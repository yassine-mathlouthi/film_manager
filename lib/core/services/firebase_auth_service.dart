import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      print("=== Starting sign in process ===");
      print("Email: $email");
      
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print("✅ Sign in successful!");
      print("UID: ${credential.user?.uid}");
      
      if (credential.user != null) {
        // Fetch user data from Firestore
        print("Fetching user data from Firestore...");
        final userData = await _getUserData(credential.user!.uid);
        print("✅ User data fetched successfully");
        return userData;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.code}");
      print("Message: ${e.message}");
      throw _handleAuthException(e);
    } catch (e) {
      print("❌ Unexpected error during sign in: $e");
      print("Error type: ${e.runtimeType}");
      throw 'An unexpected error occurred: $e';
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String role = 'user',
  }) async {
    try {
      print("=== Starting registration process ===");
      print("Email: $email");
      print("Firebase Auth instance: ${_firebaseAuth.app.name}");
      
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print("✅ User registered successfully!");
      print("UID: ${credential.user?.uid}");

      if (credential.user != null) {
        // Create user document in Firestore
        final userData = {
          'id': credential.user!.uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'role': role,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': DateTime.now().toIso8601String(),
        };

        print("Saving user data to Firestore...");

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);

        print("✅ User data saved to Firestore");

        // Update display name
        await credential.user!.updateDisplayName('$firstName $lastName');
        
        print("✅ Registration complete!");
        return userData;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print("❌ Firebase Auth Error: ${e.code}");
      print("Message: ${e.message}");
      throw _handleAuthException(e);
    } catch (e) {
      print("❌ Unexpected error during registration: $e");
      print("Error type: ${e.runtimeType}");
      throw 'An unexpected error occurred: $e';
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Sign out failed. Please try again.';
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> _getUserData(String uid) async {
    try {
      print("Fetching user document for UID: $uid");
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
        print("✅ User document found");
        final data = doc.data();
        if (data != null) {
          // Update last login
          await _firestore.collection('users').doc(uid).update({
            'lastLoginAt': DateTime.now().toIso8601String(),
          });
          
          return {
            ...data,
            'id': uid,
            'lastLoginAt': DateTime.now().toIso8601String(),
          };
        }
      } else {
        print("❌ User document not found in Firestore");
      }
      return null;
    } catch (e) {
      print("❌ Error fetching user data: $e");
      throw 'Failed to fetch user data: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw 'Failed to update profile. Please try again.';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'Failed to send reset email. Please try again.';
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Invalid password. Please try again.';
      case 'email-already-in-use':
        return 'Email already exists. Please use a different email.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // Check if user is signed in
  bool isUserSignedIn() {
    return _firebaseAuth.currentUser != null;
  }

  // Get current user ID
  String? getCurrentUserId() {
    return _firebaseAuth.currentUser?.uid;
  }
}
