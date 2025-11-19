import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../data/demo_data.dart';

class UsersProvider extends ChangeNotifier {
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;

  List<User> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all users (admin only)
  Future<void> fetchUsers() async {
    _setLoading(true);
    _clearError();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Convert static data to User objects
      _users = DemoData.getUsersList();
    } catch (e) {
      _setError('Failed to fetch users. Please check your connection.');
    }

    _setLoading(false);
  }

  // Delete user (admin only)
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();

    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      // Remove user from static data
      DemoData.users.removeWhere((user) => user['id'] == userId);
      _users.removeWhere((user) => user.id == userId);

      _setLoading(false);
      return true;
    } catch (e) {
      _setError('Delete failed. Please try again.');
    }

    _setLoading(false);
    return false;
  }

  // Search users
  List<User> searchUsers(String query) {
    if (query.isEmpty) return _users;

    return _users.where((user) {
      final fullName = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      final searchQuery = query.toLowerCase();

      return fullName.contains(searchQuery) || email.contains(searchQuery);
    }).toList();
  }

  // Filter users by role
  List<User> filterUsersByRole(String role) {
    return _users.where((user) => user.role == role).toList();
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
