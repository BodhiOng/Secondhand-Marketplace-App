import firebase_admin
from firebase_admin import credentials
from firebase_admin import auth
from firebase_admin import firestore
import sys
import os

# Initialize Firebase Admin SDK
def initialize_firebase():
    try:
        # Path to your Firebase service account key file
        # You need to download this from Firebase Console > Project Settings > Service Accounts
        cred_path = os.path.join(os.path.dirname(__file__), 'secondhand-marketplace-app-firebase-adminsdk-fbsvc-8c45231694.json')
        cred = credentials.Certificate(cred_path)
        firebase_admin.initialize_app(cred)
        return True
    except Exception as e:
        print(f"Error initializing Firebase: {e}")
        return False

# Clear all existing auth accounts
def clear_auth_accounts():
    print("\nClearing existing auth accounts...")
    try:
        # Get all users from Firebase Auth
        page = auth.list_users()
        deleted_count = 0
        
        # Delete each user
        for user in page.users:
            auth.delete_user(user.uid)
            deleted_count += 1
            print(f"Deleted user: {user.email} (UID: {user.uid})")
        
        print(f"Successfully deleted {deleted_count} auth accounts.")
        return True
    except Exception as e:
        print(f"Error clearing auth accounts: {e}")
        return False

# Create auth accounts for all users in Firestore
def create_auth_accounts():
    # Initialize Firestore client
    db = firestore.client()
    
    # Clear existing auth accounts first
    clear_auth_accounts()
    
    # Get all users from Firestore
    users_ref = db.collection('users')
    users = users_ref.get()
    
    print(f"\nFound {len(users)} users in Firestore.")
    
    # Counters for tracking progress
    created_count = 0
    error_count = 0
    skipped_count = 0
    
    # Process each user
    for user in users:
        user_data = user.to_dict()
        uid = user_data.get('uid')
        email = user_data.get('email')
        username = user_data.get('username')
        
        # Skip users without email
        if not email:
            print(f"Skipping user {uid} - No email address found.")
            skipped_count += 1
            continue
        
        try:
            # Check if user already exists in Auth
            try:
                auth.get_user(uid)
                print(f"User {uid} already exists in Auth. Skipping.")
                skipped_count += 1
                continue
            except auth.UserNotFoundError:
                # User doesn't exist in Auth, proceed with creation
                pass
            
            # Create user in Firebase Auth
            user_record = auth.create_user(
                uid=uid,
                email=email,
                password="password",
                display_name=username
            )
            
            print(f"Created auth account for {email} with UID: {user_record.uid}")
            created_count += 1
            
        except Exception as e:
            print(f"Error creating user {uid}: {e}")
            error_count += 1
    
    # Print summary
    print("\nSummary:")
    print(f"Total users found: {len(users)}")
    print(f"Users created: {created_count}")
    print(f"Users skipped: {skipped_count}")
    print(f"Errors: {error_count}")
    print("\nGenerated passwords have been saved to 'generated_passwords.txt'")

# Main function
def main():
    print("Starting Firebase Auth account creation...")
    
    # Initialize Firebase Admin SDK
    if not initialize_firebase():
        print("Failed to initialize Firebase. Exiting.")
        sys.exit(1)
    
    # Create auth accounts
    create_auth_accounts()
    
    print("Process completed.")

if __name__ == "__main__":
    main()
