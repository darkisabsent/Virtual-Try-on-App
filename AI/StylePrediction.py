import tensorflow as tf
from tensorflow.keras import layers, models
import numpy as np
import matplotlib.pyplot as plt
from sklearn.model_selection import train_test_split
from tensorflow.keras.datasets import fashion_mnist

# Load and preprocess the Fashion-MNIST dataset
(x_train, y_train), (x_test, y_test) = fashion_mnist.load_data()

# Normalize the pixel values to be between 0 and 1
x_train, x_test = x_train / 255.0, x_test / 255.0

# Expand dimensions to match the input shape (28x28x1 for CNN input)
x_train = np.expand_dims(x_train, axis=-1)
x_test = np.expand_dims(x_test, axis=-1)

# Define the CNN model for style classification
model = models.Sequential([
    layers.Conv2D(32, (3, 3), activation='relu', input_shape=(28, 28, 1)),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.MaxPooling2D((2, 2)),
    layers.Conv2D(64, (3, 3), activation='relu'),
    layers.Flatten(),
    layers.Dense(64, activation='relu'),
    layers.Dense(10, activation='softmax')  # 10 categories for Fashion-MNIST
])

# Compile the model
model.compile(optimizer='adam',
              loss='sparse_categorical_crossentropy',
              metrics=['accuracy'])

# Train the model
model.fit(x_train, y_train, epochs=5)

# Evaluate the model on the test data
test_loss, test_acc = model.evaluate(x_test, y_test, verbose=2)
print(f"Test accuracy: {test_acc}")

# Function to predict the clothing style of an image
def predict_style(image):
    image = np.expand_dims(image, axis=0)  # Add batch dimension
    image = np.expand_dims(image, axis=-1)  # Ensure the image has 1 channel (grayscale)
    image = image / 255.0  # Normalize the image
    prediction = model.predict(image)
    return np.argmax(prediction)

# Function to match a user's clothing style based on a given item
def match_style(user_item, clothing_items):
    # Predict the style of the user's clothing item
    user_style = predict_style(user_item)
    
    # Match with the most similar clothing item based on style prediction
    matches = []
    for i, item in enumerate(clothing_items):
        item_style = predict_style(item)
        if item_style == user_style:
            matches.append(i)
    
    return matches

# Display a random image from the test set
random_index = np.random.randint(len(x_test))
plt.imshow(x_test[random_index].reshape(28, 28), cmap='gray')
plt.title(f"Predicted Style: {predict_style(x_test[random_index])}")
plt.show()

# Example: User's clothing item (can be any image from the test set)
user_item = x_test[random_index]

# Example: Some other clothing items to match against
clothing_items = [x_test[i] for i in range(10)]  # Sample first 10 items for demo

# Get the matching items
matches = match_style(user_item, clothing_items)
print(f"Matching items indices: {matches}")
