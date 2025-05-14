import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os
import json
import random
import uuid
import datetime

def initialize_firebase():
    """Initialize Firebase Admin SDK with service account credentials."""
    # Check if the credentials file exists
    cred_path = "secondhand-marketplace-app-firebase-adminsdk-fbsvc-f931bb1829.json"
    
    if not os.path.exists(cred_path):
        print(f"Error: Firebase credentials file not found at {cred_path}")
        print("Please download your Firebase service account key and save it as specified")
        print("Instructions: https://firebase.google.com/docs/admin/setup#initialize-sdk")
        return None
    
    try:
        # Check if Firebase is already initialized
        if not firebase_admin._apps:
            cred = credentials.Certificate(cred_path)
            firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase initialized successfully")
        return db
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return None

def generate_product_data():
    """Generate sample product data for different categories."""
    categories = [
        "electronics", "furniture", "clothing", "books", 
        "sports", "toys", "home", "vehicles", "others"
    ]
    
    conditions = ["New", "Like New", "Good", "Fair", "Poor"]
    
    # Seller IDs (randomly choose from seller_1 to seller_6)
    seller_ids = [f"seller_{i}" for i in range(1, 7)]
    
    # Stock images for each category
    category_images = {
        "electronics": [
            "https://images.unsplash.com/photo-1498049794561-7780e7231661?w=500",  # Electronics general
            "https://images.unsplash.com/photo-1587829741301-dc798b83add3?w=500",  # Laptop
            "https://images.unsplash.com/photo-1505740420928-5e560c06d30e?w=500"   # Headphones
        ],
        "furniture": [
            "https://images.unsplash.com/photo-1555041469-a586c61ea9bc?w=500",     # Modern furniture
            "https://images.unsplash.com/photo-1538688525198-9b88f6f53126?w=500",  # Sofa
            "https://images.unsplash.com/photo-1592078615290-033ee584e267?w=500"   # Dining table
        ],
        "clothing": [
            "https://images.unsplash.com/photo-1523381210434-271e8be1f52b?w=500",  # Fashion
            "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=500",     # Shoes
            "https://images.unsplash.com/photo-1489987707025-afc232f7ea0f?w=500"   # T-shirts
        ],
        "books": [
            "https://images.unsplash.com/photo-1497633762265-9d179a990aa6?w=500",  # Books collection
            "https://images.unsplash.com/photo-1544716278-ca5e3f4abd8c?w=500",     # Open book
            "https://images.unsplash.com/photo-1495446815901-a7297e633e8d?w=500"   # Library
        ],
        "sports": [
            "https://images.unsplash.com/photo-1517649763962-0c623066013b?w=500",  # Sports equipment
            "https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=500",  # Running
            "https://images.unsplash.com/photo-1526506118085-60ce8714f8c5?w=500"   # Gym
        ],
        "toys": [
            "https://images.unsplash.com/photo-1566576912321-d58ddd7a6088?w=500",  # Toys collection
            "https://images.unsplash.com/photo-1584994696678-3d739b5ac1bf?w=500",  # Lego
            "https://images.unsplash.com/photo-1618842676088-c4d48a6a7c9d?w=500"   # Board games
        ],
        "home": [
            "https://images.unsplash.com/photo-1583847268964-b28dc8f51f92?w=500",  # Home appliances
            "https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=500",  # Kitchen
            "https://images.unsplash.com/photo-1526308182272-d2fe5e5947d8?w=500"   # Bedding
        ],
        "vehicles": [
            "https://images.unsplash.com/photo-1511919884226-fd3cad34687c?w=500",  # Cars
            "https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=500",     # Bicycles
            "https://images.unsplash.com/photo-1568772585407-9361f9bf3a87?w=500"   # Motorcycle
        ],
        "others": [
            "https://images.unsplash.com/photo-1485955900006-10f4d324d411?w=500",  # Misc items
            "https://images.unsplash.com/photo-1513542789411-b6a5d4f31634?w=500",  # Art supplies
            "https://images.unsplash.com/photo-1528498033373-3c6c08e93d79?w=500"   # Gardening
        ]
    }
    
    products = []
    
    # Category-specific product templates
    category_products = {
        "electronics": [
            {"name": "Samsung Galaxy S22", "description": "Flagship smartphone with 5G capability", "price": 2499, "stock": 3},
            {"name": "Sony Noise Cancelling Headphones", "description": "Premium wireless headphones with industry-leading noise cancellation", "price": 899, "stock": 5},
            {"name": "Dell XPS 13 Laptop", "description": "Ultrabook with 11th Gen Intel Core processor", "price": 4999, "stock": 2},
            {"name": "Apple iPad Pro", "description": "12.9-inch Liquid Retina XDR display with M1 chip", "price": 3899, "stock": 4},
            {"name": "Logitech MX Master 3 Mouse", "description": "Advanced wireless mouse for productivity", "price": 399, "stock": 10}
        ],
        "furniture": [
            {"name": "IKEA MALM Bed Frame", "description": "Queen size bed frame with storage", "price": 899, "stock": 2},
            {"name": "Leather Recliner Sofa", "description": "3-seater recliner sofa with cup holders", "price": 2499, "stock": 1},
            {"name": "Wooden Dining Table Set", "description": "6-seater dining table with chairs", "price": 1299, "stock": 1},
            {"name": "Bookshelf with Glass Doors", "description": "Tall bookshelf with adjustable shelves", "price": 599, "stock": 3},
            {"name": "Office Desk with Drawers", "description": "Spacious desk for home office setup", "price": 799, "stock": 2}
        ],
        "clothing": [
            {"name": "Adidas Ultraboost Shoes", "description": "Running shoes with responsive cushioning", "price": 599, "stock": 4},
            {"name": "Levi's 501 Jeans", "description": "Original fit denim jeans", "price": 299, "stock": 8},
            {"name": "Uniqlo AIRism T-shirt", "description": "Breathable and moisture-wicking t-shirt", "price": 59, "stock": 15},
            {"name": "North Face Waterproof Jacket", "description": "Durable jacket for outdoor activities", "price": 799, "stock": 3},
            {"name": "Ray-Ban Aviator Sunglasses", "description": "Classic sunglasses with UV protection", "price": 499, "stock": 5}
        ],
        "books": [
            {"name": "Atomic Habits", "description": "Book about building good habits by James Clear", "price": 79, "stock": 7},
            {"name": "Harry Potter Complete Collection", "description": "All seven books in the series", "price": 399, "stock": 2},
            {"name": "The Alchemist", "description": "Paulo Coelho's bestselling novel", "price": 49, "stock": 10},
            {"name": "Sapiens: A Brief History of Humankind", "description": "Book by Yuval Noah Harari", "price": 89, "stock": 5},
            {"name": "Rich Dad Poor Dad", "description": "Personal finance book by Robert Kiyosaki", "price": 59, "stock": 8}
        ],
        "sports": [
            {"name": "Yoga Mat with Carrying Strap", "description": "Non-slip exercise mat for yoga and fitness", "price": 129, "stock": 6},
            {"name": "Basketball Spalding NBA", "description": "Official size and weight basketball", "price": 199, "stock": 4},
            {"name": "Tennis Racket Wilson Pro", "description": "Professional tennis racket with cover", "price": 599, "stock": 3},
            {"name": "Dumbbells Set 20kg", "description": "Adjustable dumbbells for home workouts", "price": 349, "stock": 2},
            {"name": "Fitbit Charge 5", "description": "Advanced fitness tracker with GPS", "price": 799, "stock": 5}
        ],
        "toys": [
            {"name": "LEGO Star Wars Millennium Falcon", "description": "Building set with minifigures", "price": 699, "stock": 2},
            {"name": "Barbie Dreamhouse", "description": "Doll house with furniture and accessories", "price": 399, "stock": 3},
            {"name": "Nintendo Switch Games Bundle", "description": "3 popular Switch games", "price": 599, "stock": 4},
            {"name": "Remote Control Car", "description": "High-speed RC car with rechargeable battery", "price": 249, "stock": 5},
            {"name": "Monopoly Board Game", "description": "Classic property trading game", "price": 129, "stock": 7}
        ],
        "home": [
            {"name": "Philips Air Fryer", "description": "Digital air fryer for healthier cooking", "price": 499, "stock": 3},
            {"name": "Dyson V11 Vacuum Cleaner", "description": "Cordless vacuum with powerful suction", "price": 2499, "stock": 2},
            {"name": "Cotton Bedsheet Set", "description": "King size bedsheets with 4 pillowcases", "price": 199, "stock": 6},
            {"name": "Nespresso Coffee Machine", "description": "Automatic coffee maker with milk frother", "price": 899, "stock": 4},
            {"name": "Ceramic Dinner Set", "description": "16-piece dinner set for 4 people", "price": 299, "stock": 5}
        ],
        "vehicles": [
            {"name": "Mountain Bike", "description": "21-speed mountain bike with front suspension", "price": 1299, "stock": 2},
            {"name": "Electric Scooter", "description": "Foldable e-scooter with 25km range", "price": 1499, "stock": 3},
            {"name": "Car Roof Rack", "description": "Universal roof rack for cars", "price": 399, "stock": 4},
            {"name": "Motorcycle Helmet", "description": "Full-face helmet with visor", "price": 599, "stock": 5},
            {"name": "Bicycle Child Seat", "description": "Rear-mounted child seat for bicycles", "price": 299, "stock": 3}
        ],
        "others": [
            {"name": "Gardening Tools Set", "description": "Complete set of tools for home gardening", "price": 199, "stock": 4},
            {"name": "Acoustic Guitar", "description": "Beginner-friendly acoustic guitar with case", "price": 699, "stock": 2},
            {"name": "Art Supplies Kit", "description": "Painting and drawing supplies for artists", "price": 249, "stock": 5},
            {"name": "Camping Tent 4-Person", "description": "Waterproof tent for outdoor camping", "price": 499, "stock": 3},
            {"name": "Digital Drawing Tablet", "description": "Graphics tablet for digital artists", "price": 899, "stock": 2}
        ]
    }
    
    # Generate products for each category
    for category in categories:
        category_items = category_products[category]
        
        for item in category_items:
            # Generate a unique ID
            product_id = f"{category}_{uuid.uuid4().hex[:8]}"
            
            # Random condition from the list
            condition = random.choice(conditions)
            
            # Random ad boost price between 0 and 200
            ad_boost_price = random.randint(0, 200)
            
            # Randomly select a seller ID
            seller_id = random.choice(seller_ids)
            
            # Randomly select images from category-specific stock images
            category_stock_images = category_images[category]
            main_image = random.choice(category_stock_images)
            additional_images = random.sample(category_stock_images, min(len(category_stock_images) - 1, 2))
            
            # Generate a random creation date within the last 30 days
            days_ago = random.randint(0, 30)
            created_at = datetime.datetime.now() - datetime.timedelta(days=days_ago)
            
            # Generate a random rating between 1.0 and 5.0 with one decimal place
            rating = round(random.uniform(1.0, 5.0), 1)
            
            # Create the product document
            product = {
                "id": product_id,
                "name": item["name"],
                "description": item["description"],
                "price": item["price"],
                "imageUrl": main_image,
                "additionalImages": additional_images,
                "category": category,
                "sellerId": seller_id,
                "rating": rating,  # Add the rating field
                "condition": condition,
                "stock": item["stock"],
                "adBoostPrice": ad_boost_price,
                "createdAt": firestore.SERVER_TIMESTAMP  # Use server timestamp for accurate time
            }
            
            products.append(product)
    
    return products

def populate_products(db):
    """Populate the products collection with sample data."""
    if not db:
        return
    
    # Generate product data
    products = generate_product_data()
    
    # Reference to the products collection
    products_collection = db.collection('products')
    
    # Add each product to the collection
    for product in products:
        try:
            # Use the product id as the document ID
            products_collection.document(product['id']).set(product)
            print(f"Added product: {product['name']} with ID: {product['id']}")
        except Exception as e:
            print(f"Error adding product {product['name']}: {e}")

def main():
    print("Starting Firebase product population script...")
    db = initialize_firebase()
    if db:
        populate_products(db)
        print("Product population completed!")
    else:
        print("Failed to initialize Firebase. Exiting.")

if __name__ == "__main__":
    main()