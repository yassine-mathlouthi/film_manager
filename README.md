# Film Manager - Flutter Application

A beautiful and scalable Flutter application for managing film collections with role-based authentication and admin features.

## Features
<img width="375" height="797" alt="Capture d&#39;écran 2025-11-21 224117" src="https://github.com/user-attachments/assets/bfd1eb7c-36ff-42c3-a2c9-1ee45bf0fd99" />
<img width="365" height="792" alt="Capture d&#39;écran 2025-11-21 224039" src="https://github.com/user-attachments/assets/8ea4e7c4-2f28-4c5a-8d22-d334b066b9a0" />
<img width="391" height="813" alt="Capture d&#39;écran 2025-11-21 223642" src="https://github.com/user-attachments/assets/6db0fd27-344c-4d59-b78c-8072abb3fbc8" />
<img width="386" height="802" alt="Capture d&#39;écran 2025-11-21 223532" src="https://github.com/user-attachments/assets/c98eb344-84b3-4bda-b18a-86da10c16f61" />
<img width="369" height="809" alt="Capture d&#39;écran 2025-11-21 223507" src="https://github.com/user-attachments/assets/8697d12d-52b0-4053-a4b7-9d8a71457bcf" />
<img width="391" height="808" alt="Capture d&#39;écran 2025-11-21 223438" src="https://github.com/user-attachments/assets/749b8f5c-f806-4e4a-8c30-28320c998b7d" />

### 🔐 Authentication System

- **User Registration**: New users can create accounts with email validation
- **User Login**: Secure login system with form validation
- **Role-based Access**: Different user roles (Admin, Regular User)
- **Session Management**: Persistent login state with secure storage

### 👤 User Features

- **Home Dashboard**: Beautiful welcome screen with user statistics
- **Film Collection**: Personal film management (coming soon)
- **Profile Management**: User profile editing and management
- **Responsive UI**: Modern and intuitive user interface

### 🛡️ Admin Features

- **Admin Dashboard**: Comprehensive admin control panel
- **User Management**: View, search, and manage all users
- **System Analytics**: Overview of system statistics
- **User Role Management**: Ability to manage user permissions
- **Activity Monitoring**: Recent activities and system health

## Architecture & Best Practices

### 📁 Project Structure

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── models/          # Data models with JSON serialization
│   ├── providers/       # State management with Provider
│   ├── services/        # API and storage services
│   ├── theme/          # App theming and styling
│   └── router/         # Navigation configuration
├── features/
│   ├── auth/           # Authentication screens
│   ├── home/           # User dashboard
│   └── admin/          # Admin management screens
└── shared/
    └── widgets/        # Reusable UI components
```

### 🏗️ Architecture Principles

- **Clean Architecture**: Separation of concerns with clear layers
- **Provider Pattern**: State management using Provider package
- **Repository Pattern**: Data layer abstraction
- **Feature-based**: Modular organization by features
- **SOLID Principles**: Maintainable and extensible code

### 🎨 Design System

- **Modern UI**: Beautiful gradients and consistent styling
- **Material Design 3**: Following latest Material Design guidelines
- **Custom Theme**: Scalable theme system with brand colors
- **Responsive Design**: Works across different screen sizes
- **Accessibility**: Focus on inclusive design

## Getting Started

### Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK
- Android Studio / VS Code
- Git

### Installation

1. **Clone the repository**

   ```bash
   git clone <repository-url>
   cd film-manager
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Generate code (for JSON serialization)**

   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the application**
   ```bash
   flutter run
   ```

## Usage

### 🚀 First Time Setup

1. **Launch the app** - You'll see the login screen
2. **Create an account** - Tap "Sign Up" to register
3. **Fill in your details** - Enter your information
4. **Start exploring** - You'll be redirected to the home dashboard

### 👤 Regular User Flow

1. **Login** with your credentials
2. **Home Dashboard** - View your statistics and quick actions
3. **Manage Films** - Add, edit, and organize your film collection
4. **Profile** - Update your profile information
5. **Logout** - Securely logout when done

### 🛡️ Admin User Flow

1. **Login** with admin credentials
2. **Admin Dashboard** - View system overview and statistics
3. **User Management** - Navigate to user list to manage users
4. **Search & Filter** - Find specific users by name, email, or role
5. **User Actions** - Edit or remove users as needed
6. **System Monitoring** - Check recent activities and system health

### 📱 Demo Accounts

For testing purposes, you can use these demo accounts:

**Admin Account:**

- Email: admin@filmmanager.com
- Password: admin123

**Regular User:**

- Email: user@filmmanager.com
- Password: user123

_Note: These are demo accounts for testing the UI. In a production environment, implement proper API integration._

## API Integration

The app is designed to work with a REST API. Currently, it includes:

### 🔌 API Endpoints Structure

- `POST /auth/login` - User authentication
- `POST /auth/register` - User registration
- `GET /users` - Get all users (admin only)
- `GET /users/:id` - Get specific user
- `PATCH /users/:id` - Update user
- `DELETE /users/:id` - Delete user (admin only)

### 🛠️ API Service Configuration

Update the API base URL in `lib/core/constants/app_constants.dart`:

```dart
static const String baseUrl = 'https://your-api-url.com';
```

## Dependencies

### 📦 Core Dependencies

- **provider**: State management
- **go_router**: Declarative routing
- **google_fonts**: Typography
- **phosphor_flutter**: Beautiful icons
- **shared_preferences**: Local storage
- **http**: HTTP client

### 🛠️ Development Dependencies

- **build_runner**: Code generation
- **json_serializable**: JSON serialization
- **flutter_lints**: Code analysis

## Customization

### 🎨 Theming

Modify colors and typography in `lib/core/theme/app_theme.dart`:

```dart
// Custom colors
static const Color primaryColor = Color(0xFF1A1B3E);
static const Color secondaryColor = Color(0xFF6366F1);
static const Color accentColor = Color(0xFFEC4899);
```

### 🏗️ Adding New Features

1. Create feature folder in `lib/features/`
2. Add screens, widgets, and providers
3. Update router configuration
4. Add navigation links

### 📊 State Management

Add new providers in `lib/core/providers/`:

```dart
class NewFeatureProvider extends ChangeNotifier {
  // Your state management logic
}
```

## Testing

### 🧪 Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### 📝 Test Structure

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for user flows

## Performance Optimization

### ⚡ Best Practices Implemented

- **Lazy Loading**: Widgets loaded on demand
- **Image Caching**: Network images cached efficiently
- **Memory Management**: Proper disposal of controllers
- **Build Optimization**: Efficient widget rebuilds
- **Code Splitting**: Feature-based organization

## Security

### 🔒 Security Features

- **Input Validation**: Form validation and sanitization
- **Secure Storage**: Encrypted local storage for sensitive data
- **Authentication**: JWT token-based authentication
- **Route Guards**: Protected routes based on user roles
- **Error Handling**: Secure error messages

## Contributing

1. **Fork the repository**
2. **Create feature branch** (`git checkout -b feature/amazing-feature`)
3. **Commit changes** (`git commit -m 'Add amazing feature'`)
4. **Push to branch** (`git push origin feature/amazing-feature`)
5. **Open Pull Request**

## Troubleshooting

### 🔧 Common Issues

**Build Errors:**

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**IDE Issues:**

- Restart your IDE
- Reload the Flutter project
- Check Flutter Doctor: `flutter doctor`

### 📞 Support

- Create an issue on GitHub
- Check existing issues for solutions
- Follow Flutter best practices

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Material Design for UI guidelines
- Phosphor Icons for beautiful iconography
- Google Fonts for typography

---

**Built with ❤️ using Flutter**
