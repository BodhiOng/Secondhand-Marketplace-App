import firebase_admin
from firebase_admin import credentials, firestore, auth
import os
import time

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

def clear_collection(db, collection_name):
    """Delete all documents in a collection."""
    if not db:
        return 0
    
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
        'reports',
        'helpCenterRequests'
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

def clear_auth_accounts():
    """Clear all users from Firebase Authentication."""
    print("\nClearing Firebase Authentication users...")
    try:
        # Get all users from Firebase Auth
        page = auth.list_users()
        deleted_count = 0
        
        # Delete each user
        for user in page.users:
            try:
                auth.delete_user(user.uid)
                deleted_count += 1
                print(f"Deleted user: {user.uid}")
                # Add a small delay to avoid rate limiting
                time.sleep(0.05)
            except Exception as e:
                print(f"Error deleting user {user.uid}: {e}")
        
        print(f"Successfully deleted {deleted_count} auth accounts.")
        return True
    except Exception as e:
        print(f"Error clearing auth accounts: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    print("Starting Firebase data clearing script...")
    
    try:
        db = initialize_firebase()
        if not db:
            print("Failed to initialize Firebase. Exiting.")
            return
    except Exception as e:
        print(f"Exception during Firebase initialization: {e}")
        import traceback
        traceback.print_exc()
        return
    
    try:
        # Clear all collections
        clear_all_collections(db)
        
        # Clear auth accounts
        clear_auth_accounts()
        
        print("\nFirebase data and authentication clearing completed successfully.")
    except Exception as e:
        print(f"\nAn error occurred during data clearing: {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()
