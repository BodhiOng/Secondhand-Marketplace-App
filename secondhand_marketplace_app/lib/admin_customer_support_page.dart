// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'admin_profile_page.dart';
import 'admin_user_management_page.dart';
import 'admin_product_moderation_page.dart';
import 'admin_order_management_page.dart';
import 'utils/page_transitions.dart';
import 'utils/image_utils.dart';

class AdminCustomerSupportPage extends StatefulWidget {
  const AdminCustomerSupportPage({super.key});

  @override
  State<AdminCustomerSupportPage> createState() =>
      _AdminCustomerSupportPageState();
}

class _AdminCustomerSupportPageState extends State<AdminCustomerSupportPage> {
  final int _selectedIndex = 3; // 0 for User Management, 1 for Product Moderation, 2 for Order Moderation, 3 for Customer Support, 4 for Profile
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _supportRequests = [];
  List<Map<String, dynamic>> _filteredRequests = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedStatus = 'All';

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSupportRequests();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fetch all support requests from Firestore
  Future<void> _fetchSupportRequests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final QuerySnapshot requestsSnapshot =
          await _firestore
              .collection('helpCenterRequests')
              .orderBy('createdAt', descending: true)
              .get();

      List<Map<String, dynamic>> requests = [];

      for (var doc in requestsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore data to app format
        requests.add({
          'id': doc.id,
          'userId': data['userId'] as String? ?? '',
          'username': data['username'] as String? ?? 'Anonymous User',
          'email': data['email'] as String? ?? '',
          'subject': data['subject'] as String? ?? 'No Subject',
          'message': data['message'] as String? ?? '',
          'status': data['status'] as String? ?? 'Pending',
          'userRole': data['userRole'] as String? ?? '',
          'createdAt': (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'attachment': data['attachment'] as String? ?? '',
        });
      }

      setState(() {
        _supportRequests = requests;
        _filterRequests();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching support requests: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Filter support requests based on search query and status
  void _filterRequests() {
    setState(() {
      if (_searchQuery.isEmpty && _selectedStatus == 'All') {
        _filteredRequests = List.from(_supportRequests);
      } else {
        _filteredRequests = _supportRequests.where((request) {
          // Filter by status
          bool statusMatch = _selectedStatus == 'All' ||
              request['status'].toString().toLowerCase() ==
                  _selectedStatus.toLowerCase();

          // Filter by search query (username, email, subject, or message)
          bool searchMatch = _searchQuery.isEmpty ||
              request['username'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
              request['email'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
              request['subject'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
              request['message'].toString().toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );

          return statusMatch && searchMatch;
        }).toList();
      }
    });
  }

  // Handle bottom navigation
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(
            page: const AdminUserManagementPage(),
          ),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(
            page: const AdminProductModerationPage(),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(
            page: const AdminOrderModerationPage(),
          ),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(
            page: const AdminProfilePage(),
          ),
        );
        break;
    }
  }

  // Format date for display
  String _formatDate(DateTime date) {
    return DateFormat("MMM d, yyyy 'at' h:mm a").format(date);
  }

  // Create a detail row for the support request details dialog
  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.coolGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Show support request details dialog
  void _showRequestDetailsDialog(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          request['subject'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Status', request['status']),
              _detailRow('From', request['username']),
              _detailRow('Email', request['email']),
              _detailRow('User Role', request['userRole']),
              _detailRow('Date', _formatDate(request['createdAt'])),
              const SizedBox(height: 16),
              const Text(
                'Message:',
                style: TextStyle(
                  color: AppColors.coolGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: AppColors.deepSlateGray.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(
                    color: AppColors.coolGray.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  request['message'],
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              
              // Display attachment if available
              if (request['attachment'] != null && request['attachment'].toString().isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Attachment:',
                      style: TextStyle(
                        color: AppColors.coolGray,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(
                          color: AppColors.coolGray.withValues(alpha: 0.3),
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: ImageUtils.base64ToImage(
                        request['attachment'],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.mutedTeal),
            ),
          ),
          if (request['status'] == 'Pending')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mutedTeal,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request['id'], 'Resolved');
              },
              child: const Text('Mark as Resolved'),
            )
          else if (request['status'] == 'Resolved')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              onPressed: () {
                Navigator.pop(context);
                _updateRequestStatus(request['id'], 'Pending');
              },
              child: const Text('Mark as Pending'),
            ),
        ],
      ),
    );
  }

  // Update support request status
  Future<void> _updateRequestStatus(String requestId, String newStatus) async {
    try {
      await _firestore.collection('helpCenterRequests').doc(requestId).update({
        'status': newStatus,
      });

      // Refresh the list
      _fetchSupportRequests();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request marked as $newStatus'),
          backgroundColor: AppColors.mutedTeal,
        ),
      );
    } catch (e) {
      debugPrint('Error updating request status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update request status'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build status badge for support request
  Widget _buildStatusBadge(String status) {
    Color badgeColor;
    Color textColor = Colors.white;

    switch (status.toLowerCase()) {
      case 'pending':
        badgeColor = Colors.orange;
        break;
      case 'resolved':
        badgeColor = AppColors.mutedTeal;
        break;
      default:
        badgeColor = AppColors.coolGray;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontSize: 12.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Build status filter chip
  Widget _buildStatusFilterChip(String status) {
    final isSelected = _selectedStatus == status;

    return FilterChip(
      selected: isSelected,
      selectedColor: AppColors.mutedTeal.withValues(alpha: 0.8),
      backgroundColor: AppColors.deepSlateGray,
      checkmarkColor: Colors.white,
      label: Text(
        status,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.coolGray,
        ),
      ),
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
          _filterRequests();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: const Text(
          'Customer Support',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchSupportRequests,
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search by username, email, subject, or message',
                hintStyle: TextStyle(color: AppColors.coolGray),
                prefixIcon: Icon(Icons.search, color: AppColors.coolGray),
                filled: true,
                fillColor: AppColors.deepSlateGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.coolGray),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _filterRequests();
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _filterRequests();
                });
              },
            ),
          ),

          // Status filter chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                _buildStatusFilterChip('All'),
                _buildStatusFilterChip('Pending'),
                _buildStatusFilterChip('Resolved'),
              ],
            ),
          ),

          // Support requests list
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.mutedTeal,
                    ),
                  )
                : _filteredRequests.isEmpty
                    ? Center(
                        child: Text(
                          'No support requests found',
                          style: TextStyle(
                            color: AppColors.coolGray,
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: _filteredRequests.length,
                        itemBuilder: (context, index) {
                          final request = _filteredRequests[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              vertical: 4.0,
                              horizontal: 8.0,
                            ),
                            color: AppColors.deepSlateGray,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      request['subject'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildStatusBadge(request['status']),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Text(
                                        request['username'],
                                        style: TextStyle(
                                          color: AppColors.mutedTeal,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        '(${request['userRole']})',
                                        style: TextStyle(
                                          color: AppColors.coolGray,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    request['message'],
                                    style: TextStyle(
                                      color: AppColors.coolGray,
                                      fontSize: 12,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  
                                  // Show attachment indicator if available
                                  if (request['attachment'] != null && request['attachment'].toString().isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.image,
                                            size: 14,
                                            color: AppColors.mutedTeal,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Has attachment',
                                            style: TextStyle(
                                              color: AppColors.mutedTeal,
                                              fontSize: 12,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      _formatDate(request['createdAt']),
                                      style: TextStyle(
                                        color: AppColors.coolGray,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () => _showRequestDetailsDialog(request),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.deepSlateGray,
        selectedItemColor: AppColors.softLemonYellow,
        unselectedItemColor: AppColors.coolGray,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_outlined),
            activeIcon: Icon(Icons.receipt),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent_outlined),
            activeIcon: Icon(Icons.support_agent),
            label: 'Support',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}