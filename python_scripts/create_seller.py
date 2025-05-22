import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from firebase_admin import auth
import os
import datetime
import re

def initialize_firebase():
    """Initialize Firebase Admin SDK with service account credentials."""
    # Check if the credentials file exists
    script_dir = os.path.dirname(os.path.abspath(__file__))
    cred_path = os.path.join(script_dir, "secondhand-marketplace-app-firebase-adminsdk-fbsvc-8c45231694.json")
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
        import traceback
        traceback.print_exc()
        return None

def validate_email(email):
    """Validate email format."""
    pattern = r'^[\w\.-]+@[\w\.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None

def validate_wallet_balance(balance):
    """Validate wallet balance is a valid number."""
    try:
        balance = float(balance)
        if balance < 0:
            return False
        return True
    except ValueError:
        return False

def create_seller():
    """Create a new seller user in Firebase Authentication and Firestore."""
    print("===== Create New Seller =====\n")
    
    # Get user inputs
    while True:
        email = input("Enter email address: ")
        if validate_email(email):
            break
        print("Invalid email format. Please try again.")
    
    username = input("Enter username: ")
    address = input("Enter address: ")
    
    while True:
        wallet_balance = input("Enter wallet balance (default 0): ") or "0"
        if validate_wallet_balance(wallet_balance):
            wallet_balance = float(wallet_balance)
            break
        print("Invalid wallet balance. Please enter a valid number.")
    
    # Default values
    profile_image_url = "https://i.pinimg.com/1200x/2c/47/d5/2c47d5dd5b532f83bb55c4cd6f5bd1ef.jpg"
    password = "sellerpassword"
    role = "seller"
    
    # Initialize Firebase
    db = initialize_firebase()
    if not db:
        print("Failed to initialize Firebase. Exiting.")
        return
    
    try:
        # Create user in Firebase Authentication
        user_record = auth.create_user(
            email=email,
            password=password,
            display_name=username,
            disabled=False
        )
        
        uid = user_record.uid
        print(f"\nUser created in Firebase Authentication with UID: {uid}")
        
        # Create user in Firestore
        current_time = datetime.datetime.now()
        user_data = {
            'uid': uid,
            'username': username,
            'email': email,
            'profileImageUrl': profile_image_url,
            'address': address,
            'joinDate': current_time,
            'lastUpdated': current_time,
            'role': role,
            'walletBalance': wallet_balance
        }
        
        db.collection('users').document(uid).set(user_data)
        print("User created in Firestore users collection")
        
        print("\n===== Seller Creation Complete =====")
        print(f"Email: {email}")
        print(f"Password: {password}")
        print(f"Role: {role}")
        print("You can now log in with these credentials.")
        
    except Exception as e:
        print(f"\nAn error occurred during user creation: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    create_seller()
