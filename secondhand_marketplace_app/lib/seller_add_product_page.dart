import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'constants.dart';
import 'utils/image_converter.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ImagePicker _picker = ImagePicker();
  
  // Form controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minBargainPriceController = TextEditingController();
  final TextEditingController _adBoostController = TextEditingController();
  
  String _selectedCategory = 'electronics'; // Default category
  String _selectedCondition = 'New'; // Default condition
  File? _imageFile;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Predefined lists
  final List<String> _categories = [
    'electronics',
    'furniture',
    'clothing',
    'books',
    'sports',
    'toys',
    'home',
    'vehicles',
    'others'
  ];
  
  final List<String> _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Poor'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _minBargainPriceController.dispose();
    _adBoostController.dispose();
    super.dispose();
  }
  
  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }
  
  // Convert image to base64 or use placeholder
  Future<String> _processImage() async {
    if (_imageFile != null) {
      // Convert image file to base64
      return await ImageConverter.fileToBase64(_imageFile!);
    } else {
      // Use placeholder image URL
      return 'https://upload.wikimedia.org/wikipedia/commons/1/14/No_Image_Available.jpg';
    }
  }
  
  // Submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      try {
        final String? sellerId = _auth.currentUser?.uid;
        if (sellerId == null) {
          throw Exception('User not authenticated');
        }
        
        // Process image
        final String imageSource = await _processImage();
        
        // Generate a unique product ID
        final String productId = '${_selectedCategory}_${DateTime.now().millisecondsSinceEpoch}';
        
        // Create product data
        final Map<String, dynamic> productData = {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'imageUrl': imageSource,
          'category': _selectedCategory,
          'sellerId': sellerId,
          'condition': _selectedCondition,
          'listedDate': Timestamp.now(),
          'stock': int.parse(_stockController.text.trim()),
          'adBoost': _adBoostController.text.isEmpty 
              ? 0.0 
              : double.parse(_adBoostController.text.trim()),
          'minBargainPrice': _minBargainPriceController.text.isEmpty 
              ? double.parse(_priceController.text.trim()) 
              : double.parse(_minBargainPriceController.text.trim()),
        };
        
        // Add to Firestore
        await _firestore.collection('products').doc(productId).set(productData);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Product added successfully'),
              backgroundColor: AppColors.mutedTeal,
            ),
          );
          
          // Clear form after successful submission
          _clearForm();
          
          // Navigate back
          Navigator.pop(context, true);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Error adding product: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  // Clear form fields
  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _stockController.clear();
    _minBargainPriceController.clear();
    _adBoostController.clear();
    setState(() {
      _imageFile = null;
      _selectedCategory = 'clothing';
      _selectedCondition = 'New';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        title: const Text(
          'Add New Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.deepSlateGray,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.mutedTeal))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message if any
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: Colors.red.withAlpha(25),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Product Image
                    Center(
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            color: AppColors.deepSlateGray,
                            borderRadius: BorderRadius.circular(8.0),
                            border: Border.all(
                              color: AppColors.mutedTeal,
                              width: 1.0,
                            ),
                          ),
                          child: _imageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.file(
                                    _imageFile!,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.add_photo_alternate,
                                      color: AppColors.mutedTeal,
                                      size: 50,
                                    ),
                                    const SizedBox(height: 8.0),
                                    const Text(
                                      'Add Product Image',
                                      style: TextStyle(
                                        color: AppColors.coolGray,
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    
                    // Product Name
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Product Name',
                        labelStyle: TextStyle(color: AppColors.coolGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.coolGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.mutedTeal),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a product name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Product Description
                    TextFormField(
                      controller: _descriptionController,
                      style: const TextStyle(color: Colors.white),
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: AppColors.coolGray),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.coolGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.mutedTeal),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a product description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Price and Stock in a row
                    Row(
                      children: [
                        // Price
                        Expanded(
                          child: TextFormField(
                            controller: _priceController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Price',
                              labelStyle: TextStyle(color: AppColors.coolGray),
                              prefixText: 'RM ',
                              prefixStyle: const TextStyle(color: Colors.white),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.coolGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.mutedTeal),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (double.tryParse(value) == null) {
                                return 'Invalid price';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Stock
                        Expanded(
                          child: TextFormField(
                            controller: _stockController,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Stock',
                              labelStyle: TextStyle(color: AppColors.coolGray),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.coolGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.mutedTeal),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              final stock = int.tryParse(value);
                              if (stock == null) {
                                return 'Invalid';
                              }
                              if (stock <= 0) {
                                return 'Must be at least 1';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Category and Condition in a row
                    Row(
                      children: [
                        // Category dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCategory,
                            dropdownColor: AppColors.deepSlateGray,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Category',
                              labelStyle: TextStyle(color: AppColors.coolGray),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.coolGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.mutedTeal),
                              ),
                            ),
                            items: _categories.map((String category) {
                              return DropdownMenuItem<String>(
                                value: category,
                                child: Text(
                                  category[0].toUpperCase() + category.substring(1),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        // Condition dropdown
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCondition,
                            dropdownColor: AppColors.deepSlateGray,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: 'Condition',
                              labelStyle: TextStyle(color: AppColors.coolGray),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.coolGray),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                                borderSide: BorderSide(color: AppColors.mutedTeal),
                              ),
                            ),
                            items: _conditions.map((String condition) {
                              return DropdownMenuItem<String>(
                                value: condition,
                                child: Text(
                                  condition,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  _selectedCondition = newValue;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Minimum Bargain Price (Optional)
                    TextFormField(
                      controller: _minBargainPriceController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Minimum Bargain Price (Optional)',
                        labelStyle: TextStyle(color: AppColors.coolGray),
                        prefixText: 'RM ',
                        prefixStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.coolGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.mutedTeal),
                        ),
                        helperText: 'Lowest price you\'re willing to accept for bargaining',
                        helperStyle: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final double? minPrice = double.tryParse(value);
                          if (minPrice == null) {
                            return 'Invalid price';
                          }
                          final double? price = double.tryParse(_priceController.text);
                          if (price != null && minPrice > price) {
                            return 'Must be less than price';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    
                    // Ad Boost (Optional)
                    TextFormField(
                      controller: _adBoostController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ad Boost Budget (Optional)',
                        labelStyle: TextStyle(color: AppColors.coolGray),
                        prefixText: 'RM ',
                        prefixStyle: const TextStyle(color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.coolGray),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: AppColors.mutedTeal),
                        ),
                        helperText: 'Amount to spend on promoting this listing',
                        helperStyle: TextStyle(color: AppColors.coolGray.withAlpha(179)),
                      ),
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Invalid amount';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32.0),
                    
                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mutedTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Add Product',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                  ],
                ),
              ),
            ),
    );
  }
}
