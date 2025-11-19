// Demo data for testing the application interfaces
// This file contains static data to simulate API responses
// Replace with actual API calls when implementing backend

import '../models/user_model.dart';

class DemoData {
  // Demo users for authentication and user management testing
  static final List<Map<String, dynamic>> users = [
    {
      'id': '1',
      'email': 'admin@filmmanager.com',
      'firstName': 'Admin',
      'lastName': 'User',
      'role': 'admin',
      'password': 'admin123',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 30))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
      'profileImageUrl': null,
    },
    {
      'id': '2',
      'email': 'user@filmmanager.com',
      'firstName': 'John',
      'lastName': 'Doe',
      'role': 'user',
      'password': 'user123',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 15))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(hours: 2))
          .toIso8601String(),
      'profileImageUrl': null,
    },
    {
      'id': '3',
      'email': 'jane.smith@example.com',
      'firstName': 'Jane',
      'lastName': 'Smith',
      'role': 'user',
      'password': 'jane123',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 10))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
      'profileImageUrl': null,
    },
    {
      'id': '4',
      'email': 'mike.johnson@example.com',
      'firstName': 'Mike',
      'lastName': 'Johnson',
      'role': 'user',
      'password': 'mike123',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(hours: 12))
          .toIso8601String(),
      'profileImageUrl': null,
    },
    {
      'id': '5',
      'email': 'sarah.wilson@example.com',
      'firstName': 'Sarah',
      'lastName': 'Wilson',
      'role': 'user',
      'password': 'sarah123',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 3))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(hours: 6))
          .toIso8601String(),
      'profileImageUrl': null,
    },
    {
      'id': '6',
      'email': 'alex.brown@example.com',
      'firstName': 'Alex',
      'lastName': 'Brown',
      'role': 'user',
      'password': 'alex123',
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
      'lastLoginAt': DateTime.now()
          .subtract(const Duration(hours: 3))
          .toIso8601String(),
      'profileImageUrl': null,
    },
  ];

  // Demo films data for the film management features
  static final List<Map<String, dynamic>> films = [
    {
      'id': '1',
      'title': 'The Shawshank Redemption',
      'description':
          'Two imprisoned men bond over a number of years, finding solace and eventual redemption through acts of common decency.',
      'director': 'Frank Darabont',
      'genres': ['Drama'],
      'releaseYear': 1994,
      'rating': 9.3,
      'posterUrl': null,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 20))
          .toIso8601String(),
      'updatedAt': DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String(),
    },
    {
      'id': '2',
      'title': 'The Godfather',
      'description':
          'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.',
      'director': 'Francis Ford Coppola',
      'genres': ['Crime', 'Drama'],
      'releaseYear': 1972,
      'rating': 9.2,
      'posterUrl': null,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 18))
          .toIso8601String(),
      'updatedAt': DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
    },
    {
      'id': '3',
      'title': 'The Dark Knight',
      'description':
          'When the menace known as the Joker wreaks havoc and chaos on the people of Gotham, Batman must accept one of the greatest psychological and physical tests.',
      'director': 'Christopher Nolan',
      'genres': ['Action', 'Crime', 'Drama'],
      'releaseYear': 2008,
      'rating': 9.0,
      'posterUrl': null,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 15))
          .toIso8601String(),
      'updatedAt': DateTime.now()
          .subtract(const Duration(hours: 5))
          .toIso8601String(),
    },
    {
      'id': '4',
      'title': 'Pulp Fiction',
      'description':
          'The lives of two mob hitmen, a boxer, a gangster and his wife intertwine in four tales of violence and redemption.',
      'director': 'Quentin Tarantino',
      'genres': ['Crime', 'Drama'],
      'releaseYear': 1994,
      'rating': 8.9,
      'posterUrl': null,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 12))
          .toIso8601String(),
      'updatedAt': DateTime.now()
          .subtract(const Duration(hours: 3))
          .toIso8601String(),
    },
    {
      'id': '5',
      'title': 'Forrest Gump',
      'description':
          'The presidencies of Kennedy and Johnson, the Vietnam War, the Watergate scandal and other historical events unfold from the perspective of an Alabama man.',
      'director': 'Robert Zemeckis',
      'genres': ['Drama', 'Romance'],
      'releaseYear': 1994,
      'rating': 8.8,
      'posterUrl': null,
      'createdAt': DateTime.now()
          .subtract(const Duration(days: 8))
          .toIso8601String(),
      'updatedAt': DateTime.now()
          .subtract(const Duration(hours: 1))
          .toIso8601String(),
    },
  ];

  // Helper methods to get demo data
  static List<User> getUsersList() {
    return users.map((userData) {
      final user = Map<String, dynamic>.from(userData);
      user.remove('password'); // Remove password for security
      return User.fromJson(user);
    }).toList();
  }

  static Map<String, dynamic>? findUserByCredentials(
    String email,
    String password,
  ) {
    try {
      return users.firstWhere(
        (user) => user['email'] == email && user['password'] == password,
      );
    } catch (e) {
      return null;
    }
  }

  static bool isEmailTaken(String email) {
    return users.any((user) => user['email'] == email);
  }

  static Map<String, int> getUserStatistics() {
    final now = DateTime.now();
    return {
      'totalUsers': users.length,
      'adminUsers': users.where((user) => user['role'] == 'admin').length,
      'regularUsers': users.where((user) => user['role'] == 'user').length,
      'newUsersThisWeek': users.where((user) {
        final createdAt = DateTime.parse(user['createdAt']);
        final weekAgo = now.subtract(const Duration(days: 7));
        return createdAt.isAfter(weekAgo);
      }).length,
      'activeUsersToday': users.where((user) {
        if (user['lastLoginAt'] == null) return false;
        final lastLogin = DateTime.parse(user['lastLoginAt']);
        return lastLogin.year == now.year &&
            lastLogin.month == now.month &&
            lastLogin.day == now.day;
      }).length,
    };
  }

  static Map<String, int> getFilmStatistics() {
    return {
      'totalFilms': films.length,
      'genres': films
          .expand((film) => film['genres'] as List<String>)
          .toSet()
          .length,
      'averageRating':
          (films
                      .map((film) => film['rating'] as double)
                      .reduce((a, b) => a + b) /
                  films.length *
                  10)
              .round(),
    };
  }
}
