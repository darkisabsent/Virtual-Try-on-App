from flask import Flask, request, jsonify, send_file
import cv2
import numpy as np
import mediapipe as mp
import os

app = Flask(__name__)

# Initialize MediaPipe Pose
mp_pose = mp.solutions.pose
pose = mp_pose.Pose(min_detection_confidence=0.5, min_tracking_confidence=0.5)

# Function to get keypoints from an image
def get_keypoints(image):
    image_rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    results = pose.process(image_rgb)
    keypoints = {}
    
    if results.pose_landmarks:
        for idx, landmark in enumerate(results.pose_landmarks.landmark):
            keypoints[idx] = (landmark.x, landmark.y)
    
    return keypoints, results.pose_landmarks

# Function to extract clothing from an image (simplified for now)
def extract_clothing(image):
    # Assuming the clothing image has a transparent background
    # Find the bounding box of the non-transparent area
    if image.shape[2] == 4:
        alpha_channel = image[:, :, 3]
        non_transparent_indices = np.where(alpha_channel > 0)
        min_y, max_y = np.min(non_transparent_indices[0]), np.max(non_transparent_indices[0])
        min_x, max_x = np.min(non_transparent_indices[1]), np.max(non_transparent_indices[1])
        return image[min_y:max_y, min_x:max_x]
    return image

# Function to warp the clothing to align with the person's keypoints
def warp_clothing(clothing_image, person_image, person_keypoints):
    # Example: Align clothing based on shoulder points (left and right shoulder)
    shoulder_left = person_keypoints.get(11)
    shoulder_right = person_keypoints.get(12)
    hip_left = person_keypoints.get(23)
    hip_right = person_keypoints.get(24)

    # If we have both shoulders and hips, proceed to warp the clothing
    if shoulder_left and shoulder_right and hip_left and hip_right:
        # Convert normalized keypoints to pixel values
        shoulder_left_pixel = (int(shoulder_left[0] * person_image.shape[1]), int(shoulder_left[1] * person_image.shape[0]))
        shoulder_right_pixel = (int(shoulder_right[0] * person_image.shape[1]), int(shoulder_right[1] * person_image.shape[0]))
        hip_left_pixel = (int(hip_left[0] * person_image.shape[1]), int(hip_left[1] * person_image.shape[0]))
        hip_right_pixel = (int(hip_right[0] * person_image.shape[1]), int(hip_right[1] * person_image.shape[0]))
        
        # Find the distance between the shoulders and the hips
        shoulder_distance = np.linalg.norm(np.array(shoulder_left_pixel) - np.array(shoulder_right_pixel))
        torso_height = np.linalg.norm(np.array(shoulder_left_pixel) - np.array(hip_left_pixel))
        
        # Resize clothing to fit the torso height with slight overfitting
        scale_factor = (torso_height / clothing_image.shape[0]) * 1.2  # Increase scale factor by 20% for overfitting
        new_width = int(clothing_image.shape[1] * scale_factor)
        new_height = int(clothing_image.shape[0] * scale_factor)
        clothing_resized = cv2.resize(clothing_image, (new_width, new_height), interpolation=cv2.INTER_AREA)

        # Calculate the offset to align clothing with the person
        x_offset = int((shoulder_left_pixel[0] + shoulder_right_pixel[0]) / 2 - new_width // 2)
        y_offset = int(shoulder_left_pixel[1]) - 40   # Adjust y_offset to place the clothing higher

        # Ensure the offsets are within the image bounds
        x_offset = max(0, min(x_offset, person_image.shape[1] - new_width))
        y_offset = max(0, min(y_offset, person_image.shape[0] - new_height))

        # Add the resized clothing image to the person image
        for c in range(0, 3):
            person_image[y_offset:y_offset + clothing_resized.shape[0], x_offset:x_offset + clothing_resized.shape[1], c] = \
                clothing_resized[:, :, c] * (clothing_resized[:, :, 3] / 255.0) + \
                person_image[y_offset:y_offset + clothing_resized.shape[0], x_offset:x_offset + clothing_resized.shape[1], c] * (1.0 - clothing_resized[:, :, 3] / 255.0)

        return person_image

    return person_image  # Return original if alignment not possible

@app.route('/try-on', methods=['POST'])
def try_on():
    if 'person_image' not in request.files or 'clothing_image' not in request.files:
        return jsonify({'error': 'Missing files'}), 400

    person_image_file = request.files['person_image']
    clothing_image_file = request.files['clothing_image']

    person_image = cv2.imdecode(np.frombuffer(person_image_file.read(), np.uint8), cv2.IMREAD_UNCHANGED)
    clothing_image = cv2.imdecode(np.frombuffer(clothing_image_file.read(), np.uint8), cv2.IMREAD_UNCHANGED)

    if person_image is None or clothing_image is None:
        return jsonify({'error': 'Invalid image files'}), 400

    # Extract clothing
    clothing_image_extracted = extract_clothing(clothing_image)

    # Get keypoints of the person
    person_keypoints, _ = get_keypoints(person_image)

    # Warp clothing to align with the person
    result_image = warp_clothing(clothing_image_extracted, person_image, person_keypoints)

    # Save the result image to a temporary file
    output_path = 'output_image.png'
    cv2.imwrite(output_path, result_image)

    return send_file(output_path, mimetype='image/png')

if __name__ == '__main__':
    app.run(debug=True)