import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'product_details_page.dart';
import 'models/product.dart';

class RecentItemsPage extends StatefulWidget {
  const RecentItemsPage({super.key});

  @override
  RecentItemsPageState createState() => RecentItemsPageState();
}

class RecentItemsPageState extends State<RecentItemsPage> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _selectedCondition = 'All Conditions';
  bool _showFilterOptions = false;

  // Try to get Firestore instance, but handle the case where Firebase isn't initialized
  late final FirebaseFirestore? _firestore;

  // Flag to track if Firebase is available
  bool _isFirebaseAvailable = true;
  List<Product> _recentProducts = [];
  bool _isLoading = true;

  // Sample conditions
  final List<String> _conditions = [
    'All Conditions',
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize Firestore and check if it's available
    try {
      _firestore = FirebaseFirestore.instance;
      _fetchRecentProducts();
    } catch (e) {
      debugPrint('Error accessing Firestore: $e');
      setState(() {
        _isFirebaseAvailable = false;
        _isLoading = false;
        // If Firebase is not available, use sample data
        _recentProducts = _getSampleProducts();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch recently added products
  Future<void> _fetchRecentProducts() async {
    if (!_isFirebaseAvailable || _firestore == null) {
      setState(() {
        _isLoading = false;
        // If Firebase is not available, use sample data
        _recentProducts = _getSampleProducts();
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Query products collection, order by createdAt timestamp in descending order (newest first)
      final QuerySnapshot snapshot =
          await _firestore
              .collection('products')
              .orderBy(
                'listedDate',
                descending: true,
              ) // Using the createdAt timestamp to sort by newest first
              .get();

      // Convert the documents to Product objects
      final List<Product> products =
          snapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Product.fromFirestore(data, doc.id);
          }).toList();

      setState(() {
        _recentProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      // Log error fetching recent products
      debugPrint('Error fetching recent products: $e');
      setState(() {
        _isLoading = false;
        // If there's an error, use sample data
        _recentProducts = _getSampleProducts();
      });
    }
  }

  // Sample products for when Firebase is not available
  List<Product> _getSampleProducts() {
    return [
      Product(
        id: '5',
        name: 'iPad Air 4th Gen',
        description: '64GB, Sky Blue, with Apple Pencil 2nd Gen.',
        price: 449.99,
        imageUrl: 'https://picsum.photos/id/5/200/200',
        category: 'Electronics',
        sellerId: 'seller_5',
        seller: 'TabletPro',
        rating: 4.6,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 1)),
        stock: 2,
        adBoostPrice: 100.0,
      ),
      Product(
        id: '6',
        name: 'Vintage Leather Jacket',
        description: 'Genuine leather jacket, size M, brown color.',
        price: 199.99,
        imageUrl: 'https://picsum.photos/id/20/200/200',
        category: 'Clothing',
        sellerId: 'seller_6',
        seller: 'VintageFashion',
        rating: 4.6,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 2)),
        stock: 1,
        adBoostPrice: 30.0,
      ),
      Product(
        id: '7',
        name: 'Mechanical Keyboard',
        description: 'RGB mechanical keyboard with Cherry MX Blue switches.',
        price: 129.99,
        imageUrl: 'https://picsum.photos/id/60/200/200',
        category: 'Electronics',
        sellerId: 'seller_7',
        seller: 'PCGamer',
        rating: 4.7,
        condition: 'Like New',
        listedDate: DateTime.now().subtract(const Duration(days: 3)),
        stock: 3,
        adBoostPrice: 40.0,
      ),
      Product(
        id: '8',
        name: 'Antique Wooden Chair',
        description:
            'Handcrafted wooden chair from the 1950s, excellent condition.',
        price: 349.99,
        imageUrl: 'https://picsum.photos/id/30/200/200',
        category: 'Furniture',
        sellerId: 'seller_8',
        seller: 'AntiqueCollector',
        rating: 4.9,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 4)),
        stock: 1,
        adBoostPrice: 60.0,
      ),
      Product(
        id: '9',
        name: 'Fitness Smartwatch',
        description:
            'Waterproof fitness tracker with heart rate monitor and GPS.',
        price: 179.99,
        imageUrl: 'https://picsum.photos/id/40/200/200',
        category: 'Electronics',
        sellerId: 'seller_9',
        seller: 'FitGadgets',
        rating: 4.5,
        condition: 'New',
        listedDate: DateTime.now().subtract(const Duration(days: 5)),
        stock: 4,
        adBoostPrice: 70.0,
      ),
    ];
  }

  // Filter the products based on selected filters
  List<Product> get filteredProducts {
    return _recentProducts.where((product) {
      // Price filter
      final bool priceMatch =
          product.price >= _priceRange.start &&
          product.price <= _priceRange.end;

      // Condition filter
      final bool conditionMatch =
          _selectedCondition == 'All Conditions' ||
          product.condition == _selectedCondition;

      // Search filter (if search text is entered)
      final bool searchMatch =
          _searchController.text.isEmpty ||
          product.name.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          ) ||
          product.description.toLowerCase().contains(
            _searchController.text.toLowerCase(),
          );

      return priceMatch && conditionMatch && searchMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'Recently Added Items',
          style: TextStyle(color: AppColors.coolGray),
        ),
        iconTheme: IconThemeData(color: AppColors.coolGray),
        actions: [
          IconButton(
            icon: Icon(
              _showFilterOptions ? Icons.filter_list_off : Icons.filter_list,
              color: AppColors.coolGray,
            ),
            onPressed: () {
              setState(() {
                _showFilterOptions = !_showFilterOptions;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: TextStyle(color: AppColors.coolGray),
              decoration: InputDecoration(
                hintText: 'Search in recently added items...',
                hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(128)),
                prefixIcon: Icon(Icons.search, color: AppColors.mutedTeal),
                filled: true,
                fillColor: AppColors.deepSlateGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.mutedTeal.withAlpha(100),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: AppColors.mutedTeal.withAlpha(100),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mutedTeal),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),

          // Filter options
          if (_showFilterOptions)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              color: AppColors.deepSlateGray,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Range',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.coolGray,
                    ),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    activeColor: AppColors.mutedTeal,
                    inactiveColor: AppColors.coolGray.withAlpha(100),
                    labels: RangeLabels(
                      'RM ${_priceRange.start.toStringAsFixed(0)}',
                      'RM ${_priceRange.end.toStringAsFixed(0)}',
                    ),
                    onChanged: (RangeValues values) {
                      setState(() {
                        _priceRange = values;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RM ${_priceRange.start.toStringAsFixed(0)}',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      Text(
                        'RM ${_priceRange.end.toStringAsFixed(0)}',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Condition',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.coolGray,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.mutedTeal.withAlpha(100),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCondition,
                        icon: Icon(
                          Icons.arrow_drop_down,
                          color: AppColors.coolGray,
                        ),
                        dropdownColor: AppColors.deepSlateGray,
                        style: TextStyle(color: AppColors.coolGray),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCondition = newValue;
                            });
                          }
                        },
                        items:
                            _conditions.map<DropdownMenuItem<String>>((
                              String value,
                            ) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: AppColors.coolGray),
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Products list
          Expanded(
            child:
                _isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: AppColors.mutedTeal,
                      ),
                    )
                    : filteredProducts.isEmpty
                    ? Center(
                      child: Text(
                        'No recently added items found',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: filteredProducts.length,
                      itemBuilder: (context, index) {
                        final product = filteredProducts[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        ProductDetailsPage(product: product),
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            color: AppColors.deepSlateGray,
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Product details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        // Product name with more space
                                        Text(
                                          product.name,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.coolGray,
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        // Rating and condition
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 16,
                                              color: Colors.amber[700],
                                            ),
                                            Text(
                                              ' ${product.rating} \u2022 ',
                                              style: TextStyle(
                                                color: AppColors.coolGray,
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                product.condition,
                                                style: TextStyle(
                                                  color: AppColors.coolGray,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        // Price in its own row
                                        Text(
                                          'RM ${product.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: AppColors.mutedTeal,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
