import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
import os
import json

def initialize_firebase():
    """Initialize Firebase Admin SDK with service account credentials."""
    # Check if the credentials file exists
    cred_path = "secondhand-marketplace-app-firebase-adminsdk-fbsvc-f931bb1829.json"
    
    if not os.path.exists(cred_path):
        print(f"Error: Firebase credentials file not found at {cred_path}")
        print("Please download your Firebase service account key and save it as 'firebase_credentials.json'")
        print("Instructions: https://firebase.google.com/docs/admin/setup#initialize-sdk")
        return None
    
    try:
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        db = firestore.client()
        print("Firebase initialized successfully")
        return db
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return None

def populate_users(db):
    """Populate the users collection with sample data."""
    if not db:
        return
    
    # Sample user data
    users = [
        {
            "address": "Kuala Lumpur",
            "email": "bodhiong@gmail.com",
            "password": "password",  # Note: In production, never store plain text passwords
            "profileImageUrl": "-",
            "role": "buyer",
            "uid": "buyer_1",
            "username": "bodhiong",
            "walletBalance": 1500
        },
        {
            "address": "Selangor",
            "email": "xiangzhi@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "seller",
            "uid": "seller_1",
            "username": "xiangzhi",
            "walletBalance": 2500,
            "averageResponseTime": 5
        },
        {
            "address": "Johor",
            "email": "xiangzhi2@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "seller",
            "uid": "seller_2",
            "username": "xiangzhi_2",
            "walletBalance": 2500,
            "averageResponseTime": 5
        },
        {
            "address": "Penang",
            "email": "xiangzhi3@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "seller",
            "uid": "seller_3",
            "username": "xiangzhi_3",
            "walletBalance": 2500,
            "averageResponseTime": 5
        },
        {
            "address": "Sabah",
            "email": "xiangzhi4@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "seller",
            "uid": "seller_4",
            "username": "xiangzhi_4",
            "walletBalance": 2500,
            "averageResponseTime": 5
        },
        {
            "address": "Sarawak",
            "email": "xiangzhi5@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "seller",
            "uid": "seller_5",
            "username": "xiangzhi_5",
            "walletBalance": 2500,
            "averageResponseTime": 5
        },
        {
            "address": "Pahang",
            "email": "xiangzhi6@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "seller",
            "uid": "seller_6",
            "username": "xiangzhi_6",
            "walletBalance": 2500,
            "averageResponseTime": 5
        },
        {
            "address": "Kuala Lumpur",
            "email": "rin@gmail.com",
            "password": "password",
            "profileImageUrl": "-",
            "role": "admin",
            "uid": "admin_1",
            "username": "rin",
        },
    ]
    
    # Reference to the users collection
    users_collection = db.collection('users')
    
    # Add each user to the collection
    for user in users:
        try:
            # Use the uid as the document ID
            users_collection.document(user['uid']).set(user)
            print(f"Added user: {user['username']} with ID: {user['uid']}")
        except Exception as e:
            print(f"Error adding user {user['username']}: {e}")

def main():
    print("Starting Firebase user population script...")
    db = initialize_firebase()
    if db:
        populate_users(db)
        print("User population completed!")
    else:
        print("Failed to initialize Firebase. Exiting.")

if __name__ == "__main__":
    main()
