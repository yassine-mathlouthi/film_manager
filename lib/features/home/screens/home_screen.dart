import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/playlist_provider.dart';
import '../../../shared/widgets/welcome_header.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../../shared/widgets/action_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onNavigateToMovies;

  const HomeScreen({
    super.key,
    this.onNavigateToMovies,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, PlaylistProvider>(
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
              WelcomeHeader(user: user),
              const SizedBox(height: 32),

              // Stats section
              Text('Your Stats', style: AppTheme.titleStyle),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                      label: 'Favorites',
                      value: favoritesCount.toString(),
                      color: Colors.red,
                      onTap: () => context.push('/favorites'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: StatCard(
                      icon: PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
                      label: 'Movies',
                      value: 'Browse',
                      color: AppTheme.secondaryColor,
                      onTap: onNavigateToMovies,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick actions
              Text('Quick Actions', style: AppTheme.titleStyle),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  ActionCard(
                    icon: PhosphorIcons.heart(),
                    label: 'My Favorites',
                    iconColor: Colors.red,
                    onTap: () => context.push('/favorites'),
                  ),
                  ActionCard(
                    icon: PhosphorIcons.filmStrip(),
                    label: 'Browse Movies',
                    iconColor: AppTheme.secondaryColor,
                    onTap: onNavigateToMovies ?? () {},
                  ),
                  if (user.isAdmin)
                    ActionCard(
                      icon: PhosphorIcons.shield(),
                      label: 'Admin Panel',
                      iconColor: AppTheme.accentColor,
                      onTap: () => context.push('/admin'),
                    ),
                  ActionCard(
                    icon: PhosphorIcons.user(),
                    label: 'Profile',
                    iconColor: AppTheme.primaryColor,
                    onTap: () => context.push('/profile'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Info section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      PhosphorIcons.info(),
                      color: AppTheme.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Browse movies and add them to your favorites. Your preferences help us understand what you love!',
                        style: AppTheme.bodyStyle.copyWith(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
