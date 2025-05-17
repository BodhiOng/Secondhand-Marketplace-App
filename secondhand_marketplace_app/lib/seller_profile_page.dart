import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'constants.dart';
import 'seller_listing_page.dart';
import 'seller_reviews_page.dart';
import 'seller_wallet_page.dart';
import 'utils/page_transitions.dart';

class SellerProfilePage extends StatefulWidget {
  const SellerProfilePage({super.key});

  @override
  State<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends State<SellerProfilePage> {
  int _selectedIndex = 3; // Set to 3 for Profile tab
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _storeDescController = TextEditingController();
  final TextEditingController _helpSubjectController = TextEditingController();
  final TextEditingController _helpMessageController = TextEditingController();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // User data
  String _profileImageUrl = '';
  String _uid = '';
  String _role = 'seller';
  DateTime? _joinDate;
  bool _isLoading = true;

  File? _profileImageFile;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _storeNameController.dispose();
    _storeDescController.dispose();
    _helpSubjectController.dispose();
    _helpMessageController.dispose();
    super.dispose();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      _uid = currentUser.uid;
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        setState(() {
          _usernameController.text = userData['username'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _addressController.text = userData['address'] ?? '';
          _storeNameController.text = userData['storeName'] ?? '';
          _storeDescController.text = userData['storeDescription'] ?? '';
          _profileImageUrl = userData['profileImageUrl'] ?? '';
          _role = userData['role'] ?? 'seller';

          if (userData['joinDate'] != null) {
            _joinDate = (userData['joinDate'] as Timestamp).toDate();
          }

          _isLoading = false;
        });
        
        // Ensure user has seller role
        if (_role != 'seller') {
          await _firestore.collection('users').doc(_uid).update({
            'role': 'seller',
          });
          _role = 'seller';
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
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
      case 1: // Navigate to Reviews
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerReviewsPage()),
        );
        break;
      case 2: // Navigate to Wallet
        Navigator.pushReplacement(
          context,
          DarkPageReplaceRoute(page: const SellerWalletPage()),
        );
        break;
      case 3: // Already on Profile page, just update index
        setState(() {
          _selectedIndex = index;
        });
        break;
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        setState(() {
          _profileImageFile = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: AppColors.warmCoral,
          ),
        );
      }
    }
  }

  bool _isBase64Image(String source) {
    try {
      if (source.isEmpty) return false;
      if (source.length % 4 != 0) return false;
      final base64Regex = RegExp(r'^[A-Za-z0-9+/]*={0,2}$');
      if (!base64Regex.hasMatch(source)) return false;

      // Try to decode it
      base64Decode(source);
      return true;
    } catch (e) {
      return false;
    }
  }

  ImageProvider _getImageProvider() {
    if (_profileImageFile != null) {
      return FileImage(_profileImageFile!);
    } else if (_isBase64Image(_profileImageUrl)) {
      return MemoryImage(base64Decode(_profileImageUrl));
    } else if (_profileImageUrl.isNotEmpty) {
      return NetworkImage(_profileImageUrl);
    } else {
      return const AssetImage('assets/images/default_profile.png');
    }
  }

  Future<void> _uploadProfileImage({bool useBase64 = true}) async {
    if (_profileImageFile == null) return;

    try {
      if (useBase64) {
        // Convert image to base64
        final bytes = await _profileImageFile!.readAsBytes();
        _profileImageUrl = base64Encode(bytes);
      } else {
        // Upload to Firebase Storage
        final ref = _storage.ref().child('profile_images/$_uid.jpg');
        await ref.putFile(_profileImageFile!);
        _profileImageUrl = await ref.getDownloadURL();
      }
    } catch (e) {
      debugPrint('Error uploading profile image: $e');
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Upload profile image if changed
      if (_profileImageFile != null) {
        await _uploadProfileImage();
      }

      // Update user data in Firestore
      await _firestore.collection('users').doc(_uid).update({
        'username': _usernameController.text,
        'address': _addressController.text,
        'storeName': _storeNameController.text,
        'storeDescription': _storeDescController.text,
        'profileImageUrl': _profileImageUrl,
        'role': 'seller',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Profile updated successfully'),
            backgroundColor: AppColors.mutedTeal,
          ),
        );

        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: AppColors.warmCoral,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitHelpRequest() async {
    if (_helpSubjectController.text.isEmpty || _helpMessageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please fill in both subject and message'),
          backgroundColor: AppColors.warmCoral,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save help request to Firestore
      await _firestore.collection('help_requests').add({
        'userId': _uid,
        'username': _usernameController.text,
        'email': _emailController.text,
        'subject': _helpSubjectController.text,
        'message': _helpMessageController.text,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'userRole': 'seller',
      });

      // Clear the form
      _helpSubjectController.clear();
      _helpMessageController.clear();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Your request has been submitted. We will get back to you soon.',
            ),
            backgroundColor: AppColors.mutedTeal,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting request: $e'),
            backgroundColor: AppColors.warmCoral,
          ),
        );

        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Text('My Profile', style: TextStyle(color: AppColors.coolGray)),
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
                        _isLoading
                            ? CircularProgressIndicator(
                              color: AppColors.mutedTeal,
                            )
                            : CircleAvatar(
                              radius: 60,
                              backgroundImage: _getImageProvider(),
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
                    if (!_isEditing && !_isLoading)
                      Text(
                        _usernameController.text,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                    if (!_isEditing && !_isLoading && _role.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.softLemonYellow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.charcoalBlack,
                          ),
                        ),
                      ),
                    if (!_isEditing && !_isLoading && _joinDate != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Member since ${DateFormat('MMMM yyyy').format(_joinDate!)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.coolGray.withAlpha(150),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Store Information Section
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
                        'Store Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.coolGray,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Editing Mode
                      if (_isEditing) ...[
                        // Store Name Field
                        Text(
                          'Store Name',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _storeNameController,
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
                              borderSide: BorderSide(
                                color: AppColors.mutedTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Store Description Field
                        Text(
                          'Store Description',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _storeDescController,
                          style: TextStyle(color: AppColors.coolGray),
                          maxLines: 3,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.charcoalBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: AppColors.coolGray),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.mutedTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Username Field
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
                              borderSide: BorderSide(
                                color: AppColors.mutedTeal,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Email Field (Read-only)
                        Text(
                          'Email',
                          style: TextStyle(color: AppColors.coolGray),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          style: TextStyle(color: AppColors.coolGray),
                          enabled: false, // Disable email editing
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: AppColors.charcoalBlack,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.coolGray.withAlpha(100),
                              ),
                            ),
                            disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: AppColors.coolGray.withAlpha(70),
                              ),
                            ),
                            suffixIcon: Icon(
                              Icons.lock,
                              color: AppColors.coolGray.withAlpha(100),
                            ),
                            hintText: 'Email cannot be changed',
                            hintStyle: TextStyle(
                              color: AppColors.coolGray.withAlpha(100),
                              fontSize: 12,
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
                              borderSide: BorderSide(
                                color: AppColors.mutedTeal,
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        // Display mode (non-editing)
                        ListTile(
                          leading: Icon(
                            Icons.store,
                            color: AppColors.mutedTeal,
                          ),
                          title: Text(
                            'Store Name',
                            style: TextStyle(
                              color: AppColors.coolGray.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            _storeNameController.text.isNotEmpty
                                ? _storeNameController.text
                                : 'Not set',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                        ),
                        Divider(color: AppColors.coolGray.withAlpha(50)),
                        ListTile(
                          leading: Icon(
                            Icons.description,
                            color: AppColors.mutedTeal,
                          ),
                          title: Text(
                            'Store Description',
                            style: TextStyle(
                              color: AppColors.coolGray.withAlpha(200),
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            _storeDescController.text.isNotEmpty
                                ? _storeDescController.text
                                : 'Not set',
                            style: TextStyle(color: AppColors.coolGray),
                          ),
                        ),
                        Divider(color: AppColors.coolGray.withAlpha(50)),
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
                          hintStyle: TextStyle(
                            color: AppColors.coolGray.withAlpha(150),
                          ),
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
                          hintStyle: TextStyle(
                            color: AppColors.coolGray.withAlpha(150),
                          ),
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
                  leading: Icon(Icons.logout, color: AppColors.warmCoral),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: AppColors.coolGray),
                  ),
                  onTap: () async {
                    // Handle logout
                    try {
                      await _auth.signOut();
                      if (!mounted) return;
                      
                      // Use a post-frame callback to ensure the widget is still in the tree
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/',
                          (route) => false,
                        );
                      });
                    } catch (e) {
                      if (!mounted) return;
                      
                      // Use a post-frame callback for error handling too
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error logging out: $e'),
                            backgroundColor: AppColors.warmCoral,
                          ),
                        );
                      });
                    }
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
