import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String seller;
  final double rating;
  final String condition;
  final DateTime listedDate;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.seller,
    required this.rating,
    required this.condition,
    required this.listedDate,
  });
}

class Category {
  final String name;
  final IconData icon;

  Category({required this.name, required this.icon});
}
