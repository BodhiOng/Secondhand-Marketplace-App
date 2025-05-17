import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os
import json
import random
import uuid
import datetime
from faker import Faker
from dateutil.relativedelta import relativedelta

# Initialize Faker for generating realistic data
fake = Faker()

# Base64 encoded default images
NO_IMAGE_AVAILABLE_BASE64 = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAIjAiMDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwD2zzP9lP8AvmjzP9lP++aZRQA/zP8AZT/vmjzP9lP++aZRQA/zP9lP++aPM/2U/wC+aZRQA/zP9lP++aPM/wBlP++aZRQA/wAz/ZT/AL5o8z/ZT/vmmUUAP8z/AGU/75o8z/ZT/vmmUUAP8z/ZT/vmjzP9lP8AvmmUUAP8z/ZT/vmjzP8AZT/vmmUUAP8AM/2U/wC+aPM/2U/75plFAD/M/wBlP++aPM/2U/75plFAD/M/2U/75o8z/ZT/AL5plFAD/M/2U/75o8z/AGU/75plFAD/ADP9lP8AvmjzP9lP++aZRQA/zP8AZT/vmjzP9lP++aZRQA/zP9lP++aPM/2U/wC+aZRQA/zP9lP++aPM/wBlP++aZRQA/wAz/ZT/AL5o8z/ZT/vmmUUAP8z/AGU/75o8z/ZT/vmmUUAP8z/ZT/vmjzP9lP8AvmmUUAP8z/ZT/vmjzP8AZT/vmmUUAP8AM/2U/wC+aPM/2U/75plFAD/M/wBlP++aPM/2U/75plFAD/M/2U/75o8z/ZT/AL5plFAD/M/2U/75o8z/AGU/75plFAD/ADP9lP8AvmjzP9lP++aZRQA/zP8AZT/vmjzP9lP++aZRQA/zP9lP++aPM/2U/wC+aZRQA/zP9lP++aPM/wBlP++aZRQA/wAz/ZT/AL5o8z/ZT/vmmUUAP8z/AGU/75o8z/ZT/vmmUUAP8z/ZT/vmjzP9lP8AvmmUUAP8z/ZT/vmjzP8AZT/vmmUUAP8AM/2U/wC+aPM/2U/75plFAD/M/wBlP++aPM/2U/75plFAD/M/2U/75oplFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUU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RQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAFFFFABRRRQAUUUUAP81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKPNf1H5CiigA81/UfkKKKKAP//Z"
NO_PFP_BASE64 = "data:image/jpeg;base64,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"

def initialize_firebase():
    """Initialize Firebase Admin SDK with service account credentials."""
    # Check if the credentials file exists
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cred_path = os.path.join(script_dir, "secondhand-marketplace-app-firebase-adminsdk-fbsvc-f931bb1829.json")
    print(f"Looking for Firebase credentials at: {cred_path}")
    
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

# Data generation functions
def generate_users(num_users=20):
    """Generate sample user data with roles (buyer, seller, admin)."""
    users = []
    cities = ["Kuala Lumpur", "Johor Bahru", "Ipoh", "George Town", "Shah Alam", "Petaling Jaya", 
             "Kuching", "Kota Kinabalu", "Malacca City", "Alor Setar"]
    
    # Define roles distribution: 1 admin, 40% sellers, 60% buyers
    roles = []
    # Add 1 admin
    roles.append("admin")
    # Calculate number of sellers (about 40% of remaining users)
    num_sellers = int((num_users - 1) * 0.4)
    # Add sellers
    roles.extend(["seller"] * num_sellers)
    # Add buyers (remaining users)
    roles.extend(["buyer"] * (num_users - 1 - num_sellers))
    
    # Shuffle roles to randomize assignment
    random.shuffle(roles)
    
    for i in range(1, num_users + 1):
        role_prefix = roles[i-1].split('_')[0]
        uid = f"{role_prefix}_{i}"  # e.g., buyer_1, seller_1, admin_1
        username = fake.user_name()
        email = fake.email()
        join_date = fake.date_time_between(start_date='-2y', end_date='now')
        rating = round(random.uniform(3.0, 5.0), 1)
        wallet_balance = round(random.uniform(0, 1000), 2)
        
        # Assign role from our shuffled list
        role = roles[i-1]
                
        user = {
            "uid": uid,
            "username": username,
            "email": email,
            "profileImageUrl": NO_PFP_BASE64,
            "address": random.choice(cities),  # Using specified cities for addresses
            "joinDate": join_date,
            "walletBalance": wallet_balance,
            "role": role
        }
        users.append(user)
    
    return users

def generate_product_data(user_ids):
    """Generate sample product data for different categories."""
    categories = [
        "electronics", "furniture", "clothing", "books", 
        "sports", "toys", "home", "vehicles", "others"
    ]
    
    conditions = ["New", "Like New", "Good", "Fair", "Poor"]
        
    products = []
    
    # Category-specific product templates
    category_products = {
        "electronics": [
            {"name": "Samsung Galaxy S22", "description": "Flagship smartphone with 5G capability", "price": 2499},
            {"name": "Sony Noise Cancelling Headphones", "description": "Premium wireless headphones with industry-leading noise cancellation", "price": 899},
            {"name": "Dell XPS 13 Laptop", "description": "Ultrabook with 11th Gen Intel Core processor", "price": 4999},
            {"name": "Apple iPad Pro", "description": "12.9-inch Liquid Retina XDR display with M1 chip", "price": 3899},
            {"name": "Logitech MX Master 3 Mouse", "description": "Advanced wireless mouse for productivity", "price": 399}
        ],
        "furniture": [
            {"name": "IKEA MALM Bed Frame", "description": "Queen size bed frame with storage", "price": 899},
            {"name": "Leather Recliner Sofa", "description": "3-seater recliner sofa with cup holders", "price": 2499},
            {"name": "Wooden Dining Table Set", "description": "6-seater dining table with chairs", "price": 1299},
            {"name": "Bookshelf with Glass Doors", "description": "Tall bookshelf with adjustable shelves", "price": 599},
            {"name": "Office Desk with Drawers", "description": "Spacious desk for home office setup", "price": 799}
        ],
        "clothing": [
            {"name": "Adidas Ultraboost Shoes", "description": "Running shoes with responsive cushioning", "price": 599},
            {"name": "Levi's 501 Jeans", "description": "Original fit denim jeans", "price": 299},
            {"name": "Uniqlo AIRism T-shirt", "description": "Breathable and moisture-wicking t-shirt", "price": 59},
            {"name": "North Face Waterproof Jacket", "description": "Durable jacket for outdoor activities", "price": 799},
            {"name": "Ray-Ban Aviator Sunglasses", "description": "Classic sunglasses with UV protection", "price": 499}
        ],
        "books": [
            {"name": "Atomic Habits", "description": "Book about building good habits by James Clear", "price": 79},
            {"name": "Harry Potter Complete Collection", "description": "All seven books in the series", "price": 399},
            {"name": "The Alchemist", "description": "Paulo Coelho's bestselling novel", "price": 49},
            {"name": "Sapiens: A Brief History of Humankind", "description": "Book by Yuval Noah Harari", "price": 89},
            {"name": "Rich Dad Poor Dad", "description": "Personal finance book by Robert Kiyosaki", "price": 59}
        ],
        "sports": [
            {"name": "Yoga Mat with Carrying Strap", "description": "Non-slip exercise mat for yoga and fitness", "price": 129},
            {"name": "Basketball Spalding NBA", "description": "Official size and weight basketball", "price": 199},
            {"name": "Tennis Racket Wilson Pro", "description": "Professional tennis racket with cover", "price": 599},
            {"name": "Dumbbells Set 20kg", "description": "Adjustable dumbbells for home workouts", "price": 349},
            {"name": "Fitbit Charge 5", "description": "Advanced fitness tracker with GPS", "price": 799}
        ],
        "toys": [
            {"name": "LEGO Star Wars Millennium Falcon", "description": "Building set with minifigures", "price": 699},
            {"name": "Barbie Dreamhouse", "description": "Doll house with furniture and accessories", "price": 399},
            {"name": "Nintendo Switch Games Bundle", "description": "3 popular Switch games", "price": 599},
            {"name": "Remote Control Car", "description": "High-speed RC car with rechargeable battery", "price": 249},
            {"name": "Monopoly Board Game", "description": "Classic property trading game", "price": 129}
        ],
        "home": [
            {"name": "Philips Air Fryer", "description": "Digital air fryer for healthier cooking", "price": 499},
            {"name": "Dyson V11 Vacuum Cleaner", "description": "Cordless vacuum with powerful suction", "price": 2499},
            {"name": "Cotton Bedsheet Set", "description": "King size bedsheets with 4 pillowcases", "price": 199},
            {"name": "Nespresso Coffee Machine", "description": "Automatic coffee maker with milk frother", "price": 899},
            {"name": "Ceramic Dinner Set", "description": "16-piece dinner set for 4 people", "price": 299}
        ],
        "vehicles": [
            {"name": "Mountain Bike", "description": "21-speed mountain bike with front suspension", "price": 1299},
            {"name": "Electric Scooter", "description": "Foldable e-scooter with 25km range", "price": 1499},
            {"name": "Car Roof Rack", "description": "Universal roof rack for cars", "price": 399},
            {"name": "Motorcycle Helmet", "description": "Full-face helmet with visor", "price": 599},
            {"name": "Bicycle Child Seat", "description": "Rear-mounted child seat for bicycles", "price": 299}
        ],
        "others": [
            {"name": "Gardening Tools Set", "description": "Complete set of tools for home gardening", "price": 199},
            {"name": "Acoustic Guitar", "description": "Beginner-friendly acoustic guitar with case", "price": 699},
            {"name": "Art Supplies Kit", "description": "Painting and drawing supplies for artists", "price": 249},
            {"name": "Camping Tent 4-Person", "description": "Waterproof tent for outdoor camping", "price": 499},
            {"name": "Digital Drawing Tablet", "description": "Graphics tablet for digital artists", "price": 899}
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
            
            # Randomly select a seller ID
            seller_id = random.choice(user_ids)
            
            # Generate a random creation date within the last 90 days
            days_ago = random.randint(0, 90)
            listed_date = datetime.datetime.now() - datetime.timedelta(days=days_ago)
            
            # Create the product document
            product = {
                "id": product_id,
                "name": item["name"],
                "description": item["description"],
                "price": item["price"],
                "imageUrl": NO_IMAGE_AVAILABLE_BASE64,
                "category": category,
                "sellerId": seller_id,
                "condition": condition,
                "adBoost": random.randint(1, 1000),
                "listedDate": listed_date,
                "stock": random.randint(1, 10)
            }
            
            products.append(product)
    
    return products

def generate_orders(products, user_ids, num_orders=40):
    """Generate sample order data."""
    orders = []
    status_options = ["Pending", "Processed", "Out For Delivery", "Received", "Cancelled"]
    
    # Select random products for orders
    selected_products = random.sample(products, min(num_orders, len(products)))
    
    for i, product in enumerate(selected_products):
        # Generate a unique ID
        order_id = f"order_{uuid.uuid4().hex[:8]}"
        
        # Ensure buyer is not the seller
        available_buyers = [uid for uid in user_ids if uid != product["sellerId"]]
        buyer_id = random.choice(available_buyers)
        
        # Random quantity between 1 and 3
        quantity = random.randint(1, 3)
        
        # Original price from product
        original_price = product["price"]
        
        # Final price might have a discount (0-15%)
        discount_percent = random.randint(0, 15)
        price = round(original_price * (1 - discount_percent/100))
        
        # Random status
        status = random.choice(status_options)
        
        # Generate a purchase date after the product listing date
        product_date = product["listedDate"]
        days_after_listing = random.randint(1, 30)
        purchase_date = product_date + datetime.timedelta(days=days_after_listing)
        
        # Ensure purchase date is not in the future
        now = datetime.datetime.now()
        if purchase_date > now:
            purchase_date = now - datetime.timedelta(hours=random.randint(1, 24))
        
        order = {
            "id": order_id,
            "productId": product["id"],
            "buyerId": buyer_id,
            "sellerId": product["sellerId"],
            "quantity": quantity,
            "price": price,
            "originalPrice": original_price,
            "purchaseDate": purchase_date,
            "status": status
        }
        
        orders.append(order)
    
    return orders

def generate_reviews(orders, num_reviews=30):
    """Generate sample review data."""
    reviews = []
    
    # Only completed orders can have reviews
    completed_orders = [order for order in orders if order["status"] == "Received"]
    
    # If we don't have enough completed orders, convert some to completed
    if len(completed_orders) < num_reviews:
        additional_needed = num_reviews - len(completed_orders)
        for i in range(min(additional_needed, len(orders) - len(completed_orders))):
            orders[i]["status"] = "Received"
            completed_orders.append(orders[i])
    
    # Select random completed orders for reviews
    selected_orders = random.sample(completed_orders, min(num_reviews, len(completed_orders)))
    
    for order in selected_orders:
        # Generate a unique ID
        review_id = f"review_{uuid.uuid4().hex[:8]}"
        
        # Random rating between 1 and 5
        rating = random.randint(3, 5)  # Biased toward positive reviews
        
        # Generate review text based on rating
        if rating >= 4:
            text = random.choice([
                "Great product, exactly as described!",
                "Very satisfied with my purchase.",
                "Fast shipping and excellent quality.",
                "The seller was very responsive and helpful.",
                "Would definitely buy from this seller again!"
            ])
        else:
            text = random.choice([
                "Product was okay, but not exactly as described.",
                "Shipping took longer than expected.",
                "Average quality for the price.",
                "Seller was slow to respond to my questions.",
                "It works, but I expected better quality."
            ])
        
        # 30% chance of having an image
        image_url = None
        if random.random() < 0.3:
            image_url = NO_IMAGE_AVAILABLE_BASE64
        
        # Generate a review date after the purchase date
        purchase_date = order["purchaseDate"]
        days_after_purchase = random.randint(1, 14)
        review_date = purchase_date + datetime.timedelta(days=days_after_purchase)
        
        # Ensure review date is not in the future
        now = datetime.datetime.now()
        if review_date > now:
            review_date = now - datetime.timedelta(hours=random.randint(1, 24))
        
        review = {
            "id": review_id,
            "orderId": order["id"],
            "productId": order["productId"],
            "reviewerId": order["buyerId"],
            "sellerId": order["sellerId"],
            "rating": rating,
            "text": text,
            "imageUrl": image_url,
            "date": review_date
        }
        
        reviews.append(review)
    
    return reviews

def generate_chats(products, user_ids, num_chats=25):
    """Generate sample chat data."""
    chats = []
    
    # Select random products for chats
    selected_products = random.sample(products, min(num_chats, len(products)))
    
    for product in selected_products:
        # Generate a unique ID
        chat_id = f"chat_{uuid.uuid4().hex[:8]}"
        
        # Ensure potential buyer is not the seller
        available_buyers = [uid for uid in user_ids if uid != product["sellerId"]]
        buyer_id = random.choice(available_buyers)
        
        # Participants are the buyer and seller
        participants = [buyer_id, product["sellerId"]]
        
        # Random last message
        last_messages = [
            "Is this still available?",
            "Can you do $X for it?",
            "Where and when can we meet?",
            "Does it come with the original packaging?",
            "Can you send more pictures?",
            "I'm interested in this item.",
            "Would you be willing to deliver?",
            "Thanks, I'll think about it."
        ]
        last_message = random.choice(last_messages)
        
        # Random timestamp within the last 30 days
        days_ago = random.randint(0, 30)
        last_message_timestamp = datetime.datetime.now() - datetime.timedelta(days=days_ago, hours=random.randint(0, 23))
        
        # Random sender (buyer or seller)
        last_message_sender_id = random.choice(participants)
        
        # Random unread count for each participant
        unread_count = {}
        for participant in participants:
            if participant != last_message_sender_id:
                unread_count[participant] = random.randint(0, 5)
            else:
                unread_count[participant] = 0
        
        chat = {
            "id": chat_id,
            "participants": participants,
            "productId": product["id"],
            "lastMessage": last_message,
            "lastMessageTimestamp": last_message_timestamp,
            "lastMessageSenderId": last_message_sender_id,
            "unreadCount": unread_count
        }
        
        chats.append(chat)
    
    return chats

def generate_messages(chats, num_messages_per_chat=10):
    """Generate sample message data for each chat."""
    all_messages = []
    
    message_templates = [
        "Hi, is this still available?",
        "Yes, it's still available.",
        "What's the lowest you can go?",
        "I can do $PRICE.",
        "Can I see more pictures?",
        "Sure, I'll send some more pictures soon.",
        "Where are you located?",
        "I'm in CITY.",
        "When can we meet?",
        "How about tomorrow at 5pm?",
        "That works for me.",
        "Great, see you then!",
        "Is the condition really as described?",
        "Yes, it's in great condition.",
        "Do you have the original packaging?",
        "No, I don't have the original packaging anymore.",
        "Can you deliver it?",
        "Sorry, I can't deliver, but we can meet halfway.",
        "I'll think about it and get back to you.",
        "No problem, let me know if you have any other questions."
    ]
    
    for chat in chats:
        chat_id = chat["id"]
        participants = chat["participants"]
        last_message = chat["lastMessage"]
        last_timestamp = chat["lastMessageTimestamp"]
        
        # Generate a random number of messages for this chat
        num_messages = random.randint(3, num_messages_per_chat)
        
        messages = []
        
        # Generate messages with timestamps going backwards from the last message
        for i in range(num_messages):
            message_id = f"message_{uuid.uuid4().hex[:8]}"
            
            # Alternate sender
            sender_id = participants[i % 2]
            
            # For the last message, use the chat's last message and sender
            if i == 0:
                text = last_message
                timestamp = last_timestamp
                sender_id = chat["lastMessageSenderId"]
            else:
                # Random message text
                text = random.choice(message_templates)
                
                # Replace placeholders if needed
                if "$PRICE" in text:
                    text = text.replace("$PRICE", f"${random.randint(50, 500)}")
                if "CITY" in text:
                    text = text.replace("CITY", random.choice(["New York", "Los Angeles", "Chicago", "Houston"]))
                
                # Timestamp is earlier than the previous message
                minutes_before = random.randint(5, 60)
                timestamp = messages[i-1]["timestamp"] - datetime.timedelta(minutes=minutes_before)
            
            # 10% chance of having an image
            image_url = None
            if random.random() < 0.1:
                image_url = f"https://images.unsplash.com/photo-{random.randint(1500000000, 1600000000)}-{uuid.uuid4().hex[:8]}?w=300"
            
            # Determine if the message is read
            is_read = True
            if i == 0 and chat["unreadCount"].get(participants[1 - participants.index(sender_id)], 0) > 0:
                is_read = False
            
            message = {
                "id": message_id,
                "senderId": sender_id,
                "text": text,
                "timestamp": timestamp,
                "isRead": is_read,
                "imageUrl": image_url,
                "chatId": chat_id  # Reference to parent chat
            }
            
            messages.append(message)
        
        # Reverse the messages so they're in chronological order
        messages.reverse()
        all_messages.extend(messages)
    
    return all_messages

def generate_wallet_transactions(users, orders, num_extra_transactions=30):
    """Generate sample wallet transaction data."""
    transactions = []
    transaction_types = ["Deposit", "Withdrawal", "Purchase", "Sale"]
    
    # First, create transactions for all orders
    for order in orders:
        if order["status"] in ["Processed", "Out For Delivery", "Received"]:
            # Create a purchase transaction for the buyer
            buyer_transaction_id = f"transaction_{uuid.uuid4().hex[:8]}"
            buyer_transaction = {
                "id": buyer_transaction_id,
                "userId": order["buyerId"],
                "type": "Purchase",
                "amount": -order["price"],  # Negative amount for purchase
                "description": f"Payment for order {order['id']}",
                "relatedOrderId": order["id"],
                "timestamp": order["purchaseDate"]
            }
            transactions.append(buyer_transaction)
            
            # Create a sale transaction for the seller
            seller_transaction_id = f"transaction_{uuid.uuid4().hex[:8]}"
            seller_transaction = {
                "id": seller_transaction_id,
                "userId": order["sellerId"],
                "type": "Sale",
                "amount": order["price"],  # Positive amount for sale
                "description": f"Payment received for order {order['id']}",
                "relatedOrderId": order["id"],
                "timestamp": order["purchaseDate"]
            }
            transactions.append(seller_transaction)
    
    # Generate additional random transactions
    for _ in range(num_extra_transactions):
        transaction_id = f"transaction_{uuid.uuid4().hex[:8]}"
        user_id = random.choice(users)["uid"]
        transaction_type = random.choice(transaction_types)
        
        # Amount depends on transaction type
        if transaction_type in ["Deposit", "Sale"]:
            amount = random.randint(10, 500)  # Positive amount
        else:  # Withdrawal or Purchase
            amount = -random.randint(10, 500)  # Negative amount
        
        # Description based on type
        if transaction_type == "Deposit":
            description = "Wallet top-up"
        elif transaction_type == "Withdrawal":
            description = "Withdrawal to bank account"
        elif transaction_type == "Purchase":
            description = "Product purchase"
        else:  # Sale
            description = "Product sale"
        
        # Random timestamp within the last 90 days
        days_ago = random.randint(0, 90)
        timestamp = datetime.datetime.now() - datetime.timedelta(days=days_ago, hours=random.randint(0, 23))
        
        transaction = {
            "id": transaction_id,
            "userId": user_id,
            "type": transaction_type,
            "amount": amount,
            "description": description,
            "relatedOrderId": None,  # No related order for these random transactions
            "timestamp": timestamp
        }
        
        transactions.append(transaction)
    
    return transactions

def generate_reports(products, user_ids, num_reports=15):
    """Generate sample report data."""
    reports = []
    report_reasons = [
        "Counterfeit item",
        "Inappropriate content",
        "Misleading description",
        "Prohibited item",
        "Scam"
    ]
    status_options = ["Pending", "Investigating", "Resolved", "Dismissed"]
    
    # Select random products for reports
    selected_products = random.sample(products, min(num_reports, len(products)))
    
    for product in selected_products:
        # Generate a unique ID
        report_id = f"report_{uuid.uuid4().hex[:8]}"
        
        # Ensure reporter is not the seller
        available_reporters = [uid for uid in user_ids if uid != product["sellerId"]]
        reporter_id = random.choice(available_reporters)
        
        # Random reason and description
        reason = random.choice(report_reasons)
        
        # Description based on reason
        if reason == "Counterfeit item":
            description = "I believe this item is not authentic as claimed."
        elif reason == "Inappropriate content":
            description = "The listing contains inappropriate images or text."
        elif reason == "Misleading description":
            description = "The item description does not match the actual product."
        elif reason == "Prohibited item":
            description = "This item should not be allowed for sale on the platform."
        else:  # Scam
            description = "The seller is asking for payment outside the platform."
        
        # Random timestamp within the last 60 days
        days_ago = random.randint(0, 60)
        timestamp = datetime.datetime.now() - datetime.timedelta(days=days_ago, hours=random.randint(0, 23))
        
        # Random status, weighted toward pending and investigating for newer reports
        if days_ago < 7:
            status_weights = [0.7, 0.3, 0, 0]  # Mostly pending for very recent reports
        elif days_ago < 14:
            status_weights = [0.3, 0.5, 0.1, 0.1]  # More investigating for recent reports
        else:
            status_weights = [0.1, 0.2, 0.4, 0.3]  # More resolved/dismissed for older reports
        
        status = random.choices(status_options, weights=status_weights, k=1)[0]
        
        report = {
            "id": report_id,
            "reporterId": reporter_id,
            "productId": product["id"],
            "sellerId": product["sellerId"],
            "reason": reason,
            "description": description,
            "timestamp": timestamp,
            "status": status
        }
        
        reports.append(report)
    
    return reports


def populate_users(db, users):
    """Populate the users collection with sample data."""
    if not db:
        return
    
    # Reference to the users collection
    users_collection = db.collection('users')
    
    # Add each user to the collection
    for user in users:
        try:
            # Use the user uid as the document ID
            users_collection.document(user['uid']).set(user)
            print(f"Added user: {user['username']} with ID: {user['uid']}")
        except Exception as e:
            print(f"Error adding user {user['username']}: {e}")

def populate_products(db, products):
    """Populate the products collection with sample data."""
    if not db:
        return
    
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

def populate_orders(db, orders):
    """Populate the orders collection with sample data."""
    if not db:
        return
    
    # Reference to the orders collection
    orders_collection = db.collection('orders')
    
    # Add each order to the collection
    for order in orders:
        try:
            # Use the order id as the document ID
            orders_collection.document(order['id']).set(order)
            print(f"Added order with ID: {order['id']}")
        except Exception as e:
            print(f"Error adding order {order['id']}: {e}")

def populate_reviews(db, reviews):
    """Populate the reviews collection with sample data."""
    if not db:
        return
    
    # Reference to the reviews collection
    reviews_collection = db.collection('reviews')
    
    # Add each review to the collection
    for review in reviews:
        try:
            # Use the review id as the document ID
            reviews_collection.document(review['id']).set(review)
            print(f"Added review with ID: {review['id']}")
        except Exception as e:
            print(f"Error adding review {review['id']}: {e}")

def populate_chats(db, chats):
    """Populate the chats collection with sample data."""
    if not db:
        return
    
    # Reference to the chats collection
    chats_collection = db.collection('chats')
    
    # Add each chat to the collection
    for chat in chats:
        try:
            # Use the chat id as the document ID
            chats_collection.document(chat['id']).set(chat)
            print(f"Added chat with ID: {chat['id']}")
        except Exception as e:
            print(f"Error adding chat {chat['id']}: {e}")

def populate_messages(db, messages):
    """Populate the messages subcollection for each chat."""
    if not db:
        return
    
    # Group messages by chat ID
    messages_by_chat = {}
    for message in messages:
        chat_id = message['chatId']
        if chat_id not in messages_by_chat:
            messages_by_chat[chat_id] = []
        messages_by_chat[chat_id].append(message)
    
    # Add messages to each chat's subcollection
    for chat_id, chat_messages in messages_by_chat.items():
        # Reference to the messages subcollection for this chat
        messages_collection = db.collection('chats').document(chat_id).collection('messages')
        
        for message in chat_messages:
            try:
                # Use the message id as the document ID
                messages_collection.document(message['id']).set(message)
                print(f"Added message with ID: {message['id']} to chat: {chat_id}")
            except Exception as e:
                print(f"Error adding message {message['id']}: {e}")

def populate_wallet_transactions(db, transactions):
    """Populate the walletTransactions collection with sample data."""
    if not db:
        return
    
    # Reference to the walletTransactions collection
    transactions_collection = db.collection('walletTransactions')
    
    # Add each transaction to the collection
    for transaction in transactions:
        try:
            # Use the transaction id as the document ID
            transactions_collection.document(transaction['id']).set(transaction)
            print(f"Added wallet transaction with ID: {transaction['id']}")
        except Exception as e:
            print(f"Error adding wallet transaction {transaction['id']}: {e}")

def clear_collection(db, collection_name):
    """Delete all documents in a collection."""
    if not db:
        return
    
    # Reference to the collection
    collection_ref = db.collection(collection_name)
    
    # Get all documents in the collection
    docs = collection_ref.limit(500).stream()  # Limit to 500 docs at a time for safety
    deleted = 0
    
    # Delete each document
    for doc in docs:
        doc.reference.delete()
        deleted += 1
    
    print(f"Deleted {deleted} documents from {collection_name} collection")
    return deleted

def clear_all_collections(db):
    """Clear all collections in the Firebase database."""
    if not db:
        return
    
    print("Clearing all collections...")
    
    # List of all collections to clear
    collections = [
        'users',
        'products',
        'orders',
        'reviews',
        'chats',
        'walletTransactions',
        'reports'
    ]
    
    # Clear each collection
    for collection in collections:
        clear_collection(db, collection)
        
    # Special handling for messages subcollection
    chats_ref = db.collection('chats')
    chats = chats_ref.stream()
    
    for chat in chats:
        messages_ref = chat.reference.collection('messages')
        clear_collection(db, f"chats/{chat.id}/messages")
    
    print("All collections cleared successfully")

def populate_reports(db, reports):
    """Populate the reports collection with sample data."""
    if not db:
        return
    
    # Reference to the reports collection
    reports_collection = db.collection('reports')
    
    # Add each report to the collection
    for report in reports:
        try:
            # Use the report id as the document ID
            reports_collection.document(report['id']).set(report)
            print(f"Added report with ID: {report['id']}")
        except Exception as e:
            print(f"Error adding report {report['id']}: {e}")

def main():
    print("Starting Firebase data population script...")
    
    try:
        db = initialize_firebase()
        print(f"Database connection result: {db}")
        if not db:
            print("Failed to initialize Firebase. Exiting.")
            return
    except Exception as e:
        print(f"Exception during Firebase initialization: {e}")
        import traceback
        traceback.print_exc()
        return
    
    # Clear all existing data from the database
    clear_all_collections(db)
    
    # Generate all data
    print("Generating sample data...")
    users = generate_users(20)  # Generate 20 users
    user_ids = [user['uid'] for user in users]
    
    products = generate_product_data(user_ids)
    orders = generate_orders(products, user_ids, 40)
    reviews = generate_reviews(orders, 30)
    chats = generate_chats(products, user_ids, 25)
    messages = generate_messages(chats, 10)
    transactions = generate_wallet_transactions(users, orders, 30)
    reports = generate_reports(products, user_ids, 15)
    
    # Populate collections
    print("Populating Firebase collections...")
    populate_users(db, users)
    populate_products(db, products)
    populate_orders(db, orders)
    populate_reviews(db, reviews)
    populate_chats(db, chats)
    populate_messages(db, messages)
    populate_wallet_transactions(db, transactions)
    populate_reports(db, reports)
    
    print("Data population completed successfully!")
    print(f"Created {len(users)} users")
    print(f"Created {len(products)} products")
    print(f"Created {len(orders)} orders")
    print(f"Created {len(reviews)} reviews")
    print(f"Created {len(chats)} chats")
    print(f"Created {len(messages)} messages")
    print(f"Created {len(transactions)} wallet transactions")
    print(f"Created {len(reports)} reports")

if __name__ == "__main__":
    main()
