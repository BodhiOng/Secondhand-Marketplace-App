import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'buyer_home_page.dart';
import 'login_page.dart';
import 'landing_page.dart';
import 'seller_listing_page.dart';
import 'utils/user_role_helper.dart';

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
  bool _isCheckingRole = false;

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

  // Check user role and update state accordingly
  Future<void> _checkUserRoleAndSetState(User user) async {
    try {
      // Set checking state
      setState(() {
        _isCheckingRole = true;
      });
      
      // Check if the user ID contains 'seller' (for testing purposes)
      final bool isSellerByUserId = user.uid.toLowerCase().contains('seller');
      debugPrint('AuthWrapper - User ID: ${user.uid}');
      debugPrint('AuthWrapper - User ID contains seller: $isSellerByUserId');
      
      // For testing: Ensure the user has the seller role if their ID contains 'seller'
      // This is just for demonstration purposes
      if (isSellerByUserId) {
        await UserRoleHelper.ensureUserRole('seller');
        debugPrint('AuthWrapper - Ensured seller role for user with seller in ID');
        
        // If we're still mounted, update the state
        if (mounted) {
          setState(() {
            _isCheckingRole = false;
          });
        }
        
        // No need to continue checking if we already know the user is a seller
        return;
      }
      
      // Check if user is a seller using our helper
      final bool isSeller = await UserRoleHelper.hasRole('seller');
      debugPrint('AuthWrapper - User is seller: $isSeller');
      
      // Reset checking state if we're still mounted
      if (mounted) {
        setState(() {
          _isCheckingRole = false;
        });
      }
      
      // If user is a seller but we didn't catch it from the ID check,
      // we need to force a rebuild to show the seller page
      if (isSeller && mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('AuthWrapper - Error checking role: $e');
      // In case of error, reset checking state
      if (mounted) {
        setState(() {
          _isCheckingRole = false;
        });
      }
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
          debugPrint('AuthWrapper build - User ID: ${user.uid}');
          
          // Direct check for seller in user ID - faster than Firestore check
          final bool isSellerByUserId = user.uid.toLowerCase().contains('seller');
          debugPrint('AuthWrapper build - User ID contains seller: $isSellerByUserId');
          
          // If user ID contains 'seller', redirect to seller listing page immediately
          if (isSellerByUserId) {
            debugPrint('AuthWrapper build - Redirecting to seller listing page based on user ID');
            
            // Ensure the user has the seller role in Firestore (for consistency)
            // This is done asynchronously and doesn't block the UI
            UserRoleHelper.ensureUserRole('seller').then((_) {
              debugPrint('AuthWrapper build - Ensured seller role for user with seller in ID');
            });
            
            return const SellerListingPage();
          }
          
          // For users without 'seller' in their ID, show loading while checking role
          if (_isCheckingRole) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          // Start the role check process if not already started
          if (!_isCheckingRole) {
            _checkUserRoleAndSetState(user);
          }
          
          // Default to home page while checking role
          return const MyHomePage(title: 'ThriftNest');
        }
        
        // If user is not authenticated, show login page
        return const LoginPage();
      },
    );
  }
}
