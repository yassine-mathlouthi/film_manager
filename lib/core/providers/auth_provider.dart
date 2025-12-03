import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../services/firebase_auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuthService _firebaseAuthService = FirebaseAuthService();
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  AuthProvider() {
    _loadUserFromStorage();
  }

  // Load user data from storage on app start
  Future<void> _loadUserFromStorage() async {
    _setLoading(true);
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        _currentUser = await StorageService.getUser();
      }
    } catch (e) {
      _setError('Failed to load user data');
    }
    _setLoading(false);
  }

  // Login user
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      // Sign in with Firebase
      final userData = await _firebaseAuthService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userData != null) {
        _currentUser = User.fromJson(userData);

        // Save to local storage
        await StorageService.saveToken(userData['id']);
        await StorageService.saveLoginStatus(true);
        await StorageService.saveUser(_currentUser!);

        _setLoading(false);
        return true;
      } else {
        _setError('Invalid credentials. Please try again.');
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // Register new user
  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    int? age,
    String? imagePath,
    String role = 'user',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Register with Firebase
      final userData = await _firebaseAuthService.registerWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        age: age,
        imagePath: imagePath,
        role: role,
      );

      if (userData != null) {
        _currentUser = User.fromJson(userData);

        // Save to local storage
        await StorageService.saveToken(userData['id']);
        await StorageService.saveLoginStatus(true);
        await StorageService.saveUser(_currentUser!);

        _setLoading(false);
        return true;
      } else {
        _setError('Registration failed. Please try again.');
      }
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await _firebaseAuthService.signOut();
      await StorageService.clearUserData();
      _currentUser = null;
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    try {
      // Update in Firebase (this will handle image upload if imagePath is provided)
      await _firebaseAuthService.updateUserProfile(
        uid: _currentUser!.id,
        updates: updates,
      );

      // Fetch the updated user data from Firestore to get the new profileImageUrl
      final userData = await _firebaseAuthService.getUserData(_currentUser!.id);
      
      if (userData != null) {
        _currentUser = User.fromJson(userData);
        await StorageService.saveUser(_currentUser!);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
    return false;
  }

  // Send password reset email
  Future<bool> sendPasswordResetEmail(String email) async {
    _setLoading(true);
    _clearError();

    try {
      await _firebaseAuthService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
