import 'package:flutter/material.dart';
import 'constants.dart';
import 'search_results_page.dart';
import 'product_details_page.dart';
import 'checkout_page.dart';
import 'my_purchases_page.dart';
import 'my_wallet_page.dart';
import 'my_profile_page.dart';
import 'messages_page.dart';
import 'models/product.dart';
import 'models/cart_item.dart';
import 'utils/page_transitions.dart';

// Homepage for the secondhand marketplace app
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  
  // Sample categories
  final List<Category> _categories = [
    Category(name: 'Electronics', icon: Icons.devices),
    Category(name: 'Furniture', icon: Icons.chair),
    Category(name: 'Clothing', icon: Icons.checkroom),
    Category(name: 'Books', icon: Icons.book),
    Category(name: 'Sports', icon: Icons.sports_soccer),
    Category(name: 'Toys', icon: Icons.toys),
    Category(name: 'Home', icon: Icons.home),
    Category(name: 'Vehicles', icon: Icons.directions_car),
    Category(name: 'Others', icon: Icons.more_horiz),
  ];
  
  // Sample products
  final List<Product> _products = [
    Product(
      id: '1',
      name: 'iPhone 13 Pro',
      description: 'Slightly used iPhone 13 Pro, 256GB storage, Pacific Blue color. Minor scratches on the back but perfect working condition.',
      price: 699.99,
      imageUrl: 'https://picsum.photos/id/1/200/200',
      category: 'Electronics',
      seller: 'John Doe',
      rating: 4.7,
      condition: 'Good',
      listedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Product(
      id: '2',
      name: 'Leather Sofa',
      description: 'Brown leather sofa, 3-seater, 2 years old. Very comfortable and in excellent condition.',
      price: 450.00,
      imageUrl: 'https://picsum.photos/id/2/200/200',
      category: 'Furniture',
      seller: 'Jane Smith',
      rating: 4.9,
      condition: 'Excellent',
      listedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Product(
      id: '3',
      name: 'Nike Air Jordan',
      description: 'Nike Air Jordan 1, size US 10, worn only twice. Original box included.',
      price: 180.00,
      imageUrl: 'https://picsum.photos/id/3/200/200',
      category: 'Clothing',
      seller: 'Mike Johnson',
      rating: 4.5,
      condition: 'Like New',
      listedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Product(
      id: '4',
      name: 'Harry Potter Collection',
      description: 'Complete set of Harry Potter books (7 books), hardcover edition. Minor wear on the covers.',
      price: 120.00,
      imageUrl: 'https://picsum.photos/id/4/200/200',
      category: 'Books',
      seller: 'Sarah Williams',
      rating: 4.8,
      condition: 'Good',
      listedDate: DateTime.now().subtract(const Duration(days: 7)),
    ),
    Product(
      id: '5',
      name: 'Mountain Bike',
      description: 'Trek mountain bike, 21-speed, 26-inch wheels. Used for 1 year, recently serviced.',
      price: 350.00,
      imageUrl: 'https://picsum.photos/id/5/200/200',
      category: 'Sports',
      seller: 'David Brown',
      rating: 4.6,
      condition: 'Good',
      listedDate: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Product(
      id: '6',
      name: 'LEGO Star Wars Set',
      description: 'LEGO Star Wars Millennium Falcon, 75192. Built once and disassembled. All pieces included.',
      price: 550.00,
      imageUrl: 'https://picsum.photos/id/6/200/200',
      category: 'Toys',
      seller: 'Emma Davis',
      rating: 4.9,
      condition: 'Excellent',
      listedDate: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];

  void _onItemTapped(int index) {
    // Only update the index if we're staying on this page
    if (index == 0) {
      setState(() {
        _selectedIndex = index;
      });
    } else if (index == 1) {
      // Navigate to My Purchases page
      Navigator.push(
        context,
        DarkPageRoute(page: const MyPurchasesPage()),
      );
    } else if (index == 2) {
      // Navigate to My Wallet page
      Navigator.push(
        context,
        DarkPageRoute(page: const MyWalletPage()),
      );
    } else if (index == 3) {
      // Navigate to My Profile page
      Navigator.push(
        context,
        DarkPageRoute(page: const MyProfilePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.deepSlateGray,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.mutedTeal.withAlpha(100)),
          ),
          child: TextField(
            controller: _searchController,
            style: TextStyle(color: AppColors.coolGray), // Make text visible
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              hintText: 'Search for items...',
              hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(128)),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: const Icon(Icons.search, color: AppColors.mutedTeal),
                onPressed: () {
                  if (_searchController.text.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchResultsPage(
                          searchQuery: _searchController.text,
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchResultsPage(
                      searchQuery: value,
                    ),
                  ),
                );
              }
            },
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: AppColors.coolGray),
            onPressed: () {
              // Create sample cart items from the first few products
              final sampleCartItems = [
                CartItem(product: _products[0], quantity: 1),
                CartItem(product: _products[1], quantity: 2),
              ];
              
              // Navigate to checkout page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CheckoutPage(
                    cartItems: sampleCartItems,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.message_outlined, color: AppColors.coolGray),
            onPressed: () {
              // Navigate to messages page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MessagesPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Categories
              Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coolGray,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        color: AppColors.deepSlateGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.mutedTeal.withAlpha(100)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _categories[index].icon,
                            color: AppColors.mutedTeal,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _categories[index].name,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.coolGray,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              
              // Featured items
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Items',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coolGray,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all featured items
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.mutedTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 250,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsPage(product: product),
                          ),
                        );
                      },
                      child: Container(
                        width: 180,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: AppColors.deepSlateGray,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(50),
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              child: Image.network(
                                product.imageUrl,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.coolGray,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.coolGray.withAlpha(179),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RM ${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.mutedTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.star, size: 16, color: Colors.amber[700]),
                                          Text(
                                            ' ${product.rating}',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.coolGray,
                                            ),
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
                ),
              ),
              
              // Recently added
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Added',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.coolGray,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to all recent items
                    },
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: AppColors.mutedTeal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 3, // Show only 3 items
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailsPage(product: product),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.deepSlateGray,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(50),
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(12),
                              bottomLeft: Radius.circular(12),
                            ),
                            child: Image.network(
                              product.imageUrl,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: AppColors.coolGray,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    product.description,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.coolGray.withAlpha(179),
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'RM ${product.price.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: AppColors.mutedTeal,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Icon(Icons.access_time, size: 14, color: AppColors.coolGray.withAlpha(179)),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${DateTime.now().difference(product.listedDate).inDays}d ago',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppColors.coolGray.withAlpha(179),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
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
}
