import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'landing_page.dart';

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
        // If user is authenticated, show home page
        if (snapshot.hasData) {
          return const MyHomePage(title: 'ThriftNest');
        }
        // Otherwise, show login page
        return const LoginPage();
      },
    );
  }
}
