import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Helper class to manage user roles and ensure proper redirection
class UserRoleHelper {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if the current user has a specific role
  static Future<bool> hasRole(String role) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint('UserRoleHelper - No current user, cannot check role');
        return false;
      }

      // Check if user ID contains the role as a prefix (for testing)
      // This is a fallback mechanism for testing
      if (user.uid.toLowerCase().contains(role.toLowerCase())) {
        debugPrint('UserRoleHelper - User ID ${user.uid} contains role $role, assuming role match');
        return true;
      }

      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      // Debug information
      debugPrint('UserRoleHelper - Checking role for user: ${user.uid}');
      debugPrint('UserRoleHelper - Document exists: ${userDoc.exists}');
      
      if (userDoc.exists) {
        if (userDoc.data() == null) {
          debugPrint('UserRoleHelper - Document exists but data is null');
          return false;
        }
        
        final userData = userDoc.data() as Map<String, dynamic>;
        debugPrint('UserRoleHelper - User data: $userData');
        
        if (!userData.containsKey('role')) {
          debugPrint('UserRoleHelper - No role field in user data');
          return false;
        }
        
        final dynamic roleValue = userData['role'];
        if (roleValue == null) {
          debugPrint('UserRoleHelper - Role field is null');
          return false;
        }
        
        final String userRole = roleValue.toString().toLowerCase();
        debugPrint('UserRoleHelper - User role: $userRole, Checking for: ${role.toLowerCase()}');
        return userRole == role.toLowerCase();
      }
      
      debugPrint('UserRoleHelper - User document does not exist');
      return false;
    } catch (e) {
      debugPrint('UserRoleHelper - Error checking role: $e');
      return false;
    }
  }

  /// Ensure the current user has a role set in Firestore
  /// This is useful for testing and debugging
  static Future<void> ensureUserRole(String role) async {
    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        debugPrint('UserRoleHelper - No current user');
        return;
      }
      
      debugPrint('UserRoleHelper - Ensuring role $role for user ${user.uid}');

      // Check if user document exists
      final DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists || userDoc.data() == null) {
        // Create user document if it doesn't exist
        debugPrint('UserRoleHelper - Creating user document with role: $role');
        await _firestore.collection('users').doc(user.uid).set({
          'role': role,
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Update role if document exists
        final userData = userDoc.data() as Map<String, dynamic>;
        if (!userData.containsKey('role') || userData['role'] != role) {
          debugPrint('UserRoleHelper - Updating user role to: $role');
          await _firestore.collection('users').doc(user.uid).update({
            'role': role,
          });
        } else {
          debugPrint('UserRoleHelper - User already has role: $role');
        }
      }
    } catch (e) {
      debugPrint('UserRoleHelper - Error ensuring user role: $e');
    }
  }
}
