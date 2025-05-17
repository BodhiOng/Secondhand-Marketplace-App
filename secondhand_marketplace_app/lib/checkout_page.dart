import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'models/cart_item.dart';
import 'models/product.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;

  const CheckoutPage({super.key, required this.cartItems});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _isEditMode = false;
  late List<CartItem> _cartItems;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
    // Save cart items to local storage whenever they are loaded
    _saveCartItemsToLocalStorage();
  }
  
  // Save cart items to local storage
  Future<void> _saveCartItemsToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid ?? 'guest';
      
      // Convert cart items to JSON
      final List<Map<String, dynamic>> cartItemsJson = _cartItems.map((item) {
        return {
          'productId': item.product.id,
          'name': item.product.name,
          'price': item.product.price,
          'imageUrl': item.product.imageUrl,
          'condition': item.product.condition,
          'sellerId': item.product.sellerId,
          'category': item.product.category,
          'quantity': item.quantity,
          'isSelected': item.isSelected,
        };
      }).toList();
      
      // Save to shared preferences
      await prefs.setString('cart_$userId', jsonEncode(cartItemsJson));
      debugPrint('Cart saved to local storage: ${_cartItems.length} items');
    } catch (e) {
      debugPrint('Error saving cart items: $e');
    }
  }
  
  // Load cart items from local storage
  static Future<List<CartItem>> loadCartItemsFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = FirebaseAuth.instance.currentUser?.uid ?? 'guest';
      
      final String? cartItemsJson = prefs.getString('cart_$userId');
      if (cartItemsJson == null) {
        return [];
      }
      
      // Parse JSON
      final List<dynamic> decodedJson = jsonDecode(cartItemsJson);
      
      // Convert to CartItem objects
      return decodedJson.map((item) {
        return CartItem(
          product: Product(
            id: item['productId'] ?? '',
            name: item['name'] ?? '',
            description: 'Product from cart', // Default description
            price: (item['price'] ?? 0).toDouble(),
            imageUrl: item['imageUrl'] ?? '',
            condition: item['condition'] ?? 'Used',
            sellerId: item['sellerId'] ?? '',
            category: item['category'] ?? 'Other',
            listedDate: DateTime.now(),
            stock: item['quantity'] ?? 1,
            adBoost: 0.0,
          ),
          quantity: item['quantity'] ?? 1,
          isSelected: item['isSelected'] ?? false,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error loading cart items: $e');
      return [];
    }
  }
  
  // Clear cart items from local storage
  Future<void> _clearCartItemsFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = _auth.currentUser?.uid ?? 'guest';
      await prefs.remove('cart_$userId');
    } catch (e) {
      debugPrint('Error clearing cart items: $e');
    }
  }

  // Calculate total price of all items in cart
  double get _totalPrice {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  // Toggle edit mode
  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      // Reset all selections when exiting edit mode
      if (!_isEditMode) {
        for (var item in _cartItems) {
          item.isSelected = false;
        }
      }
    });
  }

  // Delete selected items
  void _deleteSelectedItems() {
    setState(() {
      _cartItems.removeWhere((item) => item.isSelected);
      _saveCartItemsToLocalStorage();
    });
  }

  // Update quantity of an item
  void _updateQuantity(int index, int change) {
    setState(() {
      int newQuantity = _cartItems[index].quantity + change;
      if (newQuantity > 0) {
        _cartItems[index].quantity = newQuantity;
        _saveCartItemsToLocalStorage();
      } else {
        // Show confirmation dialog before removing item
        _showRemoveItemDialog(index);
      }
    });
  }

  // Show dialog to confirm item removal
  void _showRemoveItemDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'Remove Item',
          style: TextStyle(color: AppColors.coolGray),
        ),
        content: Text(
          'Are you sure you want to remove ${_cartItems[index].product.name} from your cart?',
          style: TextStyle(color: AppColors.coolGray),
          overflow: TextOverflow.visible,
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
                _cartItems.removeAt(index);
                _saveCartItemsToLocalStorage();
              });
              Navigator.pop(context);
            },
            child: Text(
              'Remove',
              style: TextStyle(color: AppColors.warmCoral),
            ),
          ),
        ],
      ),
    );
  }

  // Proceed to checkout
  void _proceedToCheckout() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You need to be logged in to checkout')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Get user's wallet balance
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User profile not found')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final walletBalance = (userData['walletBalance'] ?? 0.0).toDouble();
      
      // Check if wallet has enough balance
      if (walletBalance < _totalPrice) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Insufficient wallet balance. Please top up your wallet.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }
      
      // Process each cart item as an order
      final timestamp = Timestamp.now();
      final batch = _firestore.batch();
      
      // Update wallet balance
      batch.update(
        _firestore.collection('users').doc(userId),
        {'walletBalance': FieldValue.increment(-_totalPrice)}
      );
      
      // Create orders
      for (var item in _cartItems) {
        final orderId = 'order_${DateTime.now().millisecondsSinceEpoch}_${item.product.id}';
        
        // Add order to orders collection
        batch.set(
          _firestore.collection('orders').doc(orderId),
          {
            'id': orderId,
            'buyerId': userId,
            'sellerId': item.product.sellerId,
            'productId': item.product.id,
            'quantity': item.quantity,
            'originalPrice': item.product.price,
            'price': item.totalPrice,
            'purchaseDate': timestamp,
            'status': 'Processing',
          }
        );
        
        // Add transaction to wallet transactions
        final transactionId = 'trans_${DateTime.now().millisecondsSinceEpoch}_${item.product.id}';
        batch.set(
          _firestore.collection('walletTransactions').doc(transactionId),
          {
            'id': transactionId,
            'userId': userId,
            'type': 'Purchase',
            'amount': item.totalPrice,
            'description': 'Purchase: ${item.product.name}',
            'relatedOrderId': orderId,
            'timestamp': timestamp,
            'status': 'Completed',
          }
        );
      }
      
      // Commit all operations
      await batch.commit();
      
      // Clear cart from local storage
      await _clearCartItemsFromLocalStorage();
      
      // Navigate to the order confirmation page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OrderConfirmationPage(),
        ),
      );
    } catch (e) {
      debugPrint('Error during checkout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error during checkout: $e'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'Shopping Cart',
          style: TextStyle(color: AppColors.coolGray),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.coolGray),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _toggleEditMode,
            child: Text(
              _isEditMode ? 'Cancel' : 'Edit',
              style: TextStyle(color: AppColors.mutedTeal),
            ),
          ),
        ],
      ),
      body: _cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartItemsList(),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  // Empty cart view
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppColors.coolGray.withAlpha(150),
          ),
          const SizedBox(height: 16),
          Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.coolGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add items to get started',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.coolGray.withAlpha(180),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mutedTeal,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Continue Shopping',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Cart items list
  Widget _buildCartItemsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          color: AppColors.deepSlateGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: item.isSelected
                  ? AppColors.mutedTeal
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Selection checkbox (only in edit mode)
                if (_isEditMode)
                  Checkbox(
                    value: item.isSelected,
                    onChanged: (value) {
                      setState(() {
                        item.isSelected = value ?? false;
                      });
                    },
                    fillColor: WidgetStateProperty.resolveWith<Color>(
                      (Set<WidgetState> states) {
                        if (states.contains(WidgetState.selected)) {
                          return AppColors.mutedTeal;
                        }
                        return AppColors.coolGray.withAlpha(100);
                      },
                    ),
                  ),
                // Product image
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    item.product.imageUrl,
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
                        item.product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Condition: ${item.product.condition}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.coolGray,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'RM ${item.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softLemonYellow,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Quantity controls
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                color: AppColors.coolGray,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _updateQuantity(index, -1),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.charcoalBlack,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                color: AppColors.coolGray,
                                iconSize: 20,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                onPressed: () => _updateQuantity(index, 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Bottom bar with total and checkout/edit buttons
  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.deepSlateGray,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _isEditMode
                ? _buildEditModeBottomBar()
                : _buildCheckoutBottomBar(),
      ),
    );
  }

  // Bottom bar in normal mode (total + checkout button)
  Widget _buildCheckoutBottomBar() {
    return Row(
      children: [
        // Total price
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.coolGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'RM ${_totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        // Checkout button
        ElevatedButton(
          onPressed: _cartItems.isEmpty ? null : _proceedToCheckout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mutedTeal,
            disabledBackgroundColor: AppColors.mutedTeal.withAlpha(100),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // Bottom bar in edit mode (delete + done buttons)
  Widget _buildEditModeBottomBar() {
    // Count selected items
    final selectedCount = _cartItems.where((item) => item.isSelected).length;
    final hasSelection = selectedCount > 0;

    return Row(
      children: [
        // Selected count
        Expanded(
          child: Text(
            hasSelection
                ? '$selectedCount ${selectedCount == 1 ? 'item' : 'items'} selected'
                : 'Select items to edit',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.coolGray,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Delete button
        ElevatedButton(
          onPressed: hasSelection ? _deleteSelectedItems : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.warmCoral,
            disabledBackgroundColor: AppColors.warmCoral.withAlpha(100),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 12),
        // Done button
        ElevatedButton(
          onPressed: _toggleEditMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.mutedTeal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Done',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
