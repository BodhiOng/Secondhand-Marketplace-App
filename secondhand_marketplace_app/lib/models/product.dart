import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final List<String>? additionalImages;
  final String category;
  final String sellerId;
  final String? seller; // For backward compatibility
  final double? rating;
  final String condition;
  final DateTime listedDate;
  final DateTime? createdAt; // When the product was created
  final int stock;
  final double adBoostPrice;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.additionalImages,
    required this.category,
    required this.sellerId,
    this.seller,
    this.rating,
    required this.condition,
    required this.listedDate,
    this.createdAt,
    required this.stock,
    required this.adBoostPrice,
  });
  
  // Factory constructor to create a Product from Firestore data
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      additionalImages: data['additionalImages'] != null 
          ? List<String>.from(data['additionalImages']) 
          : null,
      category: data['category'] ?? '',
      sellerId: data['sellerId'] ?? '',
      seller: null, // We'll fetch this separately if needed
      rating: null, // We'll calculate this separately if needed
      condition: data['condition'] ?? '',
      listedDate: DateTime.now(), // We'll use current time as default
      createdAt: data['createdAt'] != null ? (data['createdAt'] as Timestamp).toDate() : null,
      stock: data['stock'] ?? 0,
      adBoostPrice: (data['adBoostPrice'] ?? 0).toDouble(),
    );
  }
}

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}
