import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/providers/matching_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/info_card.dart';
import '../widgets/user_match_tile.dart';

class MatchingScreen extends StatefulWidget {
  const MatchingScreen({super.key});

  @override
  State<MatchingScreen> createState() => _MatchingScreenState();
}

class _MatchingScreenState extends State<MatchingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  Future<void> _loadMatches() async {
    print('\n╔═══════════════════════════════════════╗');
    print('║  MATCHING SCREEN - LOADING MATCHES    ║');
    print('╚═══════════════════════════════════════╝\n');
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final matchingProvider = Provider.of<MatchingProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      print('=== LOADING MATCHES FOR USER: ${currentUser.id} ===');
      print('User: ${currentUser.fullName}');
      print('Email: ${currentUser.email}\n');
      
      await matchingProvider.loadMatches(currentUser.id);
      
      print('=== MATCHES FOUND: ${matchingProvider.matches.length} ===');
      if (matchingProvider.matches.isEmpty) {
        print('⚠️  No matches found. Possible reasons:');
        print('   1. No other users have playlists');
        print('   2. Match percentage < 75%');
        print('   3. Other users have empty playlists');
      } else {
        print('✅ Matches:');
        for (var match in matchingProvider.matches) {
          print('   - ${match.userName}: ${match.matchPercentage.toStringAsFixed(1)}%');
        }
      }
      print('\n');
    } else {
      print('❌ No current user found!');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              PhosphorIconsRegular.users,
              color: AppTheme.primaryColor,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Your Matches',
              style: AppTheme.titleStyle,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              PhosphorIconsRegular.arrowsClockwise,
              color: AppTheme.primaryColor,
            ),
            onPressed: _loadMatches,
            tooltip: 'Refresh matches',
          ),
        ],
      ),
      body: Consumer<MatchingProvider>(
        builder: (context, matchingProvider, _) {
          if (matchingProvider.isLoading) {
            return const LoadingWidget(
              message: 'Finding users with similar tastes...',
            );
          }

          if (matchingProvider.error != null) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    PhosphorIconsRegular.warningCircle,
                    size: 80,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Oops! Something went wrong',
                    style: AppTheme.titleStyle.copyWith(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    matchingProvider.error!,
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _loadMatches,
                    icon: Icon(PhosphorIconsRegular.arrowsClockwise),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          if (matchingProvider.matches.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      gradient: AppTheme.accentGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      PhosphorIconsRegular.magnifyingGlass,
                      size: 64,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'No Matches Yet',
                    style: AppTheme.titleStyle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add more movies to your favorites to discover users with similar tastes!',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  InfoCard.info(
                    message: 'We match you with users who have at least 75% compatibility based on your favorite movies.',
                    icon: PhosphorIconsRegular.lightbulb,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadMatches,
                    icon: Icon(PhosphorIconsRegular.arrowsClockwise),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMatches,
            color: AppTheme.primaryColor,
            child: CustomScrollView(
              slivers: [
                // Header with gradient and count
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
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
                            PhosphorIconsRegular.heartbeat,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${matchingProvider.matches.length}',
                                style: AppTheme.headlineStyle.copyWith(
                                  color: Colors.white,
                                  fontSize: 36,
                                  height: 1,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getMatchTitle(matchingProvider.matches),
                                style: AppTheme.subtitleStyle.copyWith(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // List of matches
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final userMatch = matchingProvider.matches[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: UserMatchTile(userMatch: userMatch),
                        );
                      },
                      childCount: matchingProvider.matches.length,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getMatchTitle(List matches) {
    if (matches.length == 1) {
      final percentage = matches[0].matchPercentage;
      if (percentage == 100) {
        return 'Perfect Match Found';
      }
      return 'Match Found';
    }
    
    final perfectMatches = matches.where((m) => m.matchPercentage == 100).length;
    if (perfectMatches == matches.length) {
      return 'Perfect Matches';
    } else if (perfectMatches > 0) {
      return '$perfectMatches Perfect Match${perfectMatches > 1 ? 'es' : ''} • ${matches.length - perfectMatches} Compatible User${matches.length - perfectMatches > 1 ? 's' : ''}';
    }
    
    return 'Compatible Users';
  }
}