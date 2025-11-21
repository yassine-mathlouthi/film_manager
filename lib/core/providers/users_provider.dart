import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/users_service.dart';

class UsersProvider extends ChangeNotifier {
  final UsersService _usersService = UsersService();
  
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

    try {
      _users = await _usersService.getAllUsers();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Delete user (admin only)
  Future<bool> deleteUser(String userId) async {
    _setLoading(true);
    _clearError();

    try {
      await _usersService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Toggle user active status
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    _clearError();

    try {
      await _usersService.toggleUserStatus(userId, isActive);
      
      // Update local state
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = User(
          id: _users[index].id,
          email: _users[index].email,
          firstName: _users[index].firstName,
          lastName: _users[index].lastName,
          role: _users[index].role,
          isActive: isActive,
          age: _users[index].age,
          profileImageUrl: _users[index].profileImageUrl,
          createdAt: _users[index].createdAt,
        );
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
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
  }
}
