import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/providers/movies_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/models/movie_model.dart';
import '../../../shared/widgets/confirmation_dialog.dart';
import '../widgets/movies_search_filter.dart';
import '../widgets/movie_card.dart';
import '../widgets/empty_movies_view.dart';
import '../widgets/error_view.dart';
import '../widgets/add_edit_movie_dialog.dart';

class MoviesListScreen extends StatefulWidget {
  const MoviesListScreen({super.key});

  @override
  State<MoviesListScreen> createState() => _MoviesListScreenState();
}

class _MoviesListScreenState extends State<MoviesListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedGenre = 'all';
  List<Movie> _filteredMovies = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MoviesProvider>(context, listen: false).fetchMovies();
    });
    _searchController.addListener(_filterMovies);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterMovies() {
    final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
    List<Movie> movies = moviesProvider.movies;

    // Filter by genre
    if (_selectedGenre != 'all') {
      movies = movies.where((movie) => movie.genres.contains(_selectedGenre)).toList();
    }

    // Filter by search query
    final query = _searchController.text;
    if (query.isNotEmpty) {
      movies = movies.where((movie) {
        final title = movie.title.toLowerCase();
        final searchQuery = query.toLowerCase();
        return title.contains(searchQuery);
      }).toList();
    }

    setState(() {
      _filteredMovies = movies;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies Management'),
        leading: IconButton(
          icon: Icon(PhosphorIcons.arrowLeft()),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: Icon(PhosphorIcons.plus()),
            onPressed: () => _showAddMovieDialog(),
          ),
        ],
      ),
      body: Consumer<MoviesProvider>(
        builder: (context, moviesProvider, child) {
          if (moviesProvider.isLoading && moviesProvider.movies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (moviesProvider.error != null) {
            return ErrorView(
              errorMessage: moviesProvider.error,
              onRetry: () => moviesProvider.fetchMovies(),
            );
          }

          // Update filtered movies when movies list changes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_filteredMovies.isEmpty && moviesProvider.movies.isNotEmpty) {
              _filterMovies();
            }
          });

          return Column(
            children: [
              // Search and filter section
              MoviesSearchFilter(
                searchController: _searchController,
                selectedGenre: _selectedGenre,
                onGenreChanged: (value) {
                  setState(() {
                    _selectedGenre = value;
                  });
                  _filterMovies();
                },
              ),

              // Movies count
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: AppTheme.textLight.withOpacity(0.1),
                child: Text(
                  'Total: ${_filteredMovies.length} movies',
                  style: AppTheme.captionStyle,
                ),
              ),

              // Movies list
              Expanded(
                child: _filteredMovies.isEmpty
                    ? const EmptyMoviesView()
                    : RefreshIndicator(
                        onRefresh: () => moviesProvider.fetchMovies(),
                        child: ListView.builder(
                          itemCount: _filteredMovies.length,
                          itemBuilder: (context, index) {
                            final movie = _filteredMovies[index];
                            return MovieCard(
                              movie: movie,
                              onEdit: () => _showEditMovieDialog(movie),
                              onDelete: () => _showDeleteMovieDialog(
                                movie,
                                moviesProvider,
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddMovieDialog() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUser = authProvider.currentUser;
    
    if (currentUser == null) return;

    final result = await showDialog<Movie>(
      context: context,
      builder: (context) => AddEditMovieDialog(
        createdBy: currentUser.id,
      ),
    );

    if (result != null && mounted) {
      final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
      final success = await moviesProvider.addMovie(result);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.title} has been added'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _filterMovies();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              moviesProvider.error ?? 'Failed to add movie',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showEditMovieDialog(Movie movie) async {
    final result = await showDialog<Movie>(
      context: context,
      builder: (context) => AddEditMovieDialog(
        movie: movie,
        createdBy: movie.createdBy,
      ),
    );

    if (result != null && mounted) {
      final moviesProvider = Provider.of<MoviesProvider>(context, listen: false);
      final success = await moviesProvider.updateMovie(
        movie.id,
        result.toJson(),
      );
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.title} has been updated'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _filterMovies();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              moviesProvider.error ?? 'Failed to update movie',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showDeleteMovieDialog(Movie movie, MoviesProvider moviesProvider) async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Movie',
      message: 'Are you sure you want to delete "${movie.title}"? This action cannot be undone.',
      confirmText: 'Delete',
      confirmColor: AppTheme.errorColor,
      icon: PhosphorIcons.trash(),
    );

    if (confirm == true && mounted) {
      final success = await moviesProvider.deleteMovie(movie.id);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${movie.title} has been deleted'),
            backgroundColor: AppTheme.successColor,
          ),
        );
        _filterMovies();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              moviesProvider.error ?? 'Failed to delete movie',
            ),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}