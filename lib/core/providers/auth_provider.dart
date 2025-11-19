import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import '../data/demo_data.dart';

class AuthProvider extends ChangeNotifier {
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

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Check static demo users
      final user = DemoData.findUserByCredentials(email, password);

      if (user != null) {
        // Create user model without password
        final userData = Map<String, dynamic>.from(user);
        userData.remove('password');

        _currentUser = User.fromJson(userData);

        // Save to local storage
        await StorageService.saveToken('demo_token_${user['id']}');
        await StorageService.saveLoginStatus(true);
        await StorageService.saveUser(_currentUser!);

        _setLoading(false);
        return true;
      } else {
        _setError('Invalid credentials. Please try again.');
      }
    } catch (e) {
      _setError('Login failed. Please check your connection.');
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
    String role = 'user',
  }) async {
    _setLoading(true);
    _clearError();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Check if email already exists
      if (DemoData.isEmailTaken(email)) {
        _setError('Email already exists. Please use a different email.');
        _setLoading(false);
        return false;
      }

      // Create new user
      final newUser = {
        'id': (DemoData.users.length + 1).toString(),
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role,
        'createdAt': DateTime.now().toIso8601String(),
        'lastLoginAt': DateTime.now().toIso8601String(),
      };

      // Add to demo users (in real app, this would be API call)
      DemoData.users.add({...newUser, 'password': password});

      _currentUser = User.fromJson(newUser);

      // Save to local storage
      await StorageService.saveToken('demo_token_${newUser['id']}');
      await StorageService.saveLoginStatus(true);
      await StorageService.saveUser(_currentUser!);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Registration failed. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Logout user
  Future<void> logout() async {
    _setLoading(true);

    try {
      await StorageService.clearUserData();
      _currentUser = null;
      _clearError();
    } catch (e) {
      _setError('Logout failed');
    }

    _setLoading(false);
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    _clearError();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Update current user data
      final updatedUserData = {
        'id': _currentUser!.id,
        'email': _currentUser!.email,
        'firstName': updates['firstName'] ?? _currentUser!.firstName,
        'lastName': updates['lastName'] ?? _currentUser!.lastName,
        'role': _currentUser!.role,
        'createdAt': _currentUser!.createdAt.toIso8601String(),
        'lastLoginAt': _currentUser!.lastLoginAt?.toIso8601String(),
        'profileImageUrl':
            updates['profileImageUrl'] ?? _currentUser!.profileImageUrl,
      };

      _currentUser = User.fromJson(updatedUserData);
      await StorageService.saveUser(_currentUser!);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Update failed. Please try again.');
    }

    _setLoading(false);
    return false;
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
