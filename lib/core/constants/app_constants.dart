// Core constants for the application
class AppConstants {
  // Storage keys (used by StorageService)
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // User roles
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
}
