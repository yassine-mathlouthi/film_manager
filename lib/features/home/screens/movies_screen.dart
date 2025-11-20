import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/services/movie_service.dart';
import '../../../shared/widgets/movie_card.dart';
import '../../../shared/widgets/movie_details_modal.dart';
import '../../../shared/widgets/state_widgets.dart';

class MoviesScreen extends StatefulWidget {
  const MoviesScreen({super.key});

  @override
  State<MoviesScreen> createState() => _MoviesScreenState();
}

class _MoviesScreenState extends State<MoviesScreen> {
  final MovieService _movieService = MovieService();
  late Future<List<dynamic>> _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.getMovies();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<dynamic>>(
      future: _moviesFuture,
      builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            return _buildErrorState(snapshot.error.toString());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyState();
          }

          return _buildMoviesList(snapshot.data!);
        },
      );
  }

  Widget _buildLoadingState() {
    return const LoadingStateWidget();
  }

  Widget _buildErrorState(String error) {
    return ErrorStateWidget(
      error: error,
      onRetry: _refreshMovies,
    );
  }

  Widget _buildEmptyState() {
    return EmptyStateWidget(
      icon: PhosphorIcons.filmStrip(),
      message: 'No movies found',
    );
  }

  Widget _buildMoviesList(List<dynamic> movies) {
    return RefreshIndicator(
      onRefresh: _refreshMovies,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieCard(
            movie: movie,
            onTap: () => _showMovieDetails(movie),
          );
        },
      ),
    );
  }

  Future<void> _refreshMovies() async {
    setState(() {
      _moviesFuture = _movieService.getMovies();
    });
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
