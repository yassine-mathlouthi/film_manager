import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/playlist_provider.dart';
import '../../../core/providers/matching_provider.dart';
import '../../../core/services/movie_service.dart';
import '../../../shared/widgets/welcome_header.dart';
import '../../../shared/widgets/action_card.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/movie_details_modal.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback? onNavigateToMovies;

  const HomeScreen({
    super.key,
    this.onNavigateToMovies,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MovieService _movieService = MovieService();
  List<dynamic> _movies = [];
  bool _isLoadingMovies = false;

  @override
  void initState() {
    super.initState();
    _loadMovies();
    _loadMatches();
  }

  Future<void> _loadMovies() async {
    setState(() => _isLoadingMovies = true);
    try {
      final movies = await _movieService.getMovies();
      setState(() {
        _movies = movies.take(4).toList();
        _isLoadingMovies = false;
      });
    } catch (e) {
      setState(() => _isLoadingMovies = false);
    }
  }

  Future<void> _loadMatches() async {
    final authProvider = context.read<AuthProvider>();
    final matchingProvider = context.read<MatchingProvider>();
    final currentUser = authProvider.currentUser;

    if (currentUser != null) {
      await matchingProvider.loadMatches(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<AuthProvider, PlaylistProvider, MatchingProvider>(
      builder: (context, authProvider, playlistProvider, matchingProvider, child) {
        final user = authProvider.currentUser;
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final favoritesCount = playlistProvider.favoriteMovieIds.length;
        final topMatches = matchingProvider.matches.take(3).toList();

        return RefreshIndicator(
          onRefresh: () async {
            await _loadMovies();
            await _loadMatches();
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WelcomeHeader(user: user),
                const SizedBox(height: 32),

                // Quick actions
                Row(
                  children: [
                    Expanded(
                      child: ActionCard(
                        icon: PhosphorIcons.heart(PhosphorIconsStyle.fill),
                        label: 'My Favorites',
                        subtitle: '$favoritesCount ${favoritesCount == 1 ? 'movie' : 'movies'}',
                        iconColor: Colors.red,
                        onTap: () => context.push('/favorites'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ActionCard(
                        icon: PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
                        label: 'Browse Movies',
                        iconColor: AppTheme.secondaryColor,
                        onTap: widget.onNavigateToMovies ?? () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Matching Section
                _buildMatchingSection(matchingProvider, topMatches),
                const SizedBox(height: 32),

                // Popular Movies Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Popular Movies', style: AppTheme.titleStyle),
                    TextButton.icon(
                      onPressed: widget.onNavigateToMovies,
                      icon: Icon(
                        PhosphorIcons.arrowRight(),
                        size: 16,
                      ),
                      label: const Text('View All'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _isLoadingMovies
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : _movies.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(32.0),
                              child: Column(
                                children: [
                                  Icon(
                                    PhosphorIcons.filmStrip(),
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'No movies available',
                                    style: AppTheme.bodyStyle.copyWith(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _movies.length,
                            itemBuilder: (context, index) {
                              final movie = _movies[index];
                              return MovieCard(
                                movie: movie,
                                onTap: () => _showMovieDetails(movie),
                              );
                            },
                          ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMatchingSection(MatchingProvider matchingProvider, List topMatches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppTheme.accentGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    PhosphorIcons.heartbeat(PhosphorIconsStyle.fill),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text('Your Matches', style: AppTheme.titleStyle),
              ],
            ),
            if (matchingProvider.matches.length > 3)
              TextButton.icon(
                onPressed: () => context.push('/matching'),
                icon: Icon(
                  PhosphorIcons.arrowRight(),
                  size: 16,
                ),
                label: const Text('View All'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        if (matchingProvider.isLoading)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  CircularProgressIndicator(
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Finding your perfect matches...',
                    style: AppTheme.bodyStyle.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (matchingProvider.matches.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withOpacity(0.1),
                  AppTheme.secondaryColor.withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.accentColor.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    PhosphorIcons.magnifyingGlass(PhosphorIconsStyle.fill),
                    color: AppTheme.accentColor,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'No matches yet',
                        style: AppTheme.titleStyle.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Add more favorites to find users with similar tastes!',
                        style: AppTheme.captionStyle.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Column(
            children: [
              // Stats card (clickable)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => context.push('/matching'),
                  borderRadius: BorderRadius.circular(16),
                  child: Ink(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          icon: PhosphorIcons.users(PhosphorIconsStyle.fill),
                          value: '${matchingProvider.matches.length}',
                          label: 'Total Matches',
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        _buildStatItem(
                          icon: PhosphorIcons.fire(PhosphorIconsStyle.fill),
                          value: '${matchingProvider.matches.where((m) => m.matchPercentage == 100).length}',
                          label: 'Perfect Matches',
                        ),
                        Icon(
                          PhosphorIcons.arrowRight(PhosphorIconsStyle.bold),
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTheme.headlineStyle.copyWith(
            color: Colors.white,
            fontSize: 24,
            height: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTheme.captionStyle.copyWith(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  void _showMovieDetails(dynamic movie) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => MovieDetailsModal(movie: movie),
    );
  }
}