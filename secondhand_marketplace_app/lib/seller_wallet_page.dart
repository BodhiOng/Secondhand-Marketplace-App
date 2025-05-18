import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'seller_listing_page.dart';
import 'seller_reviews_page.dart';
import 'seller_profile_page.dart';
import 'utils/page_transitions.dart';

class SellerWalletPage extends StatefulWidget {
  const SellerWalletPage({super.key});

  @override
  State<SellerWalletPage> createState() => _SellerWalletPageState();
}

class _SellerWalletPageState extends State<SellerWalletPage> {
  int _selectedIndex = 2; // Set to 2 for Wallet tab
  double _balance = 0.0; // Will be fetched from Firestore
  bool _isLoading = true;
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _uid = '';
  
  // Transaction history
  List<Map<String, dynamic>> _transactions = [];
  bool _isLoadingTransactions = true;
  
  // Helper methods for showing messages safely
  void _showSuccessMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
  

  @override
  void initState() {
    super.initState();
    _fetchWalletData();
  }
  
  // Fetch wallet data and transaction history from Firestore
  Future<void> _fetchWalletData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _isLoadingTransactions = false;
        });
        return;
      }

      _uid = currentUser.uid;
      
      // Fetch user wallet balance
      final DocumentSnapshot userDoc = 
          await _firestore.collection('users').doc(_uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _balance = (userData['walletBalance'] ?? 0.0).toDouble();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
      
      // Fetch transaction history
      await _fetchTransactionHistory();
      
    } catch (e) {
      debugPrint('Error fetching wallet data: $e');
      setState(() {
        _isLoading = false;
        _isLoadingTransactions = false;
      });
    }
  }
  
  // Fetch transaction history from Firestore
  Future<void> _fetchTransactionHistory() async {
    try {
      setState(() {
        _isLoadingTransactions = true;
      });
      
      final QuerySnapshot transactionSnapshot = await _firestore
          .collection('walletTransactions')
          .where('userId', isEqualTo: _uid)
          .orderBy('timestamp', descending: true)
          .get();
          
      List<Map<String, dynamic>> transactions = [];
      
      for (var doc in transactionSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        // Convert Firestore data to app format
        transactions.add({
          'id': doc.id,
          'type': data['type'] ?? '',
          'description': data['description'] ?? '',
          'amount': _getTransactionAmount(data['type'] as String, (data['amount'] ?? 0).toDouble()),
          'date': (data['timestamp'] as Timestamp).toDate(),
          'status': data['status'] ?? 'Completed',
          'relatedOrderId': data['relatedOrderId'],
        });
      }
      
      setState(() {
        _transactions = transactions;
        _isLoadingTransactions = false;
      });
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
      setState(() {
        _isLoadingTransactions = false;
      });
    }
  }
  
  // Helper to determine transaction amount sign based on type
  double _getTransactionAmount(String type, double amount) {
    switch (type) {
      case 'Deposit':
      case 'Sale':
        return amount.abs(); // Positive
      case 'Withdrawal':
      case 'Purchase':
        return -amount.abs(); // Negative
      default:
        return amount;
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
      case 1: // Navigate to Reviews
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerReviewsPage()),
        );
        break;
      case 2: // Already on Wallet page
        setState(() {
          _selectedIndex = index;
        });
        break;
      case 3: // Navigate to Profile
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerProfilePage()),
        );
        break;
    }
  }

  // Show top-up dialog
  void _showTopUpDialog() {
    final TextEditingController amountController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String selectedMethod = 'Credit Card';
    bool isProcessing = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.deepSlateGray,
              title: Text(
                'Top Up Wallet',
                style: TextStyle(color: AppColors.coolGray),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount field
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppColors.coolGray),
                        decoration: InputDecoration(
                          labelText: 'Amount (RM)',
                          labelStyle: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.coolGray.withAlpha(179)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.coolGray.withAlpha(77)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.mutedTeal),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          errorStyle: TextStyle(color: Colors.red.shade300),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          
                          final double? amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid number';
                          }
                          
                          if (amount <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          
                          if (amount > 10000) {
                            return 'Maximum top-up amount is RM 10,000';
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Payment method selection
                      Text(
                        'Payment Method',
                        style: TextStyle(
                          color: AppColors.coolGray.withAlpha(179),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Credit Card option
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.credit_card, color: AppColors.coolGray),
                            const SizedBox(width: 8),
                            Text(
                              'Credit Card',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        value: 'Credit Card',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMethod = value!;
                          });
                        },
                        activeColor: AppColors.mutedTeal,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // Bank Transfer option
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.account_balance, color: AppColors.coolGray),
                            const SizedBox(width: 8),
                            Text(
                              'Bank Transfer',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        value: 'Bank Transfer',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMethod = value!;
                          });
                        },
                        activeColor: AppColors.mutedTeal,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // E-Wallet option
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: AppColors.coolGray),
                            const SizedBox(width: 8),
                            Text(
                              'E-Wallet',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        value: 'E-Wallet',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMethod = value!;
                          });
                        },
                        activeColor: AppColors.mutedTeal,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note about processing time
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.charcoalBlack.withAlpha(77),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.coolGray.withAlpha(51),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.coolGray.withAlpha(179),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Top-ups are usually processed instantly, but may take up to 24 hours depending on your payment method.',
                                style: TextStyle(
                                  color: AppColors.coolGray.withAlpha(179),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isProcessing
                          ? AppColors.coolGray.withAlpha(128)
                          : AppColors.coolGray,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            // Show processing state
                            setDialogState(() {
                              isProcessing = true;
                            });
                            
                            try {
                              // Get amount from controller
                              final double amount = double.parse(amountController.text);
                              
                              // Simulate network delay
                              await Future.delayed(const Duration(seconds: 2));
                              
                              // Add to wallet balance in Firestore
                              await _firestore.collection('users').doc(_uid).update({
                                'walletBalance': FieldValue.increment(amount),
                              });
                              
                              // Record transaction
                              await _firestore.collection('walletTransactions').add({
                                'userId': _uid,
                                'type': 'Deposit',
                                'description': 'Top-up via $selectedMethod',
                                'amount': amount,
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': 'Completed',
                              });
                              
                              // Store amount before closing dialog
                              final successAmount = amount;
                              
                              // Close the dialog first
                              Navigator.pop(dialogContext);
                              
                              // Then handle the UI updates if still mounted
                              if (mounted) {
                                // Show success message
                                _showSuccessMessage('Successfully added RM ${successAmount.toStringAsFixed(2)} to your wallet');
                                
                                // Refresh wallet data
                                _fetchWalletData();
                              }
                            } catch (e) {
                              // Reset processing state
                              setDialogState(() {
                                isProcessing = false;
                              });
                              
                              // Show error message
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mutedTeal,
                    disabledBackgroundColor: AppColors.mutedTeal.withAlpha(128),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Show withdraw dialog
  void _showWithdrawDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController accountController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    String selectedMethod = 'Bank Transfer';
    bool isProcessing = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: AppColors.deepSlateGray,
              title: Text(
                'Withdraw Funds',
                style: TextStyle(color: AppColors.coolGray),
              ),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Current balance display
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.charcoalBlack.withAlpha(77),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.coolGray.withAlpha(51),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available Balance',
                              style: TextStyle(
                                color: AppColors.coolGray.withAlpha(179),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'RM ${_balance.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.coolGray,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Amount field
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: AppColors.coolGray),
                        decoration: InputDecoration(
                          labelText: 'Withdrawal Amount (RM)',
                          labelStyle: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                          prefixIcon: Icon(Icons.attach_money, color: AppColors.coolGray.withAlpha(179)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.coolGray.withAlpha(77)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.mutedTeal),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          errorStyle: TextStyle(color: Colors.red.shade300),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          
                          final double? amount = double.tryParse(value);
                          if (amount == null) {
                            return 'Please enter a valid number';
                          }
                          
                          if (amount <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          
                          if (amount > _balance) {
                            return 'Insufficient balance';
                          }
                          
                          if (amount < 10) {
                            return 'Minimum withdrawal amount is RM 10';
                          }
                          
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Withdrawal method selection
                      Text(
                        'Withdrawal Method',
                        style: TextStyle(
                          color: AppColors.coolGray.withAlpha(179),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Bank Transfer option
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.account_balance, color: AppColors.coolGray),
                            const SizedBox(width: 8),
                            Text(
                              'Bank Transfer',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        value: 'Bank Transfer',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMethod = value!;
                          });
                        },
                        activeColor: AppColors.mutedTeal,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      // E-Wallet option
                      RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(Icons.account_balance_wallet, color: AppColors.coolGray),
                            const SizedBox(width: 8),
                            Text(
                              'E-Wallet',
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        value: 'E-Wallet',
                        groupValue: selectedMethod,
                        onChanged: (value) {
                          setDialogState(() {
                            selectedMethod = value!;
                          });
                        },
                        activeColor: AppColors.mutedTeal,
                        contentPadding: EdgeInsets.zero,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Account field
                      TextFormField(
                        controller: accountController,
                        style: TextStyle(color: AppColors.coolGray),
                        decoration: InputDecoration(
                          labelText: selectedMethod == 'Bank Transfer' 
                              ? 'Bank Account Number' 
                              : 'E-Wallet Account',
                          labelStyle: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                          prefixIcon: Icon(
                            selectedMethod == 'Bank Transfer' 
                                ? Icons.account_balance 
                                : Icons.account_balance_wallet,
                            color: AppColors.coolGray.withAlpha(179),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.coolGray.withAlpha(77)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppColors.mutedTeal),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.red),
                          ),
                          errorStyle: TextStyle(color: Colors.red.shade300),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return selectedMethod == 'Bank Transfer'
                                ? 'Please enter your bank account number'
                                : 'Please enter your e-wallet account';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note about processing time
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.charcoalBlack.withAlpha(77),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.coolGray.withAlpha(51),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppColors.coolGray.withAlpha(179),
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Withdrawals typically take 1-3 business days to process.',
                                style: TextStyle(
                                  color: AppColors.coolGray.withAlpha(179),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isProcessing
                      ? null
                      : () {
                          Navigator.pop(dialogContext);
                        },
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      color: isProcessing
                          ? AppColors.coolGray.withAlpha(128)
                          : AppColors.coolGray,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: isProcessing
                      ? null
                      : () async {
                          if (formKey.currentState!.validate()) {
                            // Show processing state
                            setDialogState(() {
                              isProcessing = true;
                            });
                            
                            try {
                              // Get amount from controller
                              final double amount = double.parse(amountController.text);
                              
                              // Simulate network delay
                              await Future.delayed(const Duration(seconds: 2));
                              
                              // Subtract from wallet balance in Firestore
                              await _firestore.collection('users').doc(_uid).update({
                                'walletBalance': FieldValue.increment(-amount),
                              });
                              
                              // Record transaction
                              await _firestore.collection('walletTransactions').add({
                                'userId': _uid,
                                'type': 'Withdrawal',
                                'description': 'Withdrawal via $selectedMethod to ${accountController.text}',
                                'amount': amount,
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': 'Pending',
                              });
                              
                              // Store amount before closing dialog
                              final withdrawAmount = amount;
                              
                              // Close the dialog first
                              Navigator.pop(dialogContext);
                              
                              // Then handle the UI updates if still mounted
                              if (mounted) {
                                // Show success message
                                _showSuccessMessage('Withdrawal request of RM ${withdrawAmount.toStringAsFixed(2)} has been submitted');
                                
                                // Refresh wallet data
                                _fetchWalletData();
                              }
                            } catch (e) {
                              // Reset processing state
                              setDialogState(() {
                                isProcessing = false;
                              });
                              
                              // Show error message
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.mutedTeal,
                    disabledBackgroundColor: AppColors.mutedTeal.withAlpha(128),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
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
  
  // Get appropriate icon for transaction type
  IconData _getTransactionIcon(String type) {
    switch (type) {
      case 'Deposit':
        return Icons.add_circle_outline;
      case 'Withdrawal':
        return Icons.remove_circle_outline;
      case 'Sale':
        return Icons.shopping_bag_outlined;
      case 'Purchase':
        return Icons.shopping_cart_outlined;
      default:
        return Icons.swap_horiz;
    }
  }
  
  // Get color based on transaction status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Completed':
        return Colors.green;
      case 'Pending':
        return Colors.amber;
      case 'Failed':
        return Colors.red;
      default:
        return AppColors.coolGray;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'My Wallet',
          style: TextStyle(color: AppColors.coolGray),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Balance card
                    Card(
                      color: AppColors.deepSlateGray,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            // Wallet icon
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppColors.mutedTeal.withValues(alpha: 50),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.account_balance_wallet,
                                color: AppColors.mutedTeal,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Balance text
                            Text(
                              'Your Current Balance',
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.coolGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'RM ${_balance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 24),
                            // Action buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Top up button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showTopUpDialog,
                                    icon: const Icon(Icons.add, color: Colors.white),
                                    label: const Text(
                                      'Top Up',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.mutedTeal,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Withdraw button
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _showWithdrawDialog,
                                    icon: const Icon(Icons.arrow_upward, color: Colors.white),
                                    label: const Text(
                                      'Withdraw',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.warmCoral,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Transaction history section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Transaction History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.coolGray,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh, color: AppColors.coolGray),
                          onPressed: _fetchTransactionHistory,
                          tooltip: 'Refresh transactions',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _isLoadingTransactions
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _transactions.isEmpty
                        ? Card(
                            color: AppColors.deepSlateGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      color: AppColors.coolGray.withValues(alpha: 150),
                                      size: 48,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No transactions yet',
                                      style: TextStyle(
                                        color: AppColors.coolGray,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : Card(
                            color: AppColors.deepSlateGray,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _transactions.length,
                              separatorBuilder: (context, index) => Divider(
                                color: AppColors.coolGray.withValues(alpha: 50),
                                height: 1,
                              ),
                              itemBuilder: (context, index) {
                                final transaction = _transactions[index];
                                final amount = transaction['amount'] as double;
                                final isPositive = amount >= 0;
                                final status = transaction['status'] as String;
                                
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: isPositive
                                        ? AppColors.mutedTeal.withValues(alpha: 51)
                                        : AppColors.warmCoral.withValues(alpha: 51),
                                    child: Icon(
                                      _getTransactionIcon(transaction['type'] as String),
                                      color: isPositive
                                          ? AppColors.mutedTeal
                                          : AppColors.warmCoral,
                                    ),
                                  ),
                                  title: Row(
                                    children: [
                                      Text(
                                        transaction['type'] as String,
                                        style: TextStyle(
                                          color: AppColors.coolGray,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (status != 'Completed')
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(status).withValues(alpha: 50),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              color: _getStatusColor(status),
                                              fontSize: 10,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  subtitle: Text(
                                    transaction['description'] as String,
                                    style: TextStyle(color: AppColors.coolGray.withValues(alpha: 150)),
                                  ),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isPositive ? '+' : ''}RM ${amount.abs().toStringAsFixed(2)}',
                                        style: TextStyle(
                                          color: isPositive ? AppColors.mutedTeal : AppColors.warmCoral,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _formatDate(transaction['date'] as DateTime),
                                        style: TextStyle(
                                          color: AppColors.coolGray.withValues(alpha: 150),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: transaction['relatedOrderId'] != null
                                    ? () {
                                        // Navigate to order details if there's a related order
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Order ID: ${transaction['relatedOrderId']}'),
                                              backgroundColor: AppColors.deepSlateGray,
                                            ),
                                          );
                                        }
                                      }
                                    : null,
                                );
                              },
                            ),
                          ),
                  ],
                ),
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
