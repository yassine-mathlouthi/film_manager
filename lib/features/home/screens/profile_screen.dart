import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/playlist_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.pencilSimple()),
            onPressed: () => context.push('/profile/edit'),
            tooltip: 'Edit Profile',
          ),
        ],
      ),
      body: Consumer2<AuthProvider, PlaylistProvider>(
        builder: (context, authProvider, playlistProvider, child) {
          final user = authProvider.currentUser;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final favoritesCount = playlistProvider.favoriteMovieIds.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      // Profile Photo
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: user.profileImageUrl != null &&
                                user.profileImageUrl!.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  user.profileImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar(user.fullName);
                                  },
                                ),
                              )
                            : _buildDefaultAvatar(user.fullName),
                      ),
                      const SizedBox(height: 16),
                      // Name
                      Text(
                        user.fullName,
                        style: AppTheme.headlineStyle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Email
                      Text(
                        user.email,
                        style: AppTheme.bodyStyle.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      if (user.age != null) ...[
                        const SizedBox(height: 4),
                        // Age
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              PhosphorIcons.cake(),
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${user.age} years old',
                              style: AppTheme.bodyStyle.copyWith(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      // Role Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: user.isAdmin
                              ? AppTheme.primaryGradient
                              : LinearGradient(
                                  colors: [
                                    AppTheme.secondaryColor,
                                    AppTheme.secondaryColor.withOpacity(0.8),
                                  ],
                                ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              user.isAdmin
                                  ? PhosphorIcons.shield(PhosphorIconsStyle.fill)
                                  : PhosphorIcons.user(PhosphorIconsStyle.fill),
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              user.isAdmin ? 'ADMIN' : 'USER',
                              style: AppTheme.captionStyle.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Stats Section
                Text('Statistics', style: AppTheme.titleStyle),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        label: 'Favorites',
                        value: favoritesCount.toString(),
                        color: Colors.red,
                        onTap: () => context.push('/favorites'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        icon: PhosphorIcons.calendar(),
                        label: 'Member Since',
                        value: _formatDate(user.createdAt),
                        color: AppTheme.secondaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

               

                // Preferences Section
                Text('Preferences', style: AppTheme.titleStyle),
                const SizedBox(height: 16),
                _buildMenuTile(
                  icon: PhosphorIcons.heart(),
                  title: 'My Favorites',
                  subtitle: 'View your favorite movies',
                  onTap: () => context.push('/favorites'),
                ),
                
                const SizedBox(height: 16),

                // Danger Zone
                Text('Danger Zone', style: AppTheme.titleStyle),
                const SizedBox(height: 16),
                _buildMenuTile(
                  icon: PhosphorIcons.signOut(),
                  title: 'Logout',
                  subtitle: 'Sign out of your account',
                  color: Colors.red,
                  onTap: () => _showLogoutDialog(context, authProvider, playlistProvider),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDefaultAvatar(String name) {
    final initials = name.split(' ').map((e) => e[0]).take(2).join().toUpperCase();
    return Center(
      child: Text(
        initials,
        style: AppTheme.headlineStyle.copyWith(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
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
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: AppTheme.titleStyle.copyWith(
                fontSize: 20,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.captionStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryColor).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: color ?? AppTheme.primaryColor,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: AppTheme.subtitleStyle.copyWith(
            fontSize: 16,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: AppTheme.captionStyle.copyWith(fontSize: 13),
        ),
        trailing: Icon(
          PhosphorIcons.caretRight(),
          color: Colors.grey[400],
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
    PlaylistProvider playlistProvider,
  ) {
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
              playlistProvider.clear();
              authProvider.logout();
              context.go('/login');
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
