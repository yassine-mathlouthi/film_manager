//for movies management by admin !

import 'package:flutter/foundation.dart';
import '../models/movie_model.dart';
import '../services/movies_service.dart';

class MoviesProvider extends ChangeNotifier {
  final MoviesService _moviesService = MoviesService();
  
  List<Movie> _movies = [];
  bool _isLoading = false;
  String? _error;

  List<Movie> get movies => _movies;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Fetch all movies
  Future<void> fetchMovies() async {
    _setLoading(true);
    _clearError();

    try {
      _movies = await _moviesService.getAllMovies();
    } catch (e) {
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Add new movie
  Future<bool> addMovie(Movie movie) async {
    _setLoading(true);
    _clearError();

    try {
      final movieId = await _moviesService.addMovie(movie);
      final newMovie = movie.copyWith(id: movieId);
      _movies.insert(0, newMovie);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Update movie
  Future<bool> updateMovie(String movieId, Map<String, dynamic> updates) async {
    _setLoading(true);
    _clearError();

    try {
      await _moviesService.updateMovie(movieId, updates);
      
      // Update local state
      final index = _movies.indexWhere((movie) => movie.id == movieId);
      if (index != -1) {
        final updatedMovie = _movies[index].copyWith(
          title: updates['title'] ?? _movies[index].title,
          description: updates['description'] ?? _movies[index].description,
          posterUrl: updates['posterUrl'] ?? _movies[index].posterUrl,
          year: updates['year'] ?? _movies[index].year,
          genres: updates['genres'] ?? _movies[index].genres,
          rating: updates['rating'] ?? _movies[index].rating,
        );
        _movies[index] = updatedMovie;
        notifyListeners();
      }
      
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Delete movie
  Future<bool> deleteMovie(String movieId) async {
    _setLoading(true);
    _clearError();

    try {
      await _moviesService.deleteMovie(movieId);
      _movies.removeWhere((movie) => movie.id == movieId);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Search movies
  List<Movie> searchMovies(String query) {
    if (query.isEmpty) return _movies;

    return _movies.where((movie) {
      final title = movie.title.toLowerCase();
      final searchQuery = query.toLowerCase();
      return title.contains(searchQuery);
    }).toList();
  }

  // Filter movies by genre
  List<Movie> filterMoviesByGenre(String genre) {
    if (genre == 'all') return _movies;
    return _movies.where((movie) => movie.genres.contains(genre)).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }
}