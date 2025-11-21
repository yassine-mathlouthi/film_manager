import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class UsersService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all users
  Future<List<User>> getAllUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          role: data['role'] ?? 'user',
          isActive: data['isActive'] ?? true,
          age: data['age'],
          profileImageUrl: data['profileImageUrl'],
          createdAt: _parseDateTime(data['createdAt']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users: $e');
    }
  }

  // Stream all users (real-time updates)
  Stream<List<User>> streamUsers() {
    return _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          role: data['role'] ?? 'user',
          isActive: data['isActive'] ?? true,
          age: data['age'],
          profileImageUrl: data['profileImageUrl'],
          createdAt: _parseDateTime(data['createdAt']),
        );
      }).toList();
    });
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return User(
        id: doc.id,
        email: data['email'] ?? '',
        firstName: data['firstName'] ?? '',
        lastName: data['lastName'] ?? '',
        role: data['role'] ?? 'user',
        isActive: data['isActive'] ?? true,
        age: data['age'],
        profileImageUrl: data['profileImageUrl'],
        createdAt: _parseDateTime(data['createdAt']),
      );
    } catch (e) {
      throw Exception('Failed to fetch user: $e');
    }
  }

  // Update user
  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);
    } catch (e) {
      throw Exception('Failed to update user: $e');
    }
  }

  // Delete user
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // Toggle user active status
  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isActive': isActive,
      });
    } catch (e) {
      throw Exception('Failed to update user status: $e');
    }
  }

  // Search users by name or email
  Future<List<User>> searchUsers(String query) async {
    try {
      final snapshot = await _firestore.collection('users').get();

      final allUsers = snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          role: data['role'] ?? 'user',
          isActive: data['isActive'] ?? true,
          age: data['age'],
          profileImageUrl: data['profileImageUrl'],
          createdAt: _parseDateTime(data['createdAt']),
        );
      }).toList();

      // Filter locally
      final lowerQuery = query.toLowerCase();
      return allUsers.where((user) {
        final fullName = user.fullName.toLowerCase();
        final email = user.email.toLowerCase();
        return fullName.contains(lowerQuery) || email.contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  // Get users by role
  Future<List<User>> getUsersByRole(String role) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: role)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          role: data['role'] ?? 'user',
          isActive: data['isActive'] ?? true,
          age: data['age'],
          profileImageUrl: data['profileImageUrl'],
          createdAt: _parseDateTime(data['createdAt']),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch users by role: $e');
    }
  }

  // Helper method to parse DateTime from various formats
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    } else if (value is int) {
      // Handle milliseconds since epoch
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    return DateTime.now();
  }
}
