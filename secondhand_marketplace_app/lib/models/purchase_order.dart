import 'package:flutter/material.dart';
import '../models/product.dart';

enum OrderStatus {
  pending,
  processed,
  outForDelivery,
  received,
  cancelled
}

class PurchaseOrder {
  final String id;
  final Product product;
  final int quantity;
  final double price;
  final DateTime purchaseDate;
  OrderStatus status;
  double? rating;
  String? review;

  PurchaseOrder({
    required this.id,
    required this.product,
    required this.quantity,
    required this.price,
    required this.purchaseDate,
    this.status = OrderStatus.pending,
    this.rating,
    this.review,
  });

  // Total price of the order
  double get totalPrice => price * quantity;

  // Check if order can be cancelled
  bool get canCancel => status == OrderStatus.pending;

  // Check if order can be marked as received
  bool get canMarkAsReceived => status == OrderStatus.outForDelivery;

  // Check if order can be rated
  bool get canRate => status == OrderStatus.received && (rating == null);

  // Get status color
  Color getStatusColor() {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.processed:
        return Colors.blue;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.received:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  // Get status text
  String getStatusText() {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processed:
        return 'Processed';
      case OrderStatus.outForDelivery:
        return 'Out for Delivery';
      case OrderStatus.received:
        return 'Received';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
