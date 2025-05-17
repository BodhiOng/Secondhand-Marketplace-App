import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constants.dart';
import 'models/product.dart';

class SellerListingPage extends StatefulWidget {
  const SellerListingPage({super.key});

  @override
  State<SellerListingPage> createState() => _SellerListingPageState();
}

class _SellerListingPageState extends State<SellerListingPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Product> _products = [];
  bool _isLoading = true;
  String _errorMessage = '';
  String? _sellerId;

  @override
  void initState() {
    super.initState();
    _sellerId = _auth.currentUser?.uid;
    _fetchSellerProducts();
  }

  // Fetch products for the current seller
  Future<void> _fetchSellerProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      if (_sellerId == null) {
        throw Exception('User not authenticated');
      }

      final QuerySnapshot productsSnapshot = await _firestore
          .collection('products')
          .where('sellerId', isEqualTo: _sellerId)
          .orderBy('listedDate', descending: true)
          .get();

      final List<Product> fetchedProducts = [];

      for (var doc in productsSnapshot.docs) {
        final productData = doc.data() as Map<String, dynamic>;
        fetchedProducts.add(Product.fromFirestore(productData, doc.id));
      }

      setState(() {
        _products = fetchedProducts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error fetching products: $e';
        _isLoading = false;
      });
    }
  }

  // Delete a product
  Future<void> _deleteProduct(String productId) async {
    try {
      await _firestore.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Product deleted successfully'),
          backgroundColor: AppColors.mutedTeal,
        ),
      );
      _fetchSellerProducts(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting product: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        foregroundColor: AppColors.coolGray,
        title: const Text('My Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // Navigate to add product page
              // TODO: Implement add product page
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Add product functionality coming soon'),
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: AppColors.mutedTeal,
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: TextStyle(color: AppColors.coolGray),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchSellerProducts,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mutedTeal,
                        ),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _products.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory,
                            size: 64,
                            color: AppColors.coolGray.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No products listed yet',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to add product page
                              // TODO: Implement add product page
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Add product functionality coming soon'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.mutedTeal,
                            ),
                            child: const Text('Add Product'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchSellerProducts,
                      color: AppColors.mutedTeal,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return _buildProductCard(product);
                        },
                      ),
                    ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: AppColors.deepSlateGray,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product image and status
          Stack(
            children: [
              // Product image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[800],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.white54,
                            size: 40,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              // Stock indicator
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: product.stock > 0
                        ? Colors.green.withOpacity(0.8)
                        : Colors.red.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    product.stock > 0 ? 'In Stock: ${product.stock}' : 'Out of Stock',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              
              // Boost indicator if product is boosted
              if (product.adBoost > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Boosted ${product.adBoost.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          
          // Product details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product name
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.coolGray,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                
                // Price and category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RM ${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.mutedTeal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.deepSlateGray,
                        border: Border.all(color: AppColors.coolGray.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        product.category,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.coolGray,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Min bargain price
                if (product.minBargainPrice != null)
                  Text(
                    'Min. Bargain: RM ${product.minBargainPrice!.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.coolGray.withOpacity(0.7),
                    ),
                  ),
                const SizedBox(height: 8),
                
                // Condition and listing date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Condition: ${product.condition}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.coolGray,
                      ),
                    ),
                    Text(
                      'Listed: ${_formatDate(product.listedDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.coolGray.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Edit button
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to edit product page
                        // TODO: Implement edit product page
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Edit product functionality coming soon'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Edit'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.coolGray,
                        side: BorderSide(color: AppColors.coolGray.withOpacity(0.5)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Delete button
                    OutlinedButton.icon(
                      onPressed: () {
                        // Show confirmation dialog
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.deepSlateGray,
                            title: Text(
                              'Delete Product',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                            content: Text(
                              'Are you sure you want to delete "${product.name}"? This action cannot be undone.',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(color: AppColors.coolGray),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  _deleteProduct(product.id);
                                },
                                child: Text(
                                  'Delete',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.delete, size: 16),
                      label: const Text('Delete'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Format date to a readable string
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 2) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else {
      return '${(difference.inDays / 365).floor()} years ago';
    }
  }
}
