// Core constants for the application
class AppConstants {
  // API endpoints
  static const String baseUrl = 'https://api.filmmanager.com';
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String usersEndpoint = '/users';
  static const String filmsEndpoint = '/films';

  // Storage keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isLoggedInKey = 'is_logged_in';

  // Route names
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String adminRoute = '/admin';
  static const String usersListRoute = '/admin/users';

  // User roles
  static const String adminRole = 'admin';
  static const String userRole = 'user';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
}
