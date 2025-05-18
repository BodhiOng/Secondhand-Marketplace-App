import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'seller_listing_page.dart';
import 'seller_wallet_page.dart';
import 'seller_profile_page.dart';
import 'utils/page_transitions.dart';
import 'utils/image_utils.dart';

class SellerReviewsPage extends StatefulWidget {
  const SellerReviewsPage({super.key});

  @override
  State<SellerReviewsPage> createState() => _SellerReviewsPageState();
}

class _SellerReviewsPageState extends State<SellerReviewsPage> {
  final int _selectedIndex = 1; // Set to 1 for Reviews tab
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _sellerId;
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  double _averageRating = 0.0;
  int _totalReviews = 0;

  @override
  void initState() {
    super.initState();
    _sellerId = _auth.currentUser?.uid;
    _fetchReviews();
  }

  // Fetch reviews for the current seller
  Future<void> _fetchReviews() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (_sellerId == null) {
        throw Exception('User not authenticated');
      }

      // Get reviews where the current seller's products are being reviewed
      final QuerySnapshot reviewsSnapshot =
          await _firestore
              .collection('reviews')
              .where('sellerId', isEqualTo: _sellerId)
              .orderBy('date', descending: true)
              .get();

      List<Map<String, dynamic>> reviews = [];
      double ratingSum = 0;
      int reviewCount = 0;

      // Process reviews where the seller's products are being reviewed
      for (var doc in reviewsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Get reviewer info
        String reviewerName = 'Anonymous User';
        String reviewerPhotoUrl = '';

        try {
          final reviewerDoc =
              await _firestore
                  .collection('users')
                  .doc(data['reviewerId'] as String)
                  .get();

          if (reviewerDoc.exists) {
            final reviewerData = reviewerDoc.data() as Map<String, dynamic>;
            reviewerName = reviewerData['username'] ?? 'Anonymous User';
            reviewerPhotoUrl = reviewerData['profileImageUrl'] ?? '';
          }
        } catch (e) {
          debugPrint('Error fetching reviewer info: $e');
        }

        // Get product info
        String productName = 'Unknown Product';
        String productImageUrl = '';
        double productPrice = 0.0;
        String productCategory = '';

        try {
          final productDoc =
              await _firestore
                  .collection('products')
                  .doc(data['productId'] as String)
                  .get();

          if (productDoc.exists) {
            final productData = productDoc.data() as Map<String, dynamic>;
            productName = productData['name'] ?? 'Unknown Product';
            productImageUrl = productData['imageUrl'] ?? '';
            productPrice = (productData['price'] ?? 0.0).toDouble();
            productCategory = productData['category'] ?? '';
          } else {
            // Try to get product info from orders if product no longer exists
            if (data['orderId'] != null) {
              final orderDoc =
                  await _firestore
                      .collection('orders')
                      .doc(data['orderId'] as String)
                      .get();

              if (orderDoc.exists) {
                final orderData = orderDoc.data() as Map<String, dynamic>;
                productPrice = (orderData['price'] ?? 0.0).toDouble();
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching product info: $e');
        }

        // Add to reviews list
        reviews.add({
          'id': data['id'] ?? doc.id,
          'rating': (data['rating'] ?? 0.0).toDouble(),
          'text': data['text'] ?? '',
          'date': data['date'] != null ? (data['date'] as Timestamp).toDate() : DateTime.now(),
          'reviewerName': reviewerName,
          'reviewerPhotoUrl': reviewerPhotoUrl,
          'productName': productName,
          'productImageUrl': productImageUrl,
          'productPrice': productPrice,
          'productCategory': productCategory
        });

        // Update rating sum and count
        ratingSum += (data['rating'] ?? 0.0).toDouble();
        reviewCount++;
      }

      // Calculate average rating for all reviews
      double avgRating = reviewCount > 0 ? ratingSum / reviewCount : 0.0;

      setState(() {
        _reviews = reviews;
        _averageRating = avgRating;
        _totalReviews = reviewCount;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching reviews: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0: // Navigate to My Listings
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerListingPage()),
        );
        break;
      case 1: // Already on Reviews
        break;
      case 2: // Navigate to Wallet
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerWalletPage()),
        );
        break;
      case 3: // Navigate to Profile
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerProfilePage()),
        );
        break;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        if (difference.inMinutes < 1) {
          return 'Just now';
        } else {
          return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
        }
      } else {
        return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
      }
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks ${weeks == 1 ? 'week' : 'weeks'} ago';
    } else {
      final DateFormat formatter = DateFormat('MMM d, yyyy');
      return formatter.format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: const Text('Reviews', style: TextStyle(color: Colors.white)),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppColors.mutedTeal),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Rating summary
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: AppColors.deepSlateGray,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Average rating
                              Column(
                                children: [
                                  Text(
                                    _averageRating.toStringAsFixed(1),
                                    style: const TextStyle(
                                      color: AppColors.softLemonYellow,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Star rating
                                  Row(
                                    children: List.generate(5, (index) {
                                      return Icon(
                                        index < _averageRating.floor()
                                            ? Icons.star
                                            : index < _averageRating.ceil() &&
                                                index >= _averageRating.floor()
                                            ? Icons.star_half
                                            : Icons.star_border,
                                        color: AppColors.softLemonYellow,
                                        size: 20,
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$_totalReviews ${_totalReviews == 1 ? 'review' : 'reviews'}',
                                    style: TextStyle(
                                      color: AppColors.coolGray,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Reviews list
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Text(
                        'All Reviews',
                        style: TextStyle(
                          color: AppColors.coolGray,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _reviews.isEmpty
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star_border,
                                  size: 64,
                                  color: AppColors.coolGray.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No reviews yet',
                                  style: TextStyle(
                                    color: AppColors.coolGray,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'When customers review your products, they will appear here.',
                                  style: TextStyle(
                                    color: AppColors.coolGray.withValues(
                                      alpha: 0.7,
                                    ),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        )
                        : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _reviews.length,
                          itemBuilder: (context, index) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              color: AppColors.deepSlateGray,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Reviewer/Seller info
                                    Row(
                                      children: [
                                        // User photo
                                        CircleAvatar(
                                          radius: 16,
                                          backgroundColor: AppColors.mutedTeal
                                              .withValues(alpha: 0.2),
                                          backgroundImage:
                                              review['reviewerPhotoUrl'] != null &&
                                                      (review['reviewerPhotoUrl'] as String).isNotEmpty
                                                  ? NetworkImage(
                                                      review['reviewerPhotoUrl'] as String,
                                                    )
                                                  : null,
                                          child:
                                              (review['reviewerPhotoUrl'] == null || 
                                                  (review['reviewerPhotoUrl'] as String).isEmpty)
                                                  ? const Icon(
                                                      Icons.person,
                                                      size: 16,
                                                      color: AppColors.mutedTeal,
                                                    )
                                                  : null,
                                        ),
                                        const SizedBox(width: 12),
                                        // User name
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              review['reviewerName'] as String,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              _formatDate(
                                                review['date'] as DateTime,
                                              ),
                                              style: TextStyle(
                                                color: AppColors.coolGray
                                                    .withValues(alpha: 0.7),
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        // Review type badge
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // Rating
                                    Row(
                                      children: [
                                        ...List.generate(5, (index) {
                                          return Icon(
                                            index <
                                                    (review['rating'] as double)
                                                        .floor()
                                                ? Icons.star
                                                : index <
                                                        (review['rating']
                                                                as double)
                                                            .ceil() &&
                                                    index >=
                                                        (review['rating']
                                                                as double)
                                                            .floor()
                                                ? Icons.star_half
                                                : Icons.star_border,
                                            color: AppColors.softLemonYellow,
                                            size: 16,
                                          );
                                        }),
                                        const SizedBox(width: 8),
                                        Text(
                                          (review['rating'] as double)
                                              .toStringAsFixed(1),
                                          style: const TextStyle(
                                            color: AppColors.softLemonYellow,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Review text
                                    if (review['text'] != null &&
                                        (review['text'] as String)
                                            .isNotEmpty) ...[
                                      const SizedBox(height: 12),
                                      Text(
                                        review['text'] as String,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                    // Product info
                                    const SizedBox(height: 16),
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: AppColors.charcoalBlack,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          // Product image
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              6,
                                            ),
                                            child: SizedBox(
                                              width: 48,
                                              height: 48,
                                              child:
                                                  review['productImageUrl'] !=
                                                              null &&
                                                          (review['productImageUrl']
                                                                  as String)
                                                              .isNotEmpty
                                                      ? ImageUtils.isBase64Image(
                                                            review['productImageUrl']
                                                                as String,
                                                          )
                                                          ? ImageUtils.base64ToImage(
                                                            review['productImageUrl']
                                                                as String,
                                                            fit: BoxFit.cover,
                                                            errorWidget: Container(
                                                              color:
                                                                  AppColors
                                                                      .deepSlateGray,
                                                              child: Icon(
                                                                Icons
                                                                    .image_not_supported,
                                                                color: AppColors
                                                                    .coolGray
                                                                    .withValues(
                                                                      alpha:
                                                                          0.6,
                                                                    ),
                                                                size: 24,
                                                              ),
                                                            ),
                                                          )
                                                          : Image.network(
                                                            review['productImageUrl']
                                                                as String,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (
                                                              context,
                                                              error,
                                                              stackTrace,
                                                            ) {
                                                              return Container(
                                                                color:
                                                                    AppColors
                                                                        .deepSlateGray,
                                                                child: Icon(
                                                                  Icons
                                                                      .image_not_supported,
                                                                  color: AppColors
                                                                      .coolGray
                                                                      .withValues(
                                                                        alpha:
                                                                            0.6,
                                                                      ),
                                                                  size: 24,
                                                                ),
                                                              );
                                                            },
                                                          )
                                                      : Container(
                                                        color:
                                                            AppColors
                                                                .deepSlateGray,
                                                        child: Icon(
                                                          Icons
                                                              .image_not_supported,
                                                          color: AppColors
                                                              .coolGray
                                                              .withValues(
                                                                alpha: 0.6,
                                                              ),
                                                          size: 24,
                                                        ),
                                                      ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          // Product name and details
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  review['productName']
                                                      as String,
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                // Price and category
                                                Row(
                                                  children: [
                                                    if ((review['productPrice'] ??
                                                            0.0) >
                                                        0)
                                                      Text(
                                                        'RM ${(review['productPrice'] as double).toStringAsFixed(2)}',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .coolGray
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    if ((review['productPrice'] ??
                                                                0.0) >
                                                            0 &&
                                                        review['productCategory'] !=
                                                            null &&
                                                        (review['productCategory']
                                                                as String)
                                                            .isNotEmpty)
                                                      Text(
                                                        ' • ',
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .coolGray
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    if (review['productCategory'] !=
                                                            null &&
                                                        (review['productCategory']
                                                                as String)
                                                            .isNotEmpty)
                                                      Text(
                                                        review['productCategory']
                                                            as String,
                                                        style: TextStyle(
                                                          color: AppColors
                                                              .coolGray
                                                              .withValues(
                                                                alpha: 0.7,
                                                              ),
                                                          fontSize: 12,
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
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    // Add bottom padding
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'My Listings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star_outline),
            label: 'Reviews',
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
