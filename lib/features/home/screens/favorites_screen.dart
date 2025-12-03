import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/playlist_provider.dart';
import '../../../core/services/movie_service.dart';
import '../../../core/services/movies_service.dart';
import '../../../core/models/movie_model.dart';
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
  final MoviesService _moviesService = MoviesService();
  List<dynamic> _allApiMovies = []; // Movies from RapidAPI
  List<Movie> _allFirestoreMovies = []; // Movies from Firestore (admin-created)
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

      print('[FavoritesScreen] Loading favorites...');

      // Load favorites first
      if (authProvider.currentUser != null) {
        await playlistProvider.loadFavorites(authProvider.currentUser!.id);
      }

      final favoriteIds = playlistProvider.favoriteMovieIds;
      print('[FavoritesScreen] Favorite IDs: $favoriteIds');

      // Fetch movies from BOTH sources
      final apiMovies = await _movieService.getMovies();
      final firestoreMovies = await _moviesService.getAllMovies();
      
      print('[FavoritesScreen] API movies: ${apiMovies.length}');
      print('[FavoritesScreen] Firestore movies: ${firestoreMovies.length}');
      
      // Filter favorites from API movies
      final apiMoviesFavorites = apiMovies.where((movie) {
        final movieId = movie['id']?.toString() ?? '';
        return favoriteIds.contains(movieId);
      }).toList();
      
      // Filter favorites from Firestore movies (admin-created)
      final firestoreMoviesFavorites = firestoreMovies.where((movie) {
        return favoriteIds.contains(movie.id);
      }).toList();
      
      print('[FavoritesScreen] API favorites: ${apiMoviesFavorites.length}');
      print('[FavoritesScreen] Firestore favorites: ${firestoreMoviesFavorites.length}');
      
      // Convert Firestore movies to the same format as API movies for display
      final firestoreAsMaps = firestoreMoviesFavorites.map((movie) => {
        'id': movie.id,
        'title': movie.title,
        'description': movie.description,
        'image': movie.posterUrl,
        'year': movie.year,
        'genres': movie.genres,
        'rating': movie.rating,
        'isFromFirestore': true, // Flag to identify source
      }).toList();
      
      // Merge both lists
      final allFavorites = [...apiMoviesFavorites, ...firestoreAsMaps];
      print('[FavoritesScreen] Total favorites: ${allFavorites.length}');

      setState(() {
        _allApiMovies = apiMovies;
        _allFirestoreMovies = firestoreMovies;
        _favoriteMovies = allFavorites;
        _isLoadingMovies = false;
      });
    } catch (e) {
      print('[FavoritesScreen] ERROR: $e');
      setState(() {
        _error = e.toString();
        _isLoadingMovies = false;
      });
    }
  }

  void _updateFavoritesList() {
    final playlistProvider = context.read<PlaylistProvider>();
    final favoriteIds = playlistProvider.favoriteMovieIds;
    
    print('[FavoritesScreen] Updating favorites list. Favorite IDs: $favoriteIds');
    
    // Filter favorites from API movies
    final apiMoviesFavorites = _allApiMovies.where((movie) {
      final movieId = movie['id']?.toString() ?? '';
      return favoriteIds.contains(movieId);
    }).toList();
    
    // Filter favorites from Firestore movies
    final firestoreMoviesFavorites = _allFirestoreMovies.where((movie) {
      return favoriteIds.contains(movie.id);
    }).toList();
    
    // Convert Firestore movies to maps
    final firestoreAsMaps = firestoreMoviesFavorites.map((movie) => {
      'id': movie.id,
      'title': movie.title,
      'description': movie.description,
      'image': movie.posterUrl,
      'year': movie.year,
      'genres': movie.genres,
      'rating': movie.rating,
      'isFromFirestore': true,
    }).toList();
    
    setState(() {
      _favoriteMovies = [...apiMoviesFavorites, ...firestoreAsMaps];
    });
    
    print('[FavoritesScreen] Updated favorites count: ${_favoriteMovies.length}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingMovies
          ? const LoadingStateWidget()
          : _error != null
              ? ErrorStateWidget(
                  error: _error!,
                  onRetry: _loadMovies,
                )
              : _favoriteMovies.isEmpty
                  ? EmptyStateWidget(
                      icon: PhosphorIcons.heart(),
                      message: 'No favorite movies yet\nStart adding movies to your favorites!',
                    )
                  : RefreshIndicator(
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
