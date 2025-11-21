import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/playlist_provider.dart';
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
        );
      },
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
