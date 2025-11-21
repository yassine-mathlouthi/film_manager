import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/playlist_provider.dart';
import '../../../core/services/movie_service.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/movie_details_modal.dart';
import '../../../shared/widgets/state_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final MovieService _movieService = MovieService();
  List<dynamic> _allMovies = [];
  List<dynamic> _favoriteMovies = [];
  bool _isLoadingMovies = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoadingMovies = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final playlistProvider = context.read<PlaylistProvider>();

      // Load favorites first
      if (authProvider.currentUser != null) {
        await playlistProvider.loadFavorites(authProvider.currentUser!.id);
      }

      // Fetch all movies from API
      final movies = await _movieService.getMovies();
      
      // Filter to show only favorites
      final favoriteIds = playlistProvider.favoriteMovieIds;
      final favorites = movies.where((movie) {
        final movieId = movie['id']?.toString() ?? '';
        return favoriteIds.contains(movieId);
      }).toList();

      setState(() {
        _allMovies = movies;
        _favoriteMovies = favorites;
        _isLoadingMovies = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoadingMovies = false;
      });
    }
  }

  void _updateFavoritesList() {
    final playlistProvider = context.read<PlaylistProvider>();
    final favoriteIds = playlistProvider.favoriteMovieIds;
    
    setState(() {
      _favoriteMovies = _allMovies.where((movie) {
        final movieId = movie['id']?.toString() ?? '';
        return favoriteIds.contains(movieId);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Consumer<PlaylistProvider>(
        builder: (context, playlistProvider, child) {
          if (_isLoadingMovies || playlistProvider.isLoading) {
            return const LoadingStateWidget();
          }

          if (_error != null) {
            return ErrorStateWidget(
              error: _error!,
              onRetry: _loadMovies,
            );
          }

          if (_favoriteMovies.isEmpty) {
            return EmptyStateWidget(
              icon: PhosphorIcons.heart(),
              message: 'No favorite movies yet\nStart adding movies to your favorites!',
            );
          }

          return RefreshIndicator(
            onRefresh: _loadMovies,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _favoriteMovies.length,
              itemBuilder: (context, index) {
                final movie = _favoriteMovies[index];
                return MovieCard(
                  movie: movie,
                  onTap: () => _showMovieDetails(movie),
                );
              },
            ),
          );
        },
      ),
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
    ).then((_) {
      // Refresh the list after closing modal in case favorites changed
      _updateFavoritesList();
    });
  }
}
