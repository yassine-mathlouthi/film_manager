import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/users_provider.dart';
import '../../../core/providers/movies_provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    
    await Future.wait([
      usersProvider.fetchUsers(),
      moviesProvider.fetchMovies(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.house()),
          onPressed: () => context.go('/home'),
          tooltip: 'Back to Home',
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.signOut()),
            onPressed: () => _showLogoutDialog(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Consumer3<AuthProvider, UsersProvider, MoviesProvider>(
        builder: (context, authProvider, usersProvider, moviesProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final totalUsers = usersProvider.users.length;
          final activeUsers = usersProvider.users.where((u) => u.isActive).length;
          final totalMovies = moviesProvider.movies.length;
          final newUsersToday = usersProvider.users.where((u) {
            final createdAt = u.createdAt;
            final now = DateTime.now();
            return createdAt.year == now.year &&
                   createdAt.month == now.month &&
                   createdAt.day == now.day;
          }).length;

          return RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome section
                  _buildWelcomeCard(user.fullName),
                  const SizedBox(height: 32),

                  // Admin stats
                  Text('System Overview', style: AppTheme.titleStyle),
                  const SizedBox(height: 16),
                  _buildStatsGrid(
                    totalUsers: totalUsers,
                    activeUsers: activeUsers,
                    totalMovies: totalMovies,
                    newUsersToday: newUsersToday,
                  ),
                  const SizedBox(height: 32),

                  // Admin actions
                  Text('Quick Actions', style: AppTheme.titleStyle),
                  const SizedBox(height: 16),
                  _buildAdminActions(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(String userName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              PhosphorIcons.shield(PhosphorIconsStyle.fill),
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Admin Panel',
                  style: AppTheme.titleStyle.copyWith(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Welcome back, $userName',
                  style: AppTheme.bodyStyle.copyWith(
                    color: Colors.white.withOpacity(0.95),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required int totalUsers,
    required int activeUsers,
    required int totalMovies,
    required int newUsersToday,
  }) {
    final activityPercentage = totalUsers > 0 
        ? ((activeUsers / totalUsers) * 100).toStringAsFixed(0)
        : '0';
    
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          icon: PhosphorIcons.users(PhosphorIconsStyle.fill),
          label: 'Total Users',
          value: totalUsers.toString(),
          color: AppTheme.primaryColor,
          gradient: LinearGradient(
            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.7)],
          ),
        ),
        _buildStatCard(
          icon: PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
          label: 'Total Movies',
          value: totalMovies.toString(),
          color: AppTheme.accentColor,
          gradient: LinearGradient(
            colors: [AppTheme.accentColor, AppTheme.accentColor.withOpacity(0.7)],
          ),
        ),
        _buildStatCard(
          icon: PhosphorIcons.userPlus(PhosphorIconsStyle.fill),
          label: 'New Today',
          value: newUsersToday.toString(),
          color: AppTheme.successColor,
          gradient: LinearGradient(
            colors: [AppTheme.successColor, AppTheme.successColor.withOpacity(0.7)],
          ),
        ),
        _buildStatCard(
          icon: PhosphorIcons.chartBar(PhosphorIconsStyle.fill),
          label: 'Active Users',
          value: '$activityPercentage%',
          color: AppTheme.secondaryColor,
          gradient: LinearGradient(
            colors: [AppTheme.secondaryColor, AppTheme.secondaryColor.withOpacity(0.7)],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleStyle.copyWith(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.captionStyle.copyWith(
              color: Colors.white.withOpacity(0.95),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Column(
      children: [
        _buildActionCard(
          icon: PhosphorIcons.userList(PhosphorIconsStyle.fill),
          label: 'Manage Users',
          subtitle: 'View and manage all users',
          color: AppTheme.primaryColor,
          onTap: () => context.push('/admin/users'),
        ),
        const SizedBox(height: 16),
        _buildActionCard(
          icon: PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
          label: 'Manage Movies',
          subtitle: 'Add, edit, or remove movies',
          color: AppTheme.accentColor,
          onTap: () => context.push('/admin/movies'),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTheme.subtitleStyle.copyWith(
                        fontSize: 18,
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTheme.captionStyle.copyWith(fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(
                PhosphorIcons.caretRight(PhosphorIconsStyle.bold),
                color: color,
                size: 24,
              ),
            ],
          ),
        ),
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
