import bpy

# Function to create a simple human-like figure (for demo purposes)
def create_human_avatar(height, body_width, body_depth):
    # Create the base body (a simple cylinder as placeholder)
    bpy.ops.mesh.primitive_uv_sphere_add(radius=height / 5, location=(0, 0, height / 2))
    body = bpy.context.active_object
    body.name = "Body"
    
    # Scale the body based on user input for width and depth
    body.scale = (body_width, body_width, height)
    
    # Add a head
    bpy.ops.mesh.primitive_uv_sphere_add(radius=height / 8, location=(0, 0, height * 1.4))
    head = bpy.context.active_object
    head.name = "Head"
    
    # Scale the head to match typical human proportions
    head.scale = (0.5, 0.5, 0.5)
    
    return body, head

# Function to create clothes (for now, a simple t-shirt as an example)
def create_clothes():
    # Create a basic shirt model (using a cube for simplicity)
    bpy.ops.mesh.primitive_cube_add(size=2, location=(0, 0, 1))
    shirt = bpy.context.active_object
    shirt.name = "Shirt"
    
    # Scale the shirt to fit the human model (this would require more advanced logic in reality)
    shirt.scale = (1.2, 1.5, 0.3)
    
    return shirt

# User input for measurements
height = float(input("Enter your height (cm): "))
body_width = float(input("Enter your body width (cm): "))
body_depth = float(input("Enter your body depth (cm): "))

# Generate the avatar and clothing based on inputs
avatar_body, avatar_head = create_human_avatar(height, body_width / 100, body_depth / 100)
shirt = create_clothes()

# Position the shirt on the avatar (this is a very basic example)
shirt.location = (0, 0, height * 0.75)

# Optional: Export the model for use in other programs or visualization
# bpy.ops.export_scene.obj(filepath="/path/to/your/avatar.obj")

# Render the scene in Blender
bpy.ops.render.render(write_still=True)
