import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/auth_provider.dart';
import 'home_screen.dart';
import 'movies_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const MoviesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Film Manager' : 'Movies'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.gear()),
            onPressed: () {
              // TODO: Navigate to settings
            },
          ),
          IconButton(
            icon: Icon(PhosphorIcons.signOut()),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: Icon(PhosphorIcons.house()),
            selectedIcon: Icon(PhosphorIcons.house(PhosphorIconsStyle.fill)),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(PhosphorIcons.filmStrip()),
            selectedIcon: Icon(PhosphorIcons.filmStrip(PhosphorIconsStyle.fill)),
            label: 'Movies',
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).logout();
              context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
