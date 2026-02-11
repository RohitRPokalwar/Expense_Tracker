import pandas as pd
import joblib
from sklearn.metrics import classification_report, accuracy_score, confusion_matrix
import seaborn as sns
import matplotlib.pyplot as plt
import warnings
from sklearn.exceptions import InconsistentVersionWarning

# Suppress the version warning for a cleaner report
warnings.filterwarnings("ignore", category=InconsistentVersionWarning)

# --- CONFIGURATION ---
MODEL_FILE = 'category_classifier.pkl'
TEST_DATA_FILE = 'test_data.csv'
# ---------------------

def evaluate_model():
    """
    Loads the trained model and evaluates its performance on an unseen test dataset.
    """
    print("--- Starting Model Evaluation ---")

    # 1. Load the trained model
    try:
        model = joblib.load(MODEL_FILE)
        print(f"✅ Successfully loaded model from '{MODEL_FILE}'")
    except FileNotFoundError:
        print(f"❌ ERROR: Model file '{MODEL_FILE}' not found. Please run train_model.py first.")
        return

    # 2. Load the unseen test data
    try:
        test_data = pd.read_csv(TEST_DATA_FILE)
        # Ensure columns are named correctly, even if CSV has no header
        test_data.columns = ['text', 'true_category']
        print(f"✅ Successfully loaded {len(test_data)} examples from '{TEST_DATA_FILE}'")
    except FileNotFoundError:
        print(f"❌ ERROR: Test data file '{TEST_DATA_FILE}' not found. Please create it.")
        return

    # 3. Prepare the data for prediction
    X_test = test_data['text']
    y_true = test_data['true_category'] # The "ground truth" answers

    # 4. Make predictions on the test data
    print("\nRunning predictions on the test set...")
    y_pred = model.predict(X_test)

    # 5. Calculate and display performance metrics
    print("\n--- Performance Report ---")
    accuracy = accuracy_score(y_true, y_pred)
    print(f"Overall Accuracy: {accuracy:.2%}\n") # Formats as a percentage

    # The classification_report is the most important part.
    # It shows Precision, Recall, and F1-Score for each category.
    print("Detailed Classification Report:")
    print(classification_report(y_true, y_pred, zero_division=0))

    # 6. Analyze and display the specific failures
    print("\n--- Failure Analysis (Where the model was wrong) ---")
    failures = []
    for i in range(len(test_data)):
        if y_true.iloc[i] != y_pred[i]:
            failures.append({
                "Text": X_test.iloc[i],
                "True Category": y_true.iloc[i],
                "Model Predicted": y_pred[i]
            })
    
    if not failures:
        print("✅ No failures found on this test set. Excellent!")
    else:
        failure_df = pd.DataFrame(failures)
        print(failure_df.to_string())

    # 7. (Optional but great for papers) Visualize the Confusion Matrix
    print("\nGenerating confusion matrix plot...")
    try:
        labels = sorted(y_true.unique())
        cm = confusion_matrix(y_true, y_pred, labels=labels)
        plt.figure(figsize=(10, 8))
        sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', xticklabels=labels, yticklabels=labels)
        plt.xlabel('Predicted Category')
        plt.ylabel('True Category')
        plt.title('Confusion Matrix')
        plt.savefig('confusion_matrix.png')
        print("✅ Confusion matrix saved to 'confusion_matrix.png'")
    except Exception as e:
        print(f"Could not generate confusion matrix plot. Error: {e}")

if __name__ == '__main__':
    # You might need to install seaborn and matplotlib
    # pip install seaborn matplotlib
    evaluate_model()