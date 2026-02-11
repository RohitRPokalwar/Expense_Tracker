import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import SGDClassifier
from sklearn.pipeline import Pipeline
from sklearn.metrics import accuracy_score
import joblib

print("--- Model Training Script Started ---")

# 1. Load the dataset
try:
    df = pd.read_csv('dataset.csv')
    print(f"✅ Dataset 'dataset.csv' loaded successfully. Found {len(df)} rows.")
except FileNotFoundError:
    print("❌ ERROR: 'dataset.csv' not found. Please make sure the dataset file is in the same directory.")
    exit()

# Handle any potential empty rows
df.dropna(subset=['text', 'category'], inplace=True)
if df.empty:
    print("❌ ERROR: Dataset is empty after dropping empty rows. Please check your CSV file.")
    exit()

# 2. Define features (X) and target (y)
X = df['text']
y = df['category']

# 3. Split data into training and testing sets
# This helps us evaluate how well the model performs on data it has never seen before.
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42, stratify=y)
print(f"✅ Data split into {len(X_train)} training samples and {len(X_test)} testing samples.")

# 4. Build the machine learning pipeline
# A pipeline chains together multiple steps. Here:
#   - TfidfVectorizer: Converts text into a matrix of numerical features.
#   - SGDClassifier: A fast and effective linear classifier, great for text.
text_clf = Pipeline([
    ('tfidf', TfidfVectorizer(stop_words='english')),
    ('clf', SGDClassifier(loss='hinge', penalty='l2',
                           alpha=1e-3, random_state=42,
                           max_iter=10, tol=None)),
])
print("✅ ML Pipeline created.")

# 5. Train the model
print("⏳ Training the model...")
text_clf.fit(X_train, y_train)
print("✅ Model training complete.")

# 6. Evaluate the model's performance on the test set
predictions = text_clf.predict(X_test)
accuracy = accuracy_score(y_test, predictions)
print(f"📈 Model Accuracy on Test Data: {accuracy:.2%}")

# 7. Save the trained pipeline to a file
# This is the file that your Flask app (app.py) will load.
model_filename = 'category_classifier.pkl'
joblib.dump(text_clf, model_filename)
print(f"\n✅ Model successfully trained and saved as '{model_filename}'!")
print("--- Script Finished ---")