import pandas as pd
import numpy as np
from datetime import datetime, timedelta
import calendar

def analyze_spending(expenses, income):
    """
    Analyzes expenses to provide forecast, alerts, and health score.
    
    Args:
        expenses (list): List of dicts [{'amount': 100, 'category': 'Food', 'date': '2023-10-27'}, ...]
        income (float): Monthly income.
        
    Returns:
        dict: {
            'forecast': float,
            'current_spend': float,
            'health_score': int,
            'alerts': list,
            'suggestions': list,
            'breakdown': dict
        }
    """
    if not expenses:
        return {
            'forecast': 0,
            'current_spend': 0,
            'health_score': 100,
            'alerts': [],
            'suggestions': ["Start adding expenses to get insights!"],
            'breakdown': {}
        }

    # Convert to DataFrame
    df = pd.DataFrame(expenses)
    
    # Ensure date column is datetime
    # Support 'timestamp' or 'date' keys, and handle string or timestamp objects if needed
    if 'timestamp' in df.columns:
        df['date'] = pd.to_datetime(df['timestamp'])
    elif 'date' in df.columns:
        df['date'] = pd.to_datetime(df['date'])
    else:
        # Fallback if no date found (shouldn't happen with correct DB data)
        return {'error': 'No date column found'}

    now = datetime.now()
    current_year = now.year
    current_month = now.month
    
    # Filter Current Month Data
    current_month_df = df[(df['date'].dt.year == current_year) & (df['date'].dt.month == current_month)]
    current_spend = current_month_df['amount'].sum()
    
    # Filter Last Month Data
    last_month_date = now.replace(day=1) - timedelta(days=1)
    last_month_year = last_month_date.year
    last_month_month = last_month_date.month
    last_month_df = df[(df['date'].dt.year == last_month_year) & (df['date'].dt.month == last_month_month)]
    
    alerts = []
    suggestions = []
    
    # --- 1. SMART FORECAST ---
    days_in_month = calendar.monthrange(current_year, current_month)[1]
    days_passed = now.day
    
    if days_passed > 0:
        daily_avg = current_spend / days_passed
        forecast = daily_avg * days_in_month
    else:
        forecast = current_spend # Fallback for day 0
        
    # Forecast Alert
    if income > 0 and forecast > income:
        overage = forecast - income
        alerts.append(f"Risk: Projected to exceed income by {int(overage)}.")
    
    # --- 2. BEHAVIORAL TRENDS (Category Analysis) ---
    current_cat_spend = current_month_df.groupby('category')['amount'].sum()
    last_cat_spend = last_month_df.groupby('category')['amount'].sum()
    
    breakdown = current_cat_spend.to_dict()
    
    for category, amount in current_cat_spend.items():
        if category in last_cat_spend:
            last_amount = last_cat_spend[category]
            # If spending is > 1.3x last month AND amount is significant (> 5% of income or > 1000)
            threshold = last_amount * 1.3
            if amount > threshold and amount > 500: 
                pct_increase = int(((amount - last_amount) / last_amount) * 100)
                alerts.append(f"{category}: Spending up {pct_increase}% vs last month.")
        
        # Simple high usage alert if single category eats > 30% of income
        if income > 0 and (amount / income) > 0.30:
             alerts.append(f"High Spend: {category} is consumed {int((amount/income)*100)}% of income.")

    # --- 3. SUGGESTIONS ---
    # Savings potential
    savings = income - forecast
    if savings > 0:
        savings_ratio = (savings / income) * 100
        if savings_ratio < 20:
            suggestions.append(f"Try to save at least 20%. Current projection: {int(savings_ratio)}%.")
        else:
            suggestions.append(f"Great job! On track to save {int(savings_ratio)}%.")
    else:
        suggestions.append("Look for non-essential categories to cut down.")

    # Top Category Suggestion
    if not current_cat_spend.empty:
        top_cat = current_cat_spend.idxmax()
        suggestions.append(f"Tip: {top_cat} is your highest expense. Can you reduce it?")

    today = datetime.now()
    _, days_in_month = calendar.monthrange(today.year, today.month)
    days_remaining = days_in_month - today.day
    
    # New Budget Logic
    budget_feedback = _generate_budget_feedback(current_spend, income, days_remaining)
    
    return {
        'forecast': round(forecast, 2),
        'current_spend': round(current_spend, 2),
        'health_score': _calculate_health_score(income, current_spend),
        'alerts': budget_feedback['alerts'],
        'suggestions': budget_feedback['suggestions'],
        'budget_status': budget_feedback['budget_status'],
        'breakdown': breakdown
    }

def _calculate_health_score(income, current_spend):
    if income == 0: return 50
    spend_ratio = (current_spend / income) * 100
    
    score = 100
    if spend_ratio > 100: score -= 50
    elif spend_ratio > 90: score -= 40
    elif spend_ratio > 70: score -= 20
    elif spend_ratio > 50: score -= 10
    
    return max(0, min(100, int(score)))

def _generate_budget_feedback(current_spend, budget, days_remaining):
    feedback = {'budget_status': 'within_budget', 'alerts': [], 'suggestions': []}
    
    if budget <= 0:
        feedback['suggestions'].append("Set a budget to get personalized insights!")
        return feedback

    spend_percentage = (current_spend / budget) * 100
    remaining_budget = budget - current_spend
    
    # Case 3: Overspending
    if current_spend > budget:
        over_amount = current_spend - budget
        feedback['budget_status'] = 'overspending'
        feedback['alerts'].append(f"⚠️ You have spent ₹{current_spend:,.0f} out of your ₹{budget:,.0f} budget limit.")
        feedback['alerts'].append(f"This means you have exceeded your budget by ₹{over_amount:,.0f}.")
        
        if days_remaining > 0:
             feedback['alerts'].append(f"To stay aligned, try reducing your spending by at least ₹{over_amount:,.0f} over the remaining days.")
             
        feedback['suggestions'].append(f"💡 Based on your spending pattern, reducing non-essential expenses by approximately ₹{over_amount:,.0f} can help you return within your budget limit.")

    # Case 2: Approaching Limit
    elif spend_percentage >= 70:
        feedback['budget_status'] = 'approaching_limit'
        feedback['alerts'].append(f"🔴 You have spent ₹{current_spend:,.0f} out of your ₹{budget:,.0f} monthly budget limit.")
        
        if days_remaining > 0 and remaining_budget > 0:
             daily_limit = remaining_budget / days_remaining
             feedback['alerts'].append(f"You have ₹{remaining_budget:,.0f} remaining for the next {days_remaining} days.")
             
             feedback['suggestions'].append(f"🎯 To stay within your budget, try limiting your daily spending to around ₹{daily_limit:,.0f} for the rest of the month.")
             feedback['suggestions'].append("Reducing non-essential expenses like food delivery or shopping may help you maintain balance.")
        else:
             feedback['alerts'].append("You are nearing your budget threshold. Consider reducing discretionary expenses.")

    # Case 1: Within Budget
    else:
        feedback['budget_status'] = 'within_budget'
        feedback['alerts'].append(f"🟢 You have spent ₹{current_spend:,.0f} out of your ₹{budget:,.0f} monthly limit.")
        
        if days_remaining > 0 and remaining_budget > 0:
             daily_limit = remaining_budget / days_remaining
             feedback['suggestions'].append(f"You have ₹{remaining_budget:,.0f} remaining for the next {days_remaining} days.")
             feedback['suggestions'].append(f"To stay within your budget, try limiting your daily spending to around ₹{daily_limit:,.0f} for the rest of the month.")

        feedback['suggestions'].append("🌟 From AI: Great job! You are managing your finances well.")

    return feedback
