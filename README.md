# Secondhand Marketplace App (ThriftNest)

This is a secondhand marketplace app developed as part of the CT124-3-2-MAE (Mobile App Engineering) group assignment for the Asia Pacific University (APU) in 2025. 

## Features

### For Buyers
- Browse products by category
- Search and filter listings
- View product details with high-quality images
- Save favorite items
- Secure checkout process
- Real-time chat with sellers
- Leave reviews and ratings
- Track orders
- Wallet functionality for payments
- Report items

### For Sellers
- Create and manage product listings
- Upload multiple product images
- Set pricing and stock levels
- Respond to buyer inquiries via chat
- Manage orders and sales
- View sales analytics
- Receive payments to wallet
- Manage product promotions with ad boost

### For Admins
- User management
- Product moderation
- Order management
- Customer support
- System monitoring

## Tech Stack

- **Framework**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication, Cloud Messaging)

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (as per Flutter version)
- Android Studio / Xcode (for emulators/simulators)
- Firebase account and project

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/BodhiOng/Secondhand-Marketplace-App.git
   cd secondhand_marketplace_app
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Set up Firebase:
   - Create a new Firebase project
   - Add Android and iOS apps to your Firebase project
   - Download the configuration files and place them in the appropriate directories
   - Enable Authentication, Firestore, and Storage in Firebase Console

4. Run the app:
   ```bash
   flutter run
   ```

## Project Structure

```
lib/
├── admin_*.dart        # Admin-specific screens
├── auth_wrapper.dart    # Authentication flow
├── buyer_*.dart         # Buyer-specific screens
├── constants.dart       # App-wide constants
├── landing_page.dart    # Initial landing/splash screen
├── main.dart            # App entry point
├── models/              # Data models
│   ├── cart_item.dart
│   ├── product.dart
│   └── purchase_order.dart
├── seller_*.dart        # Seller-specific screens
└── services/            # Business logic and services
```

## Data Models

### Product
- Basic Info: id, name, description, price
- Media: imageUrl, additionalImages
- Categorization: category, condition
- Seller Info: sellerId, seller (name)
- Metrics: rating, listedDate, adBoost
- Inventory: stock, minBargainPrice

### Purchase Order
- Order details, payment info, status tracking

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Firebase for the backend services
- All contributors who helped in developing this application