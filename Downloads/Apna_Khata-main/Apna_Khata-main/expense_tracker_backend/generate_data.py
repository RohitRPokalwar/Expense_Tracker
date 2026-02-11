import csv
import random

# --- Configuration ---
# You can change this number to generate more or fewer rows
NUM_ROWS = 1200
OUTPUT_FILE = 'sample_data.csv'

# Define categories and corresponding items. More items lead to a better model.
CATEGORIES = {
    'Food': ['groceries', 'lunch', 'dinner with friends', 'coffee', 'pizza', 'breakfast', 'vegetables', 'fruits', 'takeout food', 'restaurant meal', 'snacks', 'pastries', 'ice cream'],
    'Transport': ['uber ride', 'taxi fare', 'bus ticket', 'metro card recharge', 'train ticket', 'fuel for car', 'parking fee', 'auto rickshaw fare', 'flight ticket', 'car service'],
    'Shopping': ['new shirt', 'jeans', 'headphones', 'book', 'skincare products', 'running shoes', 'gift', 'watch', 'laptop', 'mobile phone', 'furniture', 'home decor', 'sunglasses'],
    'Utilities': ['electricity bill', 'internet bill', 'phone recharge', 'water bill', 'gas cylinder', 'house rent', 'maintenance fee', 'DTH recharge', 'broadband payment', 'subscription service'],
    'Health': ['medicines', 'doctor\'s visit fee', 'health insurance premium', 'vitamins', 'band-aids', 'lab test', 'hospital bill', 'dental checkup'],
    'Entertainment': ['movie tickets', 'concert tickets', 'Netflix subscription', 'Spotify premium', 'video game', 'bowling with friends', 'amusement park entry', 'sports match ticket'],
    'Personal Care': ['haircut', 'shampoo', 'soap', 'gym membership', 'protein powder', 'salon visit', 'cosmetics'],
    'Gifts & Donations': ['birthday gift', 'donation to charity', 'wedding present', 'gift for anniversary', 'contribution to fundraiser'],
    'Education': ['online course fee', 'textbooks', 'stationery for school', 'exam fee', 'pen and notebooks', 'udemy course', 'coursera specialization', 'school fees', 'tuition payment'], # Be more specific
    'Others': ['charity', 'donation', 'gift', 'office stationery', 'printing for work', 'photocopy', 'laundry', 'tailoring', 'repair', 'maintenance', 'pet food', 'toy', 'game', 'miscellaneous']
}

# Define sentence templates to create variety.
TEMPLATES = [
    "bought {item} for {amount} {currency}",
    "paid {amount} {currency} for {item}",
    "spent {amount} on {item}",
    "{item} cost {amount}",
    "just got {item} for {amount} {currency}",
    "purchase of {item} - {amount}",
    "recharged my {item} with {amount}",
    "monthly {item} payment of {amount}",
    "paid for {item}, amount was {amount}",
    "{item} {amount} {currency}",
]

CURRENCIES = ['rupees', 'rs', 'inr', '']

def generate_sentence():
    """Generates a random expense sentence and its category."""
    category = random.choice(list(CATEGORIES.keys()))
    item = random.choice(CATEGORIES[category])
    template = random.choice(TEMPLATES)
    currency = random.choice(CURRENCIES)

    # Generate a realistic amount based on category
    if category in ['Utilities', 'Shopping', 'Transport', 'Education']:
        amount = random.randint(200, 15000)
    elif category == 'Health':
        amount = random.randint(100, 5000)
    else:
        amount = random.randint(50, 1000)

    # Format the sentence
    text = template.format(item=item, amount=amount, currency=currency).strip()
    # Clean up potential double spaces
    text = ' '.join(text.split())
    
    return text, category

# --- Main script ---
def main():
    try:
        with open(OUTPUT_FILE, 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            # Write the header
            writer.writerow(['text', 'category'])
            
            print(f"Generating {NUM_ROWS} rows of sample data...")
            
            for i in range(NUM_ROWS):
                text, category = generate_sentence()
                writer.writerow([text, category])
                # Optional: Show progress for large generations
                if (i + 1) % 100 == 0:
                    print(f"  ...generated {i + 1}/{NUM_ROWS} rows")
            
        print(f"\nSuccessfully created '{OUTPUT_FILE}' with {NUM_ROWS} rows.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == '__main__':
    main()