import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'buyer_home_page.dart';
import 'login_page.dart';
import 'landing_page.dart';
import 'seller_listing_page.dart';

/// AuthWrapper is responsible for determining whether to show the login page
/// or the home page based on the user's authentication state.
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    // Show splash screen for 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSplash = false;
        });
      }
    });
  }

  // Check if user is a seller by checking their role in Firestore
  Future<bool> _isUserSeller(String uid) async {
    try {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (!userDoc.exists) return false;

      final userRole = userDoc.data()?['role']?.toString().toLowerCase();
      return userRole == 'seller' || userRole == 'admin';
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen initially
    if (_showSplash) {
      return const LandingPage();
    }

    // Listen to auth state changes and return appropriate page
    return StreamBuilder<User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        // If user is authenticated, check role and redirect accordingly
        if (snapshot.hasData) {
          // Get the current user
          final User user = snapshot.data!;

          // Direct check for seller in user ID - faster than Firestore check
          final bool isSellerByUserId = user.uid.toLowerCase().contains('seller');

          // Use FutureBuilder to handle the async role check
          return FutureBuilder<bool>(
            future: _isUserSeller(user.uid),
            builder: (context, roleSnapshot) {
              // Show loading indicator while checking role
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              // Check if user is a seller (either by ID or role in Firestore)
              final isSeller = isSellerByUserId || (roleSnapshot.data ?? false);
              if (isSeller) {
                return const SellerListingPage();
              }

              // Default to home page for buyers
              return const MyHomePage(title: 'ThriftNest');
            },
          );
        }

        // If user is not authenticated, show login page
        return const LoginPage();
      },
    );
  }
}
