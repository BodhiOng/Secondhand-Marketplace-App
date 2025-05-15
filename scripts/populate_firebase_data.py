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
        
        # Profile images from Unsplash
        profile_image_url = "https://i.pinimg.com/736x/07/c4/72/07c4720d19a9e9edad9d0e939eca304a.jpg"
        
        user = {
            "uid": uid,
            "username": username,
            "email": email,
            "profileImageUrl": profile_image_url,
            "address": random.choice(cities),  # Using specified cities for addresses
            "joinDate": join_date,
            "rating": rating,
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
            
            # Randomly select images from category-specific stock images
            category_stock_images = category_images[category]
            main_image = random.choice(category_stock_images)
            additional_images = random.sample(category_stock_images, min(len(category_stock_images) - 1, 2))
            
            # Generate a random creation date within the last 90 days
            days_ago = random.randint(0, 90)
            listed_date = datetime.datetime.now() - datetime.timedelta(days=days_ago)
            
            # Create the product document
            product = {
                "id": product_id,
                "name": item["name"],
                "description": item["description"],
                "price": item["price"],
                "imageUrl": main_image,
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
            image_url = f"https://images.unsplash.com/photo-{random.randint(1500000000, 1600000000)}-{uuid.uuid4().hex[:8]}?w=300"
        
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
    status_options = ["Pending", "Completed", "Failed"]
    
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
                "timestamp": order["purchaseDate"],
                "status": "Completed"
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
                "timestamp": order["purchaseDate"],
                "status": "Completed"
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
        
        # Most transactions are completed
        status = random.choices(status_options, weights=[0.1, 0.85, 0.05], k=1)[0]
        
        transaction = {
            "id": transaction_id,
            "userId": user_id,
            "type": transaction_type,
            "amount": amount,
            "description": description,
            "relatedOrderId": None,  # No related order for these random transactions
            "timestamp": timestamp,
            "status": status
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
