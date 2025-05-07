import 'package:flutter/material.dart';
import 'dart:io';
import 'constants.dart';
import 'models/product.dart';

class ReportItemPage extends StatefulWidget {
  final Product product;

  const ReportItemPage({super.key, required this.product});

  @override
  State<ReportItemPage> createState() => _ReportItemPageState();
}

class _ReportItemPageState extends State<ReportItemPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? _imageFile;
  final List<String> _reportReasons = [
    'Select a reason',
    'Counterfeit or fake item',
    'Prohibited or illegal item',
    'Incorrect description',
    'Scam or fraudulent listing',
    'Offensive content',
    'Other'
  ];
  String _selectedReason = 'Select a reason';

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitReport() {
    if (_formKey.currentState!.validate() && _selectedReason != _reportReasons[0]) {
      // Here you would typically send the report to your backend
      // For now, we'll just show a success message and navigate back
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report submitted successfully'),
          backgroundColor: AppColors.mutedTeal,
          duration: const Duration(seconds: 2),
        ),
      );
      
      // Navigate back after a short delay
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else if (_selectedReason == _reportReasons[0]) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select a reason for your report'),
          backgroundColor: AppColors.warmCoral,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.charcoalBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepSlateGray,
        title: Text(
          'Report Item',
          style: TextStyle(color: AppColors.coolGray),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.coolGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Preview
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.deepSlateGray,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.mutedTeal.withAlpha(100)),
                  ),
                  child: Row(
                    children: [
                      // Product Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Product Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name,
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
                              '\$${widget.product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.mutedTeal,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seller: ${widget.product.seller}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.coolGray.withAlpha(179),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                Text(
                  'Report Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.coolGray,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Reason Dropdown
                Text(
                  'Reason for Report',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.coolGray,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.deepSlateGray,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mutedTeal.withAlpha(100)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedReason,
                      dropdownColor: AppColors.deepSlateGray,
                      style: TextStyle(color: AppColors.coolGray),
                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.mutedTeal),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedReason = newValue;
                          });
                        }
                      },
                      items: _reportReasons.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value, style: TextStyle(color: AppColors.coolGray)),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Subject Field
                Text(
                  'Subject',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.coolGray,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _subjectController,
                  style: TextStyle(color: AppColors.coolGray),
                  decoration: InputDecoration(
                    hintText: 'Enter a subject for your report',
                    hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(128)),
                    filled: true,
                    fillColor: AppColors.deepSlateGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(100)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(100)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.mutedTeal),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a subject';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Description Field
                Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.coolGray,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  style: TextStyle(color: AppColors.coolGray),
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Provide details about the issue',
                    hintStyle: TextStyle(color: AppColors.coolGray.withAlpha(128)),
                    filled: true,
                    fillColor: AppColors.deepSlateGray,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(100)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppColors.mutedTeal.withAlpha(100)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.mutedTeal),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 24),
                
                // Photo Upload
                Text(
                  'Add Photos (Optional)',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.coolGray,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.deepSlateGray,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.mutedTeal.withAlpha(100)),
                  ),
                  child: Center(
                    child: _imageFile != null
                        ? Stack(
                            children: [
                              Image.file(
                                _imageFile!,
                                width: double.infinity,
                                height: 120,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _imageFile = null;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: AppColors.warmCoral,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate,
                                color: AppColors.mutedTeal,
                                size: 40,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to add photos',
                                style: TextStyle(
                                  color: AppColors.coolGray,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _submitReport,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warmCoral,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit Report',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
