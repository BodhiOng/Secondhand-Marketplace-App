# Firebase User Population Script

This script populates a Firebase Firestore database with sample user data for the Secondhand Marketplace App.

## Prerequisites

1. Python 3.6 or higher
2. Firebase project with Firestore enabled
3. Firebase Admin SDK service account credentials

## Setup

1. Install the required dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Download your Firebase service account key:
   - Go to your Firebase project settings
   - Navigate to "Service accounts" tab
   - Click "Generate new private key"
   - Save the JSON file as `firebase_credentials.json` in the same directory as this script

## Usage

Run the script:
```
python populate_firebase_users.py
```

## Sample User Data

The script will create the following users in your Firestore database:

1. **Bodhi Ong (Buyer)**
   - UID: buyer_1
   - Email: bodhiong@gmail.com
   - Wallet Balance: 1500

2. **Top Seller (Seller)**
   - UID: seller_1
   - Email: seller1@example.com
   - Wallet Balance: 2500

3. **Shopaholic (Buyer)**
   - UID: buyer_2
   - Email: buyer2@example.com
   - Wallet Balance: 800

4. **Vintage Finds (Seller)**
   - UID: seller_2
   - Email: seller2@example.com
   - Wallet Balance: 3200

5. **Bargain Hunter (Buyer)**
   - UID: buyer_3
   - Email: user5@example.com
   - Wallet Balance: 1200

## Security Note

This script includes plaintext passwords for demonstration purposes only. In a production environment, you should never store plaintext passwords in your database. Instead, use Firebase Authentication to handle user credentials securely.
