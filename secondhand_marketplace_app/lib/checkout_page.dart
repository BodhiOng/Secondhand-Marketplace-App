import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/cart_item.dart';
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

  @override
  void initState() {
    super.initState();
    _cartItems = List.from(widget.cartItems);
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
    });
  }

  // Update quantity of an item
  void _updateQuantity(int index, int change) {
    setState(() {
      int newQuantity = _cartItems[index].quantity + change;
      if (newQuantity > 0) {
        _cartItems[index].quantity = newQuantity;
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
  void _proceedToCheckout() {
    // Navigate to the order confirmation page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const OrderConfirmationPage(),
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
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Condition: ${item.product.condition}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${item.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.softLemonYellow,
                            ),
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
        child: _isEditMode
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
              ),
              Text(
                '\$${_totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
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
