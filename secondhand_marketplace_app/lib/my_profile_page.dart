import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'constants.dart';
import 'home_page.dart';
import 'my_purchases_page.dart';
import 'my_wallet_page.dart';
import 'utils/page_transitions.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({super.key});

  @override
  State<MyProfilePage> createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  int _selectedIndex = 3; // Set to 3 for Profile tab
  final TextEditingController _usernameController = TextEditingController(text: 'John Doe');
  final TextEditingController _emailController = TextEditingController(text: 'john.doe@example.com');
  final TextEditingController _addressController = TextEditingController(text: '123 Market Street, Kuala Lumpur');
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _helpSubjectController = TextEditingController();
  final TextEditingController _helpMessageController = TextEditingController();
  
  // Sample profile image
  String _profileImageUrl = 'https://picsum.photos/id/1005/200/200';
  File? _profileImageFile;
  bool _isEditing = false;
  bool _isChangingPassword = false;
  
  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _helpSubjectController.dispose();
    _helpMessageController.dispose();
    super.dispose();
  }
  
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
      // Navigate to Wallet page
      Navigator.pushReplacement(
        context,
        DarkPageReplaceRoute(page: const MyWalletPage()),
      );
    } else if (index == 3) {
      // Already on Profile page, just update index
      setState(() {
        _selectedIndex = index;
      });
    }
  }
  
  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        setState(() {
          _profileImageFile = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: AppColors.warmCoral,
        ),
      );
    }
  }
  
  void _saveProfile() {
    if (_usernameController.text.isEmpty || _emailController.text.isEmpty || _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all fields'),
          backgroundColor: AppColors.warmCoral,
        ),
      );
      return;
    }
    
    // In a real app, this would save to a backend
    setState(() {
      _isEditing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profile updated successfully'),
        backgroundColor: AppColors.mutedTeal,
      ),
    );
  }
  
  void _changePassword() {
    if (_currentPasswordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in all password fields'),
          backgroundColor: AppColors.warmCoral,
        ),
      );
      return;
    }
    
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('New passwords do not match'),
          backgroundColor: AppColors.warmCoral,
        ),
      );
      return;
    }
    
    // In a real app, this would verify the current password and update to the new one
    setState(() {
      _isChangingPassword = false;
      _currentPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password changed successfully'),
        backgroundColor: AppColors.mutedTeal,
      ),
    );
  }
  
  void _submitHelpRequest() {
    if (_helpSubjectController.text.isEmpty || _helpMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter both subject and message'),
          backgroundColor: AppColors.warmCoral,
        ),
      );
      return;
    }
    
    // In a real app, this would send the message to customer support
    setState(() {
      _helpSubjectController.clear();
      _helpMessageController.clear();
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Your message has been sent to our support team'),
        backgroundColor: AppColors.mutedTeal,
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
          'My Profile',
          style: TextStyle(color: AppColors.coolGray),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              color: AppColors.coolGray,
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              color: AppColors.mutedTeal,
              onPressed: _saveProfile,
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.cancel),
              color: AppColors.warmCoral,
              onPressed: () {
                setState(() {
                  _isEditing = false;
                });
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
              // Profile Header with Image
              Center(
                child: Column(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImageFile != null
                              ? FileImage(_profileImageFile!) as ImageProvider
                              : NetworkImage(_profileImageUrl),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.mutedTeal,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.camera_alt),
                                color: Colors.white,
                                onPressed: _pickImage,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (!_isEditing)
                      Text(
                        _usernameController.text,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                    if (!_isEditing)
                      Text(
                        _emailController.text,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.coolGray.withAlpha(200),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Profile Information Section
              Card(
                color: AppColors.deepSlateGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Username Field
                      if (_isEditing) ...[  
                        Text(
                          'Username',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _usernameController,
                          style: TextStyle(color: AppColors.coolGray),
                          decoration: InputDecoration(
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
                        
                        // Email Field
                        Text(
                          'Email',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: AppColors.coolGray),
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
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
                        
                        // Address Field
                        Text(
                          'Address',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _addressController,
                          style: TextStyle(color: AppColors.coolGray),
                          maxLines: 2,
                          decoration: InputDecoration(
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
                      ] else ...[  
                        // Display mode (non-editing)
                        ListTile(
                          leading: Icon(
                            Icons.location_on,
                            color: AppColors.mutedTeal,
                          ),
                          title: Text(
                            'Address',
                            style: TextStyle(
                              color: AppColors.coolGray.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            _addressController.text,
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                        ),
                        Divider(color: AppColors.coolGray.withAlpha(50)),
                        ListTile(
                          leading: Icon(
                            Icons.email,
                            color: AppColors.mutedTeal,
                          ),
                          title: Text(
                            'Email',
                            style: TextStyle(
                              color: AppColors.coolGray.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            _emailController.text,
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Password Section
              Card(
                color: AppColors.deepSlateGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.coolGray,
                            ),
                          ),
                          if (!_isChangingPassword)
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isChangingPassword = true;
                                });
                              },
                              child: Text(
                                'Change',
                                style: TextStyle(color: AppColors.mutedTeal),
                              ),
                            ),
                        ],
                      ),
                      if (_isChangingPassword) ...[  
                        const SizedBox(height: 16),
                        Text(
                          'Current Password',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _currentPasswordController,
                          style: TextStyle(color: AppColors.coolGray),
                          obscureText: true,
                          decoration: InputDecoration(
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
                          'New Password',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newPasswordController,
                          style: TextStyle(color: AppColors.coolGray),
                          obscureText: true,
                          decoration: InputDecoration(
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
                          'Confirm New Password',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _confirmPasswordController,
                          style: TextStyle(color: AppColors.coolGray),
                          obscureText: true,
                          decoration: InputDecoration(
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
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isChangingPassword = false;
                                  _currentPasswordController.clear();
                                  _newPasswordController.clear();
                                  _confirmPasswordController.clear();
                                });
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: AppColors.coolGray),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: _changePassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.mutedTeal,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Update Password'),
                            ),
                          ],
                        ),
                      ] else ...[  
                        ListTile(
                          leading: Icon(
                            Icons.lock,
                            color: AppColors.mutedTeal,
                          ),
                          title: Text(
                            'Password',
                            style: TextStyle(
                              color: AppColors.coolGray.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            '••••••••',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Help Center Section
              Card(
                color: AppColors.deepSlateGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Help Center',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Do you have any feedbacks, complaints, and enquiries?',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Subject',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _helpSubjectController,
                        style: TextStyle(color: AppColors.coolGray),
                        decoration: InputDecoration(
                          hintText: 'Enter subject',
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
                        'Message',
                        style: TextStyle(color: AppColors.coolGray),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _helpMessageController,
                        style: TextStyle(color: AppColors.coolGray),
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Type your message here...',
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
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _submitHelpRequest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mutedTeal,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('Submit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Logout option
              Card(
                color: AppColors.deepSlateGray,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: AppColors.warmCoral,
                  ),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.coolGray),
                  ),
                  onTap: () {
                    // Handle logout
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Logout functionality would be implemented here'),
                        backgroundColor: AppColors.mutedTeal,
                      ),
                    );
                  },
                ),
              ),
              
              // Bottom padding
              const SizedBox(height: 32),
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
