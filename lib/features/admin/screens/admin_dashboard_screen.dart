import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.house()),
            onPressed: () => context.go('/home'),
          ),
          IconButton(
            icon: Icon(PhosphorIcons.signOut()),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            PhosphorIcons.shield(),
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Admin Panel',
                                  style: AppTheme.titleStyle.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'Welcome, ${user.fullName}',
                                  style: AppTheme.subtitleStyle.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Admin stats
                Text('System Overview', style: AppTheme.titleStyle),
                const SizedBox(height: 16),
                _buildStatsGrid(),
                const SizedBox(height: 32),

                // Admin actions
                Text('Admin Actions', style: AppTheme.titleStyle),
                const SizedBox(height: 16),
                _buildAdminActions(context),
                const SizedBox(height: 32),

                // Recent activities
                Text('Recent Activities', style: AppTheme.titleStyle),
                const SizedBox(height: 16),
                _buildRecentActivities(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatCard(
          icon: PhosphorIcons.users(),
          label: 'Total Users',
          value: '247',
          color: AppTheme.secondaryColor,
        ),
        _buildStatCard(
          icon: PhosphorIcons.filmStrip(),
          label: 'Total Films',
          value: '1,523',
          color: AppTheme.accentColor,
        ),
        _buildStatCard(
          icon: PhosphorIcons.userPlus(),
          label: 'New Users',
          value: '12',
          color: AppTheme.successColor,
        ),
        _buildStatCard(
          icon: PhosphorIcons.chartBar(),
          label: 'Activity Score',
          value: '94%',
          color: AppTheme.warningColor,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTheme.titleStyle.copyWith(fontSize: 20, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTheme.captionStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: PhosphorIcons.userList(),
                label: 'Manage Users',
                subtitle: 'View and manage all users',
                color: AppTheme.primaryColor,
                onTap: () => context.go('/admin/users'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: PhosphorIcons.filmStrip(),
                label: 'Manage Films',
                subtitle: 'Add, edit, or remove films',
                color: AppTheme.secondaryColor,
                onTap: 
                  () => context.go('/admin/movies'),
                
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                icon: PhosphorIcons.chartLineUp(),
                label: 'Analytics',
                subtitle: 'View system analytics',
                color: AppTheme.accentColor,
                onTap: () {
                  // TODO: Navigate to analytics
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildActionCard(
                icon: PhosphorIcons.gear(),
                label: 'Settings',
                subtitle: 'System configuration',
                color: AppTheme.warningColor,
                onTap: () {
                  // TODO: Navigate to settings
                },
              ),
            ),
          ],
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              style: AppTheme.subtitleStyle.copyWith(
                fontSize: 16,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTheme.captionStyle),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivities() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        separatorBuilder: (context, index) =>
            Divider(color: AppTheme.textLight.withOpacity(0.2), height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: _getActivityColor(index).withOpacity(0.1),
              child: Icon(
                _getActivityIcon(index),
                color: _getActivityColor(index),
                size: 20,
              ),
            ),
            title: Text(_getActivityTitle(index), style: AppTheme.bodyStyle),
            subtitle: Text(
              _getActivitySubtitle(index),
              style: AppTheme.captionStyle,
            ),
            trailing: Text(
              _getActivityTime(index),
              style: AppTheme.captionStyle.copyWith(fontSize: 12),
            ),
          );
        },
      ),
    );
  }

  IconData _getActivityIcon(int index) {
    final icons = [
      PhosphorIcons.userPlus(),
      PhosphorIcons.filmStrip(),
      PhosphorIcons.trash(),
      PhosphorIcons.pencil(),
      PhosphorIcons.signIn(),
    ];
    return icons[index % icons.length];
  }

  Color _getActivityColor(int index) {
    final colors = [
      AppTheme.successColor,
      AppTheme.primaryColor,
      AppTheme.errorColor,
      AppTheme.warningColor,
      AppTheme.secondaryColor,
    ];
    return colors[index % colors.length];
  }

  String _getActivityTitle(int index) {
    final titles = [
      'New user registered',
      'Film added to catalog',
      'User account deleted',
      'Film information updated',
      'Admin login detected',
    ];
    return titles[index % titles.length];
  }

  String _getActivitySubtitle(int index) {
    final subtitles = [
      'john.doe@example.com joined the platform',
      'The Matrix was added by admin',
      'inactive.user@example.com was removed',
      'Updated rating for Inception',
      'Admin panel access from new device',
    ];
    return subtitles[index % subtitles.length];
  }

  String _getActivityTime(int index) {
    final times = ['2m ago', '15m ago', '1h ago', '3h ago', '1d ago'];
    return times[index % times.length];
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
