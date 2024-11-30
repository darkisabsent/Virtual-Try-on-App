import pandas as pd

# Sample size chart for a clothing brand
# This could be replaced by real data from the clothing brand's size chart
size_chart = {
    "S": {"chest": (34, 36), "waist": (28, 30), "hips": (34, 36)},
    "M": {"chest": (37, 39), "waist": (31, 33), "hips": (37, 39)},
    "L": {"chest": (40, 42), "waist": (34, 36), "hips": (40, 42)},
    "XL": {"chest": (43, 45), "waist": (37, 39), "hips": (43, 45)},
    "XXL": {"chest": (46, 48), "waist": (40, 42), "hips": (46, 48)},
}

# Function to recommend size based on user measurements
def recommend_size(user_measurements):
    
    # Initialize the best size with a score
    best_size = None
    best_fit_score = float('inf')  # A lower score indicates a better fit
    
    for size, chart in size_chart.items():
        fit_score = 0
        
        # Calculate the difference in measurements for chest, waist, and hips
        for key in chart:
            min_val, max_val = chart[key]
            user_val = user_measurements[key]
            
            # If the user's measurement is outside the range, assign a high score
            if user_val < min_val or user_val > max_val:
                fit_score += abs(user_val - (min_val if user_val < min_val else max_val))
            else:
                fit_score += 0  # Perfect fit for that measurement
                
        # If this size has a better fit score, update the best size
        if fit_score < best_fit_score:
            best_size = size
            best_fit_score = fit_score
            
    return best_size

# Example of user measurements (chest, waist, hips)
user_measurements = {
    "chest": 38,  # inches
    "waist": 32,  # inches
    "hips": 37,   # inches
}

# Recommend the best size based on user measurements
recommended_size = recommend_size(user_measurements)
print(f"Recommended size: {recommended_size}")

