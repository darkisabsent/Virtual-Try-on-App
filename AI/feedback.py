import csv
import os

# Simulate user feedback (1-5 stars rating for a virtual try-on item)
def collect_user_feedback(item_id, user_id, rating, comments=None):

    feedback_data = {
        "item_id": item_id,
        "user_id": user_id,
        "rating": rating,
        "comments": comments
    }
    
    feedback_file = "user_feedback.csv"
    file_exists = os.path.isfile(feedback_file)
    
    with open(feedback_file, mode='a', newline='', encoding='utf-8') as file:
        writer = csv.DictWriter(file, fieldnames=feedback_data.keys())
        
        # If file does not exist, write header row
        if not file_exists:
            writer.writeheader()
        
        writer.writerow(feedback_data)
    print(f"Feedback recorded: {feedback_data}")


# Example: Collect feedback from multiple users
def simulate_feedback_collection():
    collect_user_feedback(item_id="1234", user_id="user_001", rating=4, comments="Good fit, but color mismatch.")
    collect_user_feedback(item_id="1234", user_id="user_002", rating=5, comments="Perfect fit, loved the color!")
    collect_user_feedback(item_id="5678", user_id="user_003", rating=3, comments="Fit is fine, but material feels cheap.")

simulate_feedback_collection()

# Function to load and analyze feedback (example analysis could be done for retraining)
def load_feedback_data():
    with open("user_feedback.csv", mode='r', encoding='utf-8') as file:
        reader = csv.DictReader(file)
        feedback_list = [row for row in reader]
    return feedback_list

# Analyze feedback: Example of averaging ratings for an item
def analyze_feedback(item_id):
    feedback_list = load_feedback_data()
    
    # Filter feedback for the given item
    item_feedback = [f for f in feedback_list if f['item_id'] == item_id]
    
    if item_feedback:
        avg_rating = sum(int(f['rating']) for f in item_feedback) / len(item_feedback)
        print(f"Average rating for item {item_id}: {avg_rating:.2f}")
    else:
        print(f"No feedback available for item {item_id}.")

# Example: Analyze feedback for item with ID '1234'
analyze_feedback(item_id="1234")

