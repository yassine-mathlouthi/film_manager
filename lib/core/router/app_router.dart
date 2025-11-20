import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_step1_screen.dart';
import '../../features/auth/screens/register_step2_screen.dart';
import '../../features/auth/screens/register_step3_screen.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../../features/admin/screens/admin_dashboard_screen.dart';
import '../../features/admin/screens/users_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterStep1Screen(),
    ),
    GoRoute(
      path: '/register/step2',
      name: 'register-step2',
      builder: (context, state) {
        final step1Data = state.extra as Map<String, dynamic>;
        return RegisterStep2Screen(step1Data: step1Data);
      },
    ),
    GoRoute(
      path: '/register/step3',
      name: 'register-step3',
      builder: (context, state) {
        final previousData = state.extra as Map<String, dynamic>;
        return RegisterStep3Screen(previousData: previousData);
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainNavigationScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLoggedIn) {
          return '/login';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminDashboardScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLoggedIn) {
          return '/login';
        }
        if (!authProvider.isAdmin) {
          return '/home';
        }
        return null;
      },
    ),
    GoRoute(
      path: '/admin/users',
      name: 'users-list',
      builder: (context, state) => const UsersListScreen(),
      redirect: (context, state) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (!authProvider.isLoggedIn) {
          return '/login';
        }
        if (!authProvider.isAdmin) {
          return '/home';
        }
        return null;
      },
    ),
  ],
);
