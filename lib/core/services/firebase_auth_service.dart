import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cloudinary_service.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();


  // Get current Firebase user
  firebase_auth.User? get currentFirebaseUser => _firebaseAuth.currentUser;

  // Sign in with email and password
  Future<Map<String, dynamic>?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (credential.user != null) {
        final userData = await getUserData(credential.user!.uid);
        
        // Check if user is active
        if (userData != null && userData['isActive'] == false) {
          await _firebaseAuth.signOut();
          throw 'Your account has been deactivated by an administrator. Please contact support for assistance.';
        }
        
        return userData;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw 'An unexpected error occurred: $e';
    }
  }

  // Register with email and password
  Future<Map<String, dynamic>?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    int? age,
    String? imagePath,
    String role = 'user',
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user != null) {
        String? profileImageUrl;
        
        // Upload profile image to Cloudinary if provided
        if (imagePath != null) {
          try {
            profileImageUrl = await _cloudinaryService.uploadProfileImage(
              imagePath, 
              credential.user!.uid,
            );
          } catch (e) {
            // Continue registration even if image upload fails
          }
        }
        
        // Create user document in Firestore
        final userData = {
          'id': credential.user!.uid,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'age': age,
          'role': role,
          'profileImageUrl': profileImageUrl,
          'createdAt': DateTime.now().toIso8601String(),
          'lastLoginAt': DateTime.now().toIso8601String(),
        };

        await _firestore
            .collection('users')
            .doc(credential.user!.uid)
            .set(userData);

        await credential.user!.updateDisplayName('$firstName $lastName');
        
        return userData;
      }
      return null;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
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
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      
      if (doc.exists) {
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
      }
      return null;
    } catch (e) {
      throw 'Failed to fetch user data: $e';
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> updates,
  }) async {
    try {
      // Check if there's an image to upload
      if (updates.containsKey('imagePath') && updates['imagePath'] != null) {
        final imagePath = updates['imagePath'] as String;
        
        final imageUrl = await _cloudinaryService.uploadProfileImage(imagePath, uid);
        
        if (imageUrl != null) {
          updates['profileImageUrl'] = imageUrl;
        }
        
        // Remove imagePath from updates as it's not stored in Firestore
        updates.remove('imagePath');
      }
      
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
