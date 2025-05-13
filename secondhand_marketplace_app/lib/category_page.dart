import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'product_details_page.dart';
import 'models/product.dart';

class CategoryPage extends StatefulWidget {
  final String categoryName;

  const CategoryPage({super.key, required this.categoryName});

  @override
  CategoryPageState createState() => CategoryPageState();
}

class CategoryPageState extends State<CategoryPage> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _selectedCondition = 'All Conditions';
  bool _showFilterOptions = false;
  
  // Try to get Firestore instance, but handle the case where Firebase isn't initialized
  late final FirebaseFirestore? _firestore;
  
  // Flag to track if Firebase is available
  bool _isFirebaseAvailable = true;
  List<Product> _categoryProducts = [];
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
      _fetchCategoryProducts();
    } catch (e) {
      debugPrint('Error accessing Firestore: $e');
      setState(() {
        _isFirebaseAvailable = false;
        _isLoading = false;
        // If Firebase is not available, use sample data
        _categoryProducts = _getSampleProducts();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch products for the specific category
  Future<void> _fetchCategoryProducts() async {
    if (!_isFirebaseAvailable || _firestore == null) {
      setState(() {
        _isLoading = false;
        // If Firebase is not available, use sample data
        _categoryProducts = _getSampleProducts();
      });
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Query products collection, filter by category
      final QuerySnapshot snapshot = await _firestore
          .collection('products')
          .where('category', isEqualTo: widget.categoryName.toLowerCase())
          .get();
      
      // Convert the documents to Product objects
      final List<Product> products = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Product.fromFirestore(data, doc.id);
      }).toList();
      
      setState(() {
        _categoryProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      // Log error fetching category products
      debugPrint('Error fetching category products: $e');
      setState(() {
        _isLoading = false;
        // If there's an error, use sample data
        _categoryProducts = _getSampleProducts();
      });
    }
  }

  // Sample products for when Firebase is not available
  List<Product> _getSampleProducts() {
    // Filter sample products by category
    return [
      Product(
        id: '1',
        name: 'iPhone 13 Pro',
        description: 'Slightly used iPhone 13 Pro, 256GB storage, Pacific Blue color.',
        price: 699.99,
        imageUrl: 'https://picsum.photos/id/1/200/200',
        category: 'Electronics',
        sellerId: 'seller_1',
        seller: 'TechGuru',
        rating: 4.8,
        condition: 'Like New',
        listedDate: DateTime.now().subtract(const Duration(days: 5)),
        stock: 2,
        adBoostPrice: 120.0,
      ),
      Product(
        id: '2',
        name: 'Sony WH-1000XM4 Headphones',
        description: 'Noise cancelling headphones, black color, with original box and accessories.',
        price: 249.99,
        imageUrl: 'https://picsum.photos/id/2/200/200',
        category: 'Electronics',
        sellerId: 'seller_2',
        seller: 'AudioPhile',
        rating: 4.9,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 10)),
        stock: 5,
        adBoostPrice: 50.0,
      ),
      Product(
        id: '3',
        name: 'MacBook Pro 2021',
        description: 'M1 Pro chip, 16GB RAM, 512GB SSD, Space Gray, barely used.',
        price: 1599.99,
        imageUrl: 'https://picsum.photos/id/3/200/200',
        category: 'Electronics',
        sellerId: 'seller_3',
        seller: 'AppleFan',
        rating: 4.7,
        condition: 'Like New',
        listedDate: DateTime.now().subtract(const Duration(days: 3)),
        stock: 1,
        adBoostPrice: 200.0,
      ),
      Product(
        id: '4',
        name: 'Wooden Dining Table',
        description: 'Solid oak dining table, seats 6, minor scratches.',
        price: 349.99,
        imageUrl: 'https://picsum.photos/id/10/200/200',
        category: 'Furniture',
        sellerId: 'seller_5',
        seller: 'HomeDecor',
        rating: 4.5,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 15)),
        stock: 1,
        adBoostPrice: 40.0,
      ),
      Product(
        id: '5',
        name: 'Vintage Leather Jacket',
        description: 'Genuine leather jacket, size M, brown color.',
        price: 199.99,
        imageUrl: 'https://picsum.photos/id/20/200/200',
        category: 'Clothing',
        sellerId: 'seller_6',
        seller: 'VintageFashion',
        rating: 4.6,
        condition: 'Good',
        listedDate: DateTime.now().subtract(const Duration(days: 7)),
        stock: 1,
        adBoostPrice: 30.0,
      ),
    ].where((product) => product.category == widget.categoryName).toList();
  }

  // Filter the products based on selected filters
  List<Product> get filteredProducts {
    return _categoryProducts.where((product) {
      // Price filter
      final bool priceMatch = product.price >= _priceRange.start && 
                           product.price <= _priceRange.end;
      
      // Condition filter
      final bool conditionMatch = _selectedCondition == 'All Conditions' || 
                               product.condition == _selectedCondition;
      
      // Search filter (if search text is entered)
      final bool searchMatch = _searchController.text.isEmpty ||
                            product.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
                            product.description.toLowerCase().contains(_searchController.text.toLowerCase());
      
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
          '${widget.categoryName} Items',
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
                hintText: 'Search in ${widget.categoryName}...',
                hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(128)),
                prefixIcon: Icon(Icons.search, color: AppColors.mutedTeal),
                filled: true,
                fillColor: AppColors.deepSlateGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(100)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(100)),
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.deepSlateGray,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price Range',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coolGray),
                  ),
                  RangeSlider(
                    values: _priceRange,
                    min: 0,
                    max: 10000,
                    divisions: 20,
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
                      Text('RM ${_priceRange.start.toStringAsFixed(0)}', style: TextStyle(color: AppColors.coolGray)),
                      Text('RM ${_priceRange.end.toStringAsFixed(0)}', style: TextStyle(color: AppColors.coolGray)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Condition',
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coolGray),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.mutedTeal.withAlpha(100)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCondition,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.coolGray),
                        dropdownColor: AppColors.deepSlateGray,
                        style: TextStyle(color: AppColors.coolGray),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCondition = newValue;
                            });
                          }
                        },
                        items: _conditions.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: AppColors.coolGray)),
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
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: AppColors.mutedTeal))
                : filteredProducts.isEmpty
                    ? Center(child: Text('No ${widget.categoryName} items found', style: TextStyle(color: AppColors.coolGray)))
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
                                  builder: (context) => ProductDetailsPage(product: product),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                              Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                              Text(' ${product.rating} \u2022 ', style: TextStyle(color: AppColors.coolGray)),
                                              Expanded(
                                                child: Text(
                                                  product.condition,
                                                  style: TextStyle(color: AppColors.coolGray),
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
