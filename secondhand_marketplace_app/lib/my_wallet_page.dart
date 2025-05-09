import 'package:flutter/material.dart';
import 'constants.dart';
import 'home_page.dart';
import 'my_purchases_page.dart';
import 'utils/page_transitions.dart';

class MyWalletPage extends StatefulWidget {
  const MyWalletPage({super.key});

  @override
  State<MyWalletPage> createState() => _MyWalletPageState();
}

class _MyWalletPageState extends State<MyWalletPage> {
  int _selectedIndex = 2; // Set to 2 for Wallet tab
  double _balance = 1250.75; // Sample balance
  
  // Payment methods
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Credit Card',
      'icon': Icons.credit_card,
      'lastDigits': '4242',
      'isDefault': true,
    },
    {
      'name': 'PayPal',
      'icon': Icons.account_balance_wallet,
      'email': 'user@example.com',
      'isDefault': false,
    },
    {
      'name': 'Bank Account',
      'icon': Icons.account_balance,
      'accountNumber': '****6789',
      'isDefault': false,
    },
  ];
  
  // Payment method types for adding new methods
  final List<Map<String, dynamic>> _paymentMethodTypes = [
    {
      'name': 'Credit Card',
      'icon': Icons.credit_card,
    },
    {
      'name': 'PayPal',
      'icon': Icons.account_balance_wallet,
    },
    {
      'name': 'Bank Account',
      'icon': Icons.account_balance,
    },
  ];

  // Transaction history
  final List<Map<String, dynamic>> _transactions = [
    {
      'type': 'Purchase',
      'description': 'iPhone 13 Pro',
      'amount': -699.99,
      'date': DateTime.now().subtract(const Duration(days: 2)),
    },
    {
      'type': 'Top-up',
      'description': 'Added via Credit Card',
      'amount': 1000.00,
      'date': DateTime.now().subtract(const Duration(days: 5)),
    },
    {
      'type': 'Refund',
      'description': 'Cancelled Order: Leather Sofa',
      'amount': 450.00,
      'date': DateTime.now().subtract(const Duration(days: 7)),
    },
    {
      'type': 'Withdrawal',
      'description': 'To Bank Account',
      'amount': -200.00,
      'date': DateTime.now().subtract(const Duration(days: 10)),
    },
    {
      'type': 'Purchase',
      'description': 'Nike Air Jordan',
      'amount': -180.00,
      'date': DateTime.now().subtract(const Duration(days: 12)),
    },
  ];

  void _onItemTapped(int index) {
    if (index == 0) {
      // Navigate directly to HomePage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage(title: 'Secondhand Marketplace')),
      );
    } else if (index == 1) {
      // Navigate to My Purchases page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyPurchasesPage()),
      );
    } else if (index == 2) {
      // Already on Wallet page, just update index
      setState(() {
        _selectedIndex = index;
      });
    } else {
      // For other tabs, just update the index for now
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  // Show top-up dialog
  void _showTopUpDialog() {
    final amountController = TextEditingController();
    String selectedMethod = _paymentMethods[0]['name'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'Top Up Balance',
          style: TextStyle(color: AppColors.coolGray),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to add:',
                style: TextStyle(color: AppColors.coolGray),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.coolGray),
                decoration: InputDecoration(
                  prefixText: r'$',
                  prefixStyle: TextStyle(color: AppColors.coolGray),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(150)),
                  filled: true,
                  fillColor: AppColors.charcoalBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.coolGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.mutedTeal),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Method:',
                style: TextStyle(color: AppColors.coolGray),
              ),
              const SizedBox(height: 8),
              // Payment method selector
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Column(
                    children: _paymentMethods.map((method) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(
                              method['icon'] as IconData,
                              color: AppColors.mutedTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              method['name'] as String,
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          method.containsKey('lastDigits')
                              ? 'Ending in ${method['lastDigits']}'
                              : method.containsKey('email')
                                  ? method['email'] as String
                                  : method['accountNumber'] as String,
                          style: TextStyle(
                            color: AppColors.coolGray.withAlpha(150),
                            fontSize: 12,
                          ),
                        ),
                        value: method['name'] as String,
                        groupValue: selectedMethod,
                        activeColor: AppColors.mutedTeal,
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedMethod = value!;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
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
              // Validate and process top-up
              final amountText = amountController.text.trim();
              if (amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter an amount'),
                    backgroundColor: AppColors.warmCoral,
                  ),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid amount'),
                    backgroundColor: AppColors.warmCoral,
                  ),
                );
                return;
              }

              // Add to balance
              setState(() {
                _balance += amount;
                _transactions.insert(0, {
                  'type': 'Top-up',
                  'description': 'Added via $selectedMethod',
                  'amount': amount,
                  'date': DateTime.now(),
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully added RM ${amount.toStringAsFixed(2)} to your wallet'),
                  backgroundColor: AppColors.mutedTeal,
                ),
              );
            },
            child: Text(
              'Add Funds',
              style: TextStyle(color: AppColors.mutedTeal),
            ),
          ),
        ],
      ),
    );
  }

  // Show withdrawal dialog
  void _showWithdrawDialog() {
    final amountController = TextEditingController();
    String selectedMethod = _paymentMethods[0]['name'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'Withdraw Funds',
          style: TextStyle(color: AppColors.coolGray),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Amount to withdraw:',
                style: TextStyle(color: AppColors.coolGray),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: AppColors.coolGray),
                decoration: InputDecoration(
                  prefixText: r'$',
                  prefixStyle: TextStyle(color: AppColors.coolGray),
                  hintText: '0.00',
                  hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(150)),
                  filled: true,
                  fillColor: AppColors.charcoalBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.coolGray),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.mutedTeal),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Withdraw to:',
                style: TextStyle(color: AppColors.coolGray),
              ),
              const SizedBox(height: 8),
              // Payment method selector
              StatefulBuilder(
                builder: (context, setStateDialog) {
                  return Column(
                    children: _paymentMethods.map((method) {
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            Icon(
                              method['icon'] as IconData,
                              color: AppColors.mutedTeal,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              method['name'] as String,
                              style: TextStyle(color: AppColors.coolGray),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          method.containsKey('lastDigits')
                              ? 'Ending in ${method['lastDigits']}'
                              : method.containsKey('email')
                                  ? method['email'] as String
                                  : method['accountNumber'] as String,
                          style: TextStyle(
                            color: AppColors.coolGray.withAlpha(150),
                            fontSize: 12,
                          ),
                        ),
                        value: method['name'] as String,
                        groupValue: selectedMethod,
                        activeColor: AppColors.mutedTeal,
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedMethod = value!;
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
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
              // Validate and process withdrawal
              final amountText = amountController.text.trim();
              if (amountText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter an amount'),
                    backgroundColor: AppColors.warmCoral,
                  ),
                );
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Please enter a valid amount'),
                    backgroundColor: AppColors.warmCoral,
                  ),
                );
                return;
              }

              if (amount > _balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Insufficient balance'),
                    backgroundColor: AppColors.warmCoral,
                  ),
                );
                return;
              }

              // Subtract from balance
              setState(() {
                _balance -= amount;
                _transactions.insert(0, {
                  'type': 'Withdrawal',
                  'description': 'To $selectedMethod',
                  'amount': -amount,
                  'date': DateTime.now(),
                });
              });

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Successfully withdrew RM ${amount.toStringAsFixed(2)} from your wallet'),
                  backgroundColor: AppColors.mutedTeal,
                ),
              );
            },
            child: Text(
              'Withdraw',
              style: TextStyle(color: AppColors.mutedTeal),
            ),
          ),
        ],
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
          'My Wallet',
          style: TextStyle(color: AppColors.coolGray),
        ),
      ),
      body: SingleChildScrollView(
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
                          color: AppColors.mutedTeal.withAlpha(50),
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
              // Payment methods section
              Text(
                'Payment Methods',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coolGray,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: AppColors.deepSlateGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _paymentMethods.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.coolGray.withAlpha(50),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final method = _paymentMethods[index];
                    return ListTile(
                      leading: Icon(
                        method['icon'] as IconData,
                        color: AppColors.mutedTeal,
                      ),
                      title: Text(
                        method['name'] as String,
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      subtitle: Text(
                        method.containsKey('lastDigits')
                            ? 'Ending in ${method['lastDigits']}'
                            : method.containsKey('email')
                                ? method['email'] as String
                                : method['accountNumber'] as String,
                        style: TextStyle(color: AppColors.coolGray.withAlpha(150)),
                      ),
                      trailing: method['isDefault'] as bool
                          ? Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.mutedTeal.withAlpha(50),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Default',
                                style: TextStyle(
                                  color: AppColors.mutedTeal,
                                  fontSize: 12,
                                ),
                              ),
                            )
                          : null,
                      onTap: () {
                        _showPaymentMethodOptions(method, index);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: _showAddPaymentMethodDialog,
                icon: Icon(Icons.add, color: AppColors.mutedTeal, size: 16),
                label: Text(
                  'Add Payment Method',
                  style: TextStyle(color: AppColors.mutedTeal),
                ),
              ),
              const SizedBox(height: 24),
              // Transaction history section
              Text(
                'Transaction History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.coolGray,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: AppColors.deepSlateGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  separatorBuilder: (context, index) => Divider(
                    color: AppColors.coolGray.withAlpha(50),
                    height: 1,
                  ),
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    final amount = transaction['amount'] as double;
                    final isPositive = amount > 0;
                    
                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: (isPositive ? AppColors.mutedTeal : AppColors.warmCoral).withAlpha(50),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPositive ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isPositive ? AppColors.mutedTeal : AppColors.warmCoral,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        transaction['type'] as String,
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      subtitle: Text(
                        transaction['description'] as String,
                        style: TextStyle(color: AppColors.coolGray.withAlpha(150)),
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
                              color: AppColors.coolGray.withAlpha(150),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
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
  
  // Helper method to format date
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  // Show payment method options
  void _showPaymentMethodOptions(Map<String, dynamic> method, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.deepSlateGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.info_outline,
                color: AppColors.mutedTeal,
              ),
              title: Text(
                'View Details',
                style: TextStyle(color: AppColors.coolGray),
              ),
              onTap: () {
                Navigator.pop(context);
                // In a real app, this would show detailed information
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Payment method details would be shown here'),
                    backgroundColor: AppColors.mutedTeal,
                  ),
                );
              },
            ),
            if (!(method['isDefault'] as bool))
              ListTile(
                leading: Icon(
                  Icons.check_circle_outline,
                  color: AppColors.mutedTeal,
                ),
                title: Text(
                  'Set as Default',
                  style: TextStyle(color: AppColors.coolGray),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _setDefaultPaymentMethod(index);
                },
              ),
            ListTile(
              leading: Icon(
                Icons.delete_outline,
                color: AppColors.warmCoral,
              ),
              title: Text(
                'Remove',
                style: TextStyle(color: AppColors.coolGray),
              ),
              onTap: () {
                Navigator.pop(context);
                _removePaymentMethod(index);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  // Set default payment method
  void _setDefaultPaymentMethod(int index) {
    setState(() {
      for (int i = 0; i < _paymentMethods.length; i++) {
        _paymentMethods[i]['isDefault'] = (i == index);
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_paymentMethods[index]['name']} set as default payment method'),
        backgroundColor: AppColors.mutedTeal,
      ),
    );
  }
  
  // Remove payment method
  void _removePaymentMethod(int index) {
    final methodName = _paymentMethods[index]['name'];
    final isDefault = _paymentMethods[index]['isDefault'] as bool;
    
    setState(() {
      _paymentMethods.removeAt(index);
      
      // If we removed the default method, set the first one as default
      if (isDefault && _paymentMethods.isNotEmpty) {
        _paymentMethods[0]['isDefault'] = true;
      }
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$methodName removed'),
        backgroundColor: AppColors.mutedTeal,
      ),
    );
  }
  
  // Show add payment method dialog
  void _showAddPaymentMethodDialog() {
    String selectedType = _paymentMethodTypes[0]['name'];
    final TextEditingController detailController = TextEditingController();
    String detailLabel = 'Card Number';
    String detailHint = 'XXXX XXXX XXXX XXXX';
    IconData detailIcon = Icons.credit_card;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          // Update detail fields based on selected type
          void updateDetailFields() {
            if (selectedType == 'Credit Card') {
              detailLabel = 'Card Number';
              detailHint = 'XXXX XXXX XXXX XXXX';
              detailIcon = Icons.credit_card;
            } else if (selectedType == 'PayPal') {
              detailLabel = 'Email Address';
              detailHint = 'email@example.com';
              detailIcon = Icons.email;
            } else if (selectedType == 'Bank Account') {
              detailLabel = 'Account Number';
              detailHint = 'XXXXXXXX';
              detailIcon = Icons.account_balance;
            }
          }
          
          return AlertDialog(
            backgroundColor: AppColors.deepSlateGray,
            title: Text(
              'Add Payment Method',
              style: TextStyle(color: AppColors.coolGray),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Method Type:',
                    style: TextStyle(color: AppColors.coolGray),
                  ),
                  const SizedBox(height: 8),
                  // Payment method type selector
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.charcoalBlack,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.coolGray.withAlpha(100)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedType,
                        dropdownColor: AppColors.charcoalBlack,
                        isExpanded: true,
                        icon: Icon(Icons.arrow_drop_down, color: AppColors.coolGray),
                        items: _paymentMethodTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type['name'] as String,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  Icon(
                                    type['icon'] as IconData,
                                    color: AppColors.mutedTeal,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    type['name'] as String,
                                    style: TextStyle(color: AppColors.coolGray),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setStateDialog(() {
                            selectedType = value!;
                            updateDetailFields();
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    detailLabel,
                    style: TextStyle(color: AppColors.coolGray),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: detailController,
                    style: TextStyle(color: AppColors.coolGray),
                    decoration: InputDecoration(
                      hintText: detailHint,
                      hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(150)),
                      prefixIcon: Icon(detailIcon, color: AppColors.mutedTeal),
                      filled: true,
                      fillColor: AppColors.charcoalBlack,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.coolGray),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.mutedTeal),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.coolGray.withAlpha(150)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'In a real app, additional security verification would be required',
                          style: TextStyle(fontSize: 12, color: AppColors.coolGray.withAlpha(150)),
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
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.coolGray),
                ),
              ),
              TextButton(
                onPressed: () {
                  final detail = detailController.text.trim();
                  if (detail.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter $detailLabel'),
                        backgroundColor: AppColors.warmCoral,
                      ),
                    );
                    return;
                  }
                  
                  // Add the new payment method
                  final newMethod = <String, dynamic>{
                    'name': selectedType,
                    'icon': _paymentMethodTypes
                        .firstWhere((type) => type['name'] == selectedType)['icon'],
                    'isDefault': false,
                  };
                  
                  // Add the appropriate detail field based on type
                  if (selectedType == 'Credit Card') {
                    // Format the last 4 digits
                    final lastFour = detail.replaceAll(' ', '').substring(
                        detail.replaceAll(' ', '').length > 4 ? 
                        detail.replaceAll(' ', '').length - 4 : 0);
                    newMethod['lastDigits'] = lastFour.length == 4 ? lastFour : detail;
                  } else if (selectedType == 'PayPal') {
                    newMethod['email'] = detail;
                  } else if (selectedType == 'Bank Account') {
                    newMethod['accountNumber'] = '****${detail.substring(detail.length > 4 ? detail.length - 4 : 0)}';
                  }
                  
                  setState(() {
                    _paymentMethods.add(newMethod);
                  });
                  
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$selectedType added successfully'),
                      backgroundColor: AppColors.mutedTeal,
                    ),
                  );
                },
                child: Text(
                  'Add',
                  style: TextStyle(color: AppColors.mutedTeal),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
