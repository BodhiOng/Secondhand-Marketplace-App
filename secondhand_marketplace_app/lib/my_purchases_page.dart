import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_page.dart';
import 'my_wallet_page.dart';
import 'my_profile_page.dart';
import 'models/purchase_order.dart';
import 'models/product.dart';
import 'utils/page_transitions.dart';

class MyPurchasesPage extends StatefulWidget {
  const MyPurchasesPage({super.key});

  @override
  State<MyPurchasesPage> createState() => _MyPurchasesPageState();
}

class _MyPurchasesPageState extends State<MyPurchasesPage> {
  int _selectedIndex = 1; // Set to 1 for My Purchases tab

  // Sample purchase orders for demonstration
  final List<PurchaseOrder> _purchaseOrders = [
    PurchaseOrder(
      id: 'ORD-001',
      product: Product(
        id: '1',
        name: 'iPhone 13 Pro',
        description:
            'Slightly used iPhone 13 Pro, 256GB storage, Pacific Blue color.',
        price: 699.99,
        imageUrl: 'https://picsum.photos/id/1/200/200',
        category: 'Electronics',
        sellerId: 'seller_1',
        seller: 'John Doe',
        rating: 4.7,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 3)),
        stock: 3,
        adBoost: 50.0,
      ),
      quantity: 1,
      price: 699.99,
      purchaseDate: DateTime.now().subtract(const Duration(days: 2)),
      status: OrderStatus.pending,
    ),
    PurchaseOrder(
      id: 'ORD-002',
      product: Product(
        id: '2',
        name: 'Leather Sofa',
        description:
            'Brown leather sofa, 3-seater, 2 years old. Very comfortable.',
        price: 450.00,
        imageUrl: 'https://picsum.photos/id/2/200/200',
        category: 'Furniture',
        sellerId: 'seller_2',
        seller: 'Jane Smith',
        rating: 4.9,
        condition: 'Excellent',
        listedDate: DateTime.now().subtract(const Duration(days: 5)),
        stock: 1,
        adBoost: 100.0,
      ),
      quantity: 1,
      price: 450.00,
      purchaseDate: DateTime.now().subtract(const Duration(days: 5)),
      status: OrderStatus.processed,
    ),
    PurchaseOrder(
      id: 'ORD-003',
      product: Product(
        id: '3',
        name: 'Nike Air Jordan',
        description:
            'Nike Air Jordan 1, size US 10, worn only twice. Original box included.',
        price: 180.00,
        imageUrl: 'https://picsum.photos/id/3/200/200',
        category: 'Clothing',
        sellerId: 'seller_3',
        seller: 'Mike Johnson',
        rating: 4.5,
        condition: 'Like New',
        listedDate: DateTime.now().subtract(const Duration(days: 1)),
        stock: 1,
        adBoost: 75.0,
      ),
      quantity: 1,
      price: 180.00,
      purchaseDate: DateTime.now().subtract(const Duration(days: 1)),
      status: OrderStatus.outForDelivery,
    ),
    PurchaseOrder(
      id: 'ORD-004',
      product: Product(
        id: '4',
        name: 'Harry Potter Collection',
        description:
            'Complete set of Harry Potter books (7 books), hardcover edition.',
        price: 120.00,
        imageUrl: 'https://picsum.photos/id/4/200/200',
        category: 'Books',
        sellerId: 'seller_4',
        seller: 'Sarah Williams',
        rating: 4.8,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 7)),
        stock: 2,
        adBoost: 25.0,
      ),
      quantity: 1,
      price: 120.00,
      purchaseDate: DateTime.now().subtract(const Duration(days: 10)),
      status: OrderStatus.received,
      rating: 5.0,
      review: 'Excellent condition, exactly as described!',
    ),
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate directly to HomePage
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(
          page: const MyHomePage(title: 'Secondhand Marketplace'),
        ),
      );
    } else if (index == 1) {
      // Already on My Purchases page, just update index
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 2) {
      // Navigate to My Wallet page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyWalletPage()),
      );
    } else if (index == 3) {
      // Navigate to Profile page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyProfilePage()),
      );
    }
  }

  // Cancel an order
  void _cancelOrder(PurchaseOrder order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.deepSlateGray,
            title: Text(
              'Cancel Order',
              style: TextStyle(color: AppColors.coolGray),
            ),
            content: Text(
              'Are you sure you want to cancel this order?',
              style: TextStyle(color: AppColors.coolGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('No', style: TextStyle(color: AppColors.mutedTeal)),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    order.status = OrderStatus.cancelled;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Order cancelled successfully'),
                      backgroundColor: AppColors.warmCoral,
                    ),
                  );
                },
                child: Text(
                  'Yes',
                  style: TextStyle(color: AppColors.warmCoral),
                ),
              ),
            ],
          ),
    );
  }

  // Mark order as received
  void _markAsReceived(PurchaseOrder order) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.deepSlateGray,
            title: Text(
              'Confirm Receipt',
              style: TextStyle(color: AppColors.coolGray),
            ),
            content: Text(
              'Confirm that you have received this order? This will release payment to the seller.',
              style: TextStyle(color: AppColors.coolGray),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.mutedTeal),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    order.status = OrderStatus.received;
                  });
                  Navigator.pop(context);
                  // Show rating dialog
                  _showRatingDialog(order);
                },
                child: Text(
                  'Confirm Receipt',
                  style: TextStyle(color: AppColors.mutedTeal),
                ),
              ),
            ],
          ),
    );
  }

  // Show rating dialog
  void _showRatingDialog(PurchaseOrder order) {
    double rating = 5.0;
    final reviewController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.deepSlateGray,
            title: Text(
              'Rate & Review',
              style: TextStyle(color: AppColors.coolGray),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How would you rate this product?',
                    style: TextStyle(color: AppColors.coolGray),
                  ),
                  const SizedBox(height: 16),
                  // Star rating
                  StatefulBuilder(
                    builder: (context, setStateDialog) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return IconButton(
                            icon: Icon(
                              index < rating.floor()
                                  ? Icons.star
                                  : (index == rating.floor() && rating % 1 > 0)
                                  ? Icons.star_half
                                  : Icons.star_border,
                              color: AppColors.softLemonYellow,
                              size: 32,
                            ),
                            onPressed: () {
                              setStateDialog(() {
                                rating = index + 1.0;
                              });
                            },
                          );
                        }),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  // Review text field
                  TextField(
                    controller: reviewController,
                    maxLines: 3,
                    style: TextStyle(color: AppColors.coolGray),
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      hintStyle: TextStyle(
                        color: AppColors.coolGray.withAlpha(150),
                      ),
                      filled: true,
                      fillColor: AppColors.charcoalBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.coolGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.mutedTeal),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Skip',
                  style: TextStyle(color: AppColors.coolGray),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    order.rating = rating;
                    order.review =
                        reviewController.text.isNotEmpty
                            ? reviewController.text
                            : null;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Thank you for your review!'),
                      backgroundColor: AppColors.mutedTeal,
                    ),
                  );
                },
                child: Text(
                  'Submit',
                  style: TextStyle(color: AppColors.mutedTeal),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'My Purchases',
          style: TextStyle(color: AppColors.coolGray),
        ),
      ),
      body:
          _purchaseOrders.isEmpty
              ? _buildEmptyPurchases()
              : _buildPurchasesList(),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            label: 'My Purchases',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        backgroundColor: AppColors.deepSlateGray,
        selectedItemColor: AppColors.softLemonYellow,
        unselectedItemColor: AppColors.coolGray,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  // Empty purchases view
  Widget _buildEmptyPurchases() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: 80,
            color: AppColors.coolGray.withAlpha(150),
          ),
          const SizedBox(height: 16),
          Text(
            'No purchases yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.coolGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your purchase history will appear here',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.coolGray.withAlpha(150),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mutedTeal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Start Shopping',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Purchases list view
  Widget _buildPurchasesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _purchaseOrders.length,
      itemBuilder: (context, index) {
        final order = _purchaseOrders[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppColors.deepSlateGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // Order header with ID and date
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.charcoalBlack.withAlpha(100),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Order ${order.id}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.coolGray,
                      ),
                    ),
                    Text(
                      '${order.purchaseDate.day}/${order.purchaseDate.month}/${order.purchaseDate.year}',
                      style: TextStyle(
                        color: AppColors.coolGray.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
              // Order content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        order.product.imageUrl,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Product details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.product.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.coolGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.product.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.coolGray.withAlpha(150),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          // Quantity and price
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Qty: ${order.quantity}',
                                style: TextStyle(color: AppColors.coolGray),
                              ),
                              Text(
                                'RM ${order.totalPrice.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.mutedTeal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Status and action buttons
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.charcoalBlack.withAlpha(100),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  children: [
                    // Status row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Status: ',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: order.getStatusColor().withAlpha(50),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                order.getStatusText(),
                                style: TextStyle(
                                  color: order.getStatusColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Rating if available
                        if (order.rating != null)
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: AppColors.softLemonYellow,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                order.rating!.toStringAsFixed(1),
                                style: TextStyle(color: AppColors.coolGray),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Action buttons
                    if (order.canCancel ||
                        order.canMarkAsReceived ||
                        order.canRate)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Cancel button
                            if (order.canCancel)
                              ElevatedButton(
                                onPressed: () => _cancelOrder(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.warmCoral,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Cancel Order',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            // Mark as received button
                            if (order.canMarkAsReceived) ...[
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _markAsReceived(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.mutedTeal,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Confirm Receipt',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                            // Rate button
                            if (order.canRate) ...[
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => _showRatingDialog(order),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.softLemonYellow,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  'Rate & Review',
                                  style: TextStyle(
                                    color: AppColors.charcoalBlack,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    // Review if available
                    if (order.review != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.charcoalBlack.withAlpha(150),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: AppColors.coolGray.withAlpha(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Your Review:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.coolGray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                order.review!,
                                style: TextStyle(
                                  color: AppColors.coolGray.withAlpha(200),
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
