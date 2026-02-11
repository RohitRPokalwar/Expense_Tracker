import pandas as pd

try:
    df = pd.read_csv('dataset.csv')
    print("--- Checking Category Counts in dataset.csv ---\n")
    
    # Count how many times each category appears
    category_counts = df['category'].value_counts()
    
    print("Full count of all categories:")
    print(category_counts)
    
    # Find and display the categories with fewer than 2 examples
    problem_categories = category_counts[category_counts < 2]
    
    if not problem_categories.empty:
        print("\n------------------------------------------------------")
        print("🚨 PROBLEM FOUND! The following categories have only 1 entry:")
        print(problem_categories)
        print("\nSOLUTION: Open 'dataset.csv', find the rows for these categories, and either add more examples or remove them.")
        print("------------------------------------------------------")
    else:
        print("\n✅ No categories with only 1 entry were found. The 'stratify' issue might be resolved.")

except FileNotFoundError:
    print("❌ ERROR: 'dataset.csv' not found.")
except Exception as e:
    print(f"An error occurred: {e}")