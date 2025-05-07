import 'package:flutter/material.dart';
import 'constants.dart';
import 'models/product.dart'; // To access the Product class
import 'report_item_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final Product product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  ProductDetailsPageState createState() => ProductDetailsPageState();
}

class ProductDetailsPageState extends State<ProductDetailsPage> {
  final int _availableStock = 1; // Sample stock value
  bool _showBargainSheet = false;
  double _bargainPrice = 0;
  final TextEditingController _bargainController = TextEditingController();
  
  // Calculate minimum price (70% of product price)
  double get _minimumPrice => widget.product.price * 0.7;

  // Sample seller data
  final Map<String, dynamic> _seller = {
    'name': 'John Seller',
    'city': 'New York',
    'responseTime': '< 1 hour',
    'rating': 4.8,
    'sales': 128,
    'joinDate': '2 years ago',
    'profilePic': 'https://picsum.photos/id/1005/200/200',
  };

  // Sample reviews
  final List<Map<String, dynamic>> _reviews = [
    {
      'username': 'Alice',
      'profilePic': 'https://picsum.photos/id/1001/200/200',
      'rating': 5.0,
      'date': '2 weeks ago',
      'text': 'Excellent product, exactly as described. Fast shipping and great packaging!',
      'image': 'https://picsum.photos/id/20/200/200',
    },
    {
      'username': 'Bob',
      'profilePic': 'https://picsum.photos/id/1002/200/200',
      'rating': 4.0,
      'date': '1 month ago',
      'text': 'Good quality product, but shipping took longer than expected.',
      'image': null,
    },
    {
      'username': 'Carol',
      'profilePic': 'https://picsum.photos/id/1003/200/200',
      'rating': 4.5,
      'date': '2 months ago',
      'text': 'Very satisfied with my purchase. Would buy from this seller again.',
      'image': 'https://picsum.photos/id/30/200/200',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bargainPrice = widget.product.price * 0.8; // Set initial bargain price to 80% of original
    _bargainController.text = _bargainPrice.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _bargainController.dispose();
    super.dispose();
  }

  // Calculate average rating from reviews
  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    double total = _reviews.fold(0, (sum, review) => sum + (review['rating'] as double));
    return total / _reviews.length;
  }

  // Build star rating widget
  Widget _buildRatingStars(double rating) {
    return Row(
      children: List.generate(5, (index) {
        if (index < rating.floor()) {
          return Icon(Icons.star, color: Colors.amber[700], size: 16);
        } else if (index < rating.ceil() && index > rating.floor()) {
          return Icon(Icons.star_half, color: Colors.amber[700], size: 16);
        } else {
          return Icon(Icons.star_border, color: Colors.amber[700], size: 16);
        }
      }),
    );
  }

  void _showBargainBottomSheet() {
    setState(() {
      _showBargainSheet = true;
    });
  }

  void _hideBargainBottomSheet() {
    setState(() {
      _showBargainSheet = false;
    });
  }

  void _submitBargain() {
    // Here you would typically send the bargain request to the backend
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bargain request sent for \$${_bargainPrice.toStringAsFixed(2)}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.mutedTeal,
      ),
    );
    _hideBargainBottomSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        foregroundColor: AppColors.coolGray,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.flag_outlined, color: AppColors.coolGray),
            onPressed: () {
              // Navigate to report item page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReportItemPage(product: widget.product),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Image
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
                
                // Product Info
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Name
                      Text(
                        widget.product.name,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Price and Stock
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '\$${widget.product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.mutedTeal,
                            ),
                          ),
                          Text(
                            '$_availableStock in stock',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.coolGray.withAlpha(179),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Divider
                      Divider(color: AppColors.coolGray.withAlpha(77)),
                      const SizedBox(height: 16),
                      
                      // Seller Info
                      Row(
                        children: [
                          // Seller Profile Pic
                          CircleAvatar(
                            radius: 25,
                            backgroundImage: NetworkImage(_seller['profilePic']),
                          ),
                          const SizedBox(width: 16),
                          
                          // Seller Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _seller['name'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.coolGray,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 14, color: AppColors.coolGray.withAlpha(179)),
                                    const SizedBox(width: 4),
                                    Text(
                                      _seller['city'],
                                      style: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                                    ),
                                    const SizedBox(width: 12),
                                    Icon(Icons.access_time, size: 14, color: AppColors.coolGray.withAlpha(179)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Responds in ${_seller['responseTime']}',
                                      style: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Divider
                      Divider(color: AppColors.coolGray.withAlpha(77)),
                      const SizedBox(height: 16),
                      
                      // Description
                      Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.product.description,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.coolGray,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Divider
                      Divider(color: AppColors.coolGray.withAlpha(77)),
                      const SizedBox(height: 16),
                      
                      // Reviews Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coolGray,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: TextStyle(color: AppColors.mutedTeal),
                            ),
                          ),
                        ],
                      ),
                      
                      // Rating Summary
                      Row(
                        children: [
                          _buildRatingStars(_averageRating),
                          const SizedBox(width: 8),
                          Text(
                            '${_averageRating.toStringAsFixed(1)} (${_reviews.length} reviews)',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Reviews List
                      ..._reviews.take(3).map((review) => _buildReviewItem(review)),
                      
                      // Bottom padding to ensure content isn't hidden behind the action buttons
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom Action Buttons
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.deepSlateGray,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(77),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Chat Button
                  Expanded(
                    flex: 1,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepSlateGray,
                        foregroundColor: AppColors.coolGray,
                        side: BorderSide(color: AppColors.mutedTeal),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Icon(Icons.chat_bubble_outline),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Add to Cart Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.deepSlateGray,
                        foregroundColor: AppColors.coolGray,
                        side: BorderSide(color: AppColors.mutedTeal),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Add to Cart'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Buy Now Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mutedTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Buy Now'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Bargain Button
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _showBargainBottomSheet,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmCoral,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Bargain'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bargain Bottom Sheet
          if (_showBargainSheet)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.deepSlateGray,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(77),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Make an Offer',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.coolGray,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.coolGray),
                          onPressed: _hideBargainBottomSheet,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Input your desired price for item',
                      style: TextStyle(color: AppColors.coolGray),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bargainController,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        prefixText: '\$ ',
                        prefixStyle: TextStyle(color: AppColors.mutedTeal),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(77)),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.mutedTeal),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {
                            _bargainPrice = double.tryParse(value) ?? widget.product.price * 0.8;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Minimum amount is: \$${_minimumPrice.toStringAsFixed(2)}',
                      style: TextStyle(color: AppColors.warmCoral),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _bargainPrice >= _minimumPrice ? _submitBargain : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mutedTeal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          disabledBackgroundColor: AppColors.coolGray.withAlpha(77),
                        ),
                        child: const Text('Send Bargain Request'),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Reviewer Profile Pic
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(review['profilePic']),
              ),
              const SizedBox(width: 8),
              
              // Reviewer Name
              Text(
                review['username'],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.coolGray,
                ),
              ),
              const Spacer(),
              
              // Review Date
              Text(
                review['date'],
                style: TextStyle(color: AppColors.coolGray.withAlpha(179), fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Rating
          _buildRatingStars(review['rating']),
          const SizedBox(height: 4),
          
          // Review Text
          Text(
            review['text'],
            style: TextStyle(color: AppColors.coolGray),
          ),
          
          // Review Image (if any)
          if (review['image'] != null) ...[  
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                review['image'],
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              ),
            ),
          ],
          
          const SizedBox(height: 8),
          Divider(color: AppColors.coolGray.withAlpha(77)),
        ],
      ),
    );
  }
}
