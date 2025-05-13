import 'package:flutter/material.dart';
import 'constants.dart';
import 'product_details_page.dart';
import 'models/product.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({super.key, required this.searchQuery});

  @override
  SearchResultsPageState createState() => SearchResultsPageState();
}

class SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  RangeValues _priceRange = const RangeValues(0, 10000);
  String _selectedLocation = 'All Locations';
  String _selectedCondition = 'All Conditions';
  bool _showFilterOptions = false;

  // Sample locations
  final List<String> _locations = [
    'All Locations',
    'United States',
    'Europe',
    'Asia',
    'Australia',
    'Canada',
    'United Kingdom',
  ];

  // Sample conditions
  final List<String> _conditions = [
    'All Conditions',
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor',
  ];

  // Sample search results
  final List<Product> _searchResults = [
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
      name: 'Samsung Galaxy S21',
      description: '128GB, Phantom Black, with case and screen protector.',
      price: 499.99,
      imageUrl: 'https://picsum.photos/id/4/200/200',
      category: 'Electronics',
      sellerId: 'seller_4',
      seller: 'MobileDeals',
      rating: 4.5,
      condition: 'Good',
      listedDate: DateTime.now().subtract(const Duration(days: 15)),
      stock: 3,
      adBoostPrice: 80.0,
    ),
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
      listedDate: DateTime.now().subtract(const Duration(days: 7)),
      stock: 2,
      adBoostPrice: 100.0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter the search results based on selected filters
  List<Product> get filteredResults {
    return _searchResults.where((product) {
      // Price filter
      final bool priceMatch = product.price >= _priceRange.start && 
                             product.price <= _priceRange.end;
      
      // Condition filter
      final bool conditionMatch = _selectedCondition == 'All Conditions' || 
                                 product.condition == _selectedCondition;
      
      // For location, we'd typically check the product's location field
      // Since our model doesn't have it, we'll assume all match for demo
      final bool locationMatch = _selectedLocation == 'All Locations' || true;
      
      return priceMatch && conditionMatch && locationMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        foregroundColor: AppColors.coolGray,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: AppColors.coolGray),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white, fontSize: 16),
                cursorColor: AppColors.mutedTeal,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.deepSlateGray,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search, color: AppColors.coolGray),
                    onPressed: () {
                      // Implement search functionality
                      setState(() {});
                    },
                  ),
                ),
                onSubmitted: (value) {
                  // Implement search functionality
                  setState(() {});
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.filter_list, color: AppColors.coolGray),
              onPressed: () {
                setState(() {
                  _showFilterOptions = !_showFilterOptions;
                });
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Filter options
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showFilterOptions ? 280 : 0,
            color: AppColors.deepSlateGray,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Filter Options',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.coolGray),
                    ),
                    const SizedBox(height: 16),
                    
                    // Price Range Slider
                    Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coolGray)),
                    RangeSlider(
                      values: _priceRange,
                      min: 0,
                      max: 10000,
                      activeColor: AppColors.mutedTeal,
                      inactiveColor: AppColors.coolGray.withAlpha(77),
                      labels: RangeLabels(
                        'RM ${_priceRange.start.round()}',
                        'RM ${_priceRange.end.round()}',
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
                        Text('RM ${_priceRange.start.round()}', style: TextStyle(color: AppColors.coolGray)),
                        Text('RM ${_priceRange.end.round()}', style: TextStyle(color: AppColors.coolGray)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Shipped From Dropdown
                    Text('Shipped From', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coolGray)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.deepSlateGray,
                        border: Border.all(color: AppColors.mutedTeal.withAlpha(77)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedLocation,
                        underline: Container(),
                        dropdownColor: AppColors.deepSlateGray,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.coolGray),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedLocation = newValue;
                            });
                          }
                        },
                        items: _locations.map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value, style: TextStyle(color: AppColors.coolGray)),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Item Condition Dropdown
                    Text('Item Condition', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coolGray)),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.deepSlateGray,
                        border: Border.all(color: AppColors.mutedTeal.withAlpha(77)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedCondition,
                        underline: Container(),
                        dropdownColor: AppColors.deepSlateGray,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.coolGray),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  ],
                ),
              ),
            ),
          ),
          
          // Search results
          Expanded(
            child: filteredResults.isEmpty
                ? Center(child: Text('No results found', style: TextStyle(color: AppColors.coolGray)))
                : ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: filteredResults.length,
                    itemBuilder: (context, index) {
                      final product = filteredResults[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        color: AppColors.deepSlateGray,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.imageUrl,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Text(
                            product.name,
                            style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.coolGray),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                  Text(' ${product.rating} \u2022 ', style: TextStyle(color: AppColors.coolGray)),
                                  Text(product.condition, style: TextStyle(color: AppColors.coolGray)),
                                ],
                              ),
                            ],
                          ),
                          trailing: Text(
                            'RM ${product.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: AppColors.mutedTeal,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsPage(product: product),
                              ),
                            );
                          },
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
