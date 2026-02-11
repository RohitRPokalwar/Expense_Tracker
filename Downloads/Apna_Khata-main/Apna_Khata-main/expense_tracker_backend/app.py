import os
import re
import joblib
from flask import Flask, request, jsonify
from flask_cors import CORS
from google.cloud import vision
from google.oauth2 import service_account
from sklearn.exceptions import InconsistentVersionWarning
import warnings

# --- 0. PRE-CONFIGURATION ---
warnings.filterwarnings("ignore", category=InconsistentVersionWarning)

# --- 1. INITIAL SETUP ---
app = Flask(__name__)
CORS(app)

# --- 2. LOAD MODELS & CLIENTS ON STARTUP ---

# Scikit-learn Model Loading
try:
    category_classifier = joblib.load('category_classifier.pkl')
    print("✅ Category classification model loaded successfully .!")
except FileNotFoundError:
    print("❌ ERROR: 'category_classifier.pkl' not found. Please run train_model.py first.")
    exit()

# Google Cloud Vision Client

# Google Cloud Vision Client
try:
    credentials_path = "gcp-vision-credentials.json"
    if os.path.exists(credentials_path):
        credentials = service_account.Credentials.from_service_account_file(credentials_path)
        vision_client = vision.ImageAnnotatorClient(credentials=credentials)
        print("✅ Google Cloud Vision client initialized successfully.")
    else:
        print("⚠️  WARNING: 'gcp-vision-credentials.json' not found. OCR features will be disabled.")
        vision_client = None
except Exception as e:
    print(f"❌ ERROR: Could not initialize Google Vision client: {e}")
    print("   OCR features will be disabled.")
    vision_client = None

# --- 3. KEYWORD DICTIONARY & HELPER FUNCTIONS ---

CATEGORY_KEYWORDS = {
    'Food & Dining': ['biryani', 'pizza', 'burger', 'sandwich', 'pasta', 'noodles', 'momo', 'thali', 'biriyani', 'dosa', 'idli', 'pav bhaji', 'maggi', 'roll', 'shawarma', 'wrap', 'ice cream', 'cake', 'pastry', 'dessert', 'coffee', 'tea', 'juice', 'smoothie', 'milkshake', 'biryani house', 'barbecue', 'kebab', 'tikka', 'restaurant', 'cafe', 'canteen', 'dining', 'buffet', 'meal', 'zomato', 'swiggy', 'dominos', 'pizza hut', "domino's", "mcdonald's", 'mcdonald', 'kfc', 'subway', 'burger king', 'starbucks', 'barista', '99 pancakes', 'chicken tandoori', 'hocco','apple', 'bikanervala', 'haldiram', 'cafe coffee day', 'baskin robbins'],
    'Grocery': ['rice', 'wheat', 'dal', 'pulses', 'sugar', 'salt', 'milk', 'bread', 'butter', 'oil', 'tea powder', 'coffee powder', 'vegetables', 'fruits', 'tomato', 'potato', 'onion', 'cabbage', 'spinach', 'coriander', 'lemon', 'masala', 'atta', 'besan', 'poha', 'suji', 'jaggery', 'eggs', 'meat', 'fish', 'chicken', 'mutton', 'prawns', 'spices', 'detergent', 'soap', 'toothpaste', 'grocery', 'bigbasket', 'dmart', 'd mart', 'reliance fresh', 'more supermarket', "nature's basket", 'spencer’s', 'jiomart'],
    'Entertainment': ['movie', 'netflix', 'spotify', 'concert', 'bookmyshow', 'hotstar', 'prime video', 'sports match', 'stadium', 'theatre', 'cricket', 'football', 'ipl', 'ticket show'],
    'Transport': ['taxi', 'cab', 'auto', 'bus', 'train', 'flight', 'airline', 'airfare', 'metro', 'tram', 'ferry', 'fuel', 'petrol', 'diesel', 'cng', 'parking', 'toll', 'ticket', 'pass', 'travel card', 'ola', 'uber', 'rapido', 'blablacar', 'redbus', 'irctc'],
    'Shopping & Lifestyle': ['shirt', 'jeans', 't-shirt', 'tshirt', 'trousers', 'kurta', 'saree', 'dress', 'shoes', 'sandals', 'chappal', 'watch', 'wallet', 'handbag', 'purse', 'belt', 'accessories', 'jacket', 'coat', 'sweater', 'hoodie', 'spectacles', 'sunglasses', 'electronics', 'phone', 'laptop', 'charger', 'earphones', 'headphones', 'camera', 'mall', 'boutique', 'apparel', 'amazon', 'flipkart', 'myntra', 'ajio', 'meesho', 'snapdeal', 'shopclues', 'tatacliq', 'h&m', 'zara', 'nike', 'adidas', 'puma', 'reebok', 'lifestyle'],
    'Healthcare & Medicine': ['doctor', 'hospital', 'clinic', 'pharmacy', 'chemist', 'medicine', 'injection', 'vaccine', 'blood test', 'sugar test', 'x-ray', 'scan', 'ct scan', 'mri', 'consultation', 'surgery', 'therapy', 'physiotherapy', 'dentist', 'dental', 'ayurvedic', 'homeopathy', 'optician', 'spectacles', 'hearing aid', 'apollo pharmacy', 'medplus', 'pharmeasy', '1mg', 'netmeds', 'practo'],
    'Personal Care & Grooming': ['salon','spa', 'haircut', 'hair wash', 'shaving', 'trimming', 'beard', 'hair color', 'facial', 'manicure', 'pedicure', 'beauty', 'makeup', 'wax', 'threading', 'perfume', 'deodorant','prostitute','lotion', 'shampoo', 'conditioner', 'body wash', 'soap', 'comb', 'mirror', 'towel', 'grooming kit', 'nykaa', 'purplle', 'wow skin', 'beardo', 'mcaffeine', 'urban company', 'jawed habib'],
    'Education': ['school fees', 'tuition', 'college fees', 'udemy', 'coursera', 'online course', 'textbooks', 'exam fee'],
    'Utilities & Bills': ['electricity bill', 'water bill', 'gas bill', 'broadband', 'wifi', 'internet', 'cable', 'dth', 'recharge', 'mobile bill', 'postpaid', 'prepaid', 'landline', 'rent', 'emi', 'loan', 'insurance', 'subscription', 'youtube premium'],
    'Gifts & Donations': ['gift', 'charity', 'donation', 'present'],
    'Others': ['stationery', 'pen', 'pencil', 'notebook', 'printing', 'photocopy', 'laundry', 'tailoring', 'repair', 'maintenance', 'pet food', 'toy', 'game', 'miscellaneous']
}

def get_category_from_keywords(text):
    text_lower = text.lower()

    # Special rule for "ticket"
    if "ticket" in text_lower:
        if any(word in text_lower for word in ["sports", "match", "cricket", "football", "concert", "movie", "show", "stadium"]):
            return "Entertainment"
        else:
            return "Transport"

    for category, keywords in CATEGORY_KEYWORDS.items():
        if any(keyword in text_lower for keyword in keywords):
            return category
    return None

def extract_amount(text):
    text_lower = text.lower()
    print(f"DEBUG: Searching amount in text (length {len(text)})")
    
    # 1. Look for explicit total labels first (Highest Priority)
    # Matches: "Total: 500", "Grand Total 1200.50", "Order Total: Rs. 500", "Total Amount ..... 500"
    # The pattern allows for significant whitespace or non-digit chars between label and value
    total_patterns = [
        r'(?:grand|order|bill|invoice|total)\s*(?:total|amount|value)?\s*[:=.-]*\s*(?:rs\.?|inr)?\s*(\d+(?:,\d+)*(?:\.\d{2})?)',
        r'amount\s*payable\s*[:=.-]*\s*(?:rs\.?|inr)?\s*(\d+(?:,\d+)*(?:\.\d{2})?)'
    ]
    
    for pattern in total_patterns:
        # Search for pattern allowing for multiline match if needed (though processed text is usually line by line)
        # We also check for the pattern spanning across some noise
        match = re.search(pattern, text_lower)
        if match:
            try:
                amount_str = match.group(1).replace(',', '')
                val = float(amount_str)
                print(f"DEBUG: Found precise total match: {val} (Pattern: {pattern})")
                return val
            except ValueError:
                continue
                
    # 1.5 Special check for "Total Amount" followed by a number later in the line (common in tables)
    # This catches "Total Amount          500.00" where the space is large
    separated_patterns = [
        r'total\s+amount.*?(\d+(?:,\d+)*(?:\.\d{2})?)',
        r'grand\s+total.*?(\d+(?:,\d+)*(?:\.\d{2})?)'
    ]
    for pattern in separated_patterns:
        match = re.search(pattern, text_lower)
        if match:
             try:
                amount_str = match.group(1).replace(',', '')
                val = float(amount_str)
                print(f"DEBUG: Found separated total match: {val} (Pattern: {pattern})")
                return val
             except ValueError:
                continue

    # 2. Fallback to previous keyword search
    amount_keywords = ['paid', 'cost', 'rs', 'inr', 'amount']
    
    for keyword in amount_keywords:
        matches = re.findall(f'{keyword}[^0-9]*(\\d+(?:,\\d+)*(?:\\.\\d{{2}})*)', text_lower)
        if matches:
            try:
                val = float(matches[-1].replace(',', ''))
                print(f"DEBUG: Found keyword match: {val} (Keyword: {keyword})")
                return val
            except: 
                continue

    # 3. Last Resort: Find the largest number
    numbers = re.findall(r'\d+(?:,\d+)*(?:\.\d+)?', text_lower)
    if not numbers: 
        print("DEBUG: No numbers found in text.")
        return None
    
    valid_amounts = []
    for n in numbers:
        try:
            val = float(n.replace(',', ''))
            if 1.0 < val < 500000: 
                valid_amounts.append(val)
        except:
            continue
            
    if valid_amounts: 
        MaxVal = max(valid_amounts)
        print(f"DEBUG: Fallback to max number: {MaxVal}")
        return MaxVal
    
    print("DEBUG: No valid amount found.")
    return None

def extract_item(text, amount):
    text_lower = text.lower()
    if amount:
        amount_str = str(int(amount) if amount % 1 == 0 else amount)
        text_lower = text_lower.replace(amount_str, '')
    text_no_numbers = re.sub(r'\d+\.?\d*', '', text_lower).strip()
    stop_words = ['bought', 'paid', 'for', 'a', 'an', 'the', 'rs', 'inr', 'rupees', 'was', 'of', 'my', 'recharged', 'new', 'got', 'purchase', 'cost', 'bill', 'amount', 'at', 'costing', 'price', 'rate']
    querywords = text_no_numbers.split()
    resultwords  = [word for word in querywords if word.lower() not in stop_words]
    item = ' '.join(resultwords).strip()
    item = re.sub(r'\s+', ' ', item).title()
    return item if item else "Unknown Item"

def parse_receipt_text(text):
    lines = text.lower().split('\n')
    item = "Scanned Receipt"
    amount = extract_amount(text)
    category = get_category_from_keywords(text) or 'Others'
    for line in lines:
        if line.strip() and len(line.strip()) > 2:
            if not re.fullmatch(r'[\d\s.,-]+', line.strip()):
                item = line.strip().title()
                break
    return {'item': item, 'amount': amount, 'category': category}

# --- 4. API ENDPOINTS ---

@app.route('/process', methods=['POST'])
def process_text():
    """Endpoint for simple text-based expenses."""
    print("\n--- Request received at /process endpoint! ---")
    try:
        data = request.get_json()
        if not data or 'text' not in data:
            return jsonify({'error': 'Invalid input. Please provide a "text" field.'}), 400

        input_text = data['text']
        
        predicted_category = get_category_from_keywords(input_text)
        if not predicted_category:
            print("-> No keyword match found. Using ML model for classification...")
            predicted_category = str(category_classifier.predict([input_text])[0])
        if predicted_category:
            print(f"-> Keyword match found! Category: {predicted_category}")
        
        amount = extract_amount(input_text)
        print(f"DEBUG: Extracted Amount: {amount}")
        
        if amount is None:
            return jsonify({'error': 'Could not determine the amount from the text.'}), 400
            
        item = extract_item(input_text, amount)

        response = {
            'item': item,
            'amount': amount,
            'category': predicted_category
        }
        print(f"✅ Processed text successfully: {response}")
        return jsonify(response)
    except Exception as e:
        print(f"❌ An error occurred in /process: {e}")
        return jsonify({'error': 'An internal server error occurred.'}), 500

@app.route('/process-image-receipt', methods=['POST'])
def process_image_receipt():
    """Endpoint for processing uploaded receipt images."""
    if vision_client is None:
        print("❌ Request received at /process-image-receipt, but OCR is disabled.")
        return jsonify({'error': 'OCR functionality is currently disabled because Google Cloud Vision credentials are missing.'}), 503

    print("\n--- Request received at /process-image-receipt endpoint! ---")
    if 'receipt' not in request.files:
        return jsonify({'error': 'No image file found in request (expected key "receipt").'}), 400
    
    file = request.files['receipt']
    
    if file.filename == '':
        return jsonify({'error': 'No image file selected.'}), 400

    try:
        print("Received image, sending to Google Cloud Vision for OCR...")
        image_content = file.read()
        image = vision.Image(content=image_content)
        
        response = vision_client.text_detection(image=image)
        
        if response.error.message:
            raise Exception(response.error.message)

        if response.text_annotations:
            full_ocr_text = response.text_annotations[0].description
            print("✅ Google Vision OCR successful. Analyzing extracted text...")
            
            processed_data = parse_receipt_text(full_ocr_text)
            
            if processed_data.get('amount') is None:
                return jsonify({'error': 'Could not determine total from receipt text.'}), 400
            
            print(f"✅ Processed image successfully: {processed_data}")
            return jsonify(processed_data)
        else:
            return jsonify({'error': 'No text detected in the image by Google Vision.'}), 400

    except Exception as e:
        print(f"❌ An error occurred during image processing: {e}")
        return jsonify({'error': 'An internal error occurred while processing the image.'}), 500

# --- PDF PROCESSING ---
import pdfplumber

@app.route('/process-pdf-receipt', methods=['POST'])
def process_pdf_receipt():
    """Endpoint for processing uploaded PDF receipts."""
    print("\n--- Request received at /process-pdf-receipt endpoint! ---")
    if 'pdf' not in request.files:
        return jsonify({'error': 'No PDF file found in request (expected key "pdf").'}), 400
    
    file = request.files['pdf']
    
    if file.filename == '':
        return jsonify({'error': 'No PDF file selected.'}), 400

    try:
        print("Received PDF, extracting text...")
        with pdfplumber.open(file) as pdf:
            full_text = ""
            for page in pdf.pages:
                text = page.extract_text()
                if text:
                    full_text += text + "\n"
            
        if not full_text.strip():
             return jsonify({'error': 'No text detected in the PDF.'}), 400

        print(f"✅ PDF text extraction successful. Analyzing extracted text...")
        print(f"📄 RAW PDF TEXT:\n{full_text}\n-------------------")
        
        # Reuse the existing parsing logic
        processed_data = parse_receipt_text(full_text)
        
        if processed_data.get('amount') is None:
            return jsonify({'error': 'Could not determine total from PDF text.'}), 400
        
        print(f"✅ Processed PDF successfully: {processed_data}")
        return jsonify(processed_data)

    except Exception as e:
        print(f"❌ An error occurred during PDF processing: {e}")
        return jsonify({'error': 'An internal error occurred while processing the PDF.'}), 500

# --- 5. RUN THE APP ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
