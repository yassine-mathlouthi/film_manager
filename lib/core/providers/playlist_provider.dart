import 'package:flutter/material.dart';
import '../services/playlist_service.dart';

class PlaylistProvider with ChangeNotifier {
  final PlaylistService _playlistService = PlaylistService();
  Set<String> _favoriteMovieIds = {};
  bool _isLoading = false;

  Set<String> get favoriteMovieIds => _favoriteMovieIds;
  bool get isLoading => _isLoading;

  // Load user's favorite movies
  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final movieIds = await _playlistService.getPlaylistMovieIds(userId);
      _favoriteMovieIds = movieIds.toSet();
    } catch (e) {
      // Handle error silently or log to crash reporting
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Check if movie is favorite
  bool isFavorite(String movieId) {
    return _favoriteMovieIds.contains(movieId);
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String userId, String movieId) async {
    final wasFavorite = _favoriteMovieIds.contains(movieId);

    // Optimistic update
    if (wasFavorite) {
      _favoriteMovieIds.remove(movieId);
    } else {
      _favoriteMovieIds.add(movieId);
    }
    notifyListeners();

    try {
      if (wasFavorite) {
        await _playlistService.removeMovieFromPlaylist(userId, movieId);
      } else {
        await _playlistService.addMovieToPlaylist(userId, movieId);
      }
    } catch (e) {
      // Revert on error
      if (wasFavorite) {
        _favoriteMovieIds.add(movieId);
      } else {
        _favoriteMovieIds.remove(movieId);
      }
      notifyListeners();
      rethrow;
    }
  }

  // Add to favorites
  Future<void> addToFavorites(String userId, String movieId) async {
    if (_favoriteMovieIds.contains(movieId)) return;

    _favoriteMovieIds.add(movieId);
    notifyListeners();

    try {
      await _playlistService.addMovieToPlaylist(userId, movieId);
    } catch (e) {
      _favoriteMovieIds.remove(movieId);
      notifyListeners();
      rethrow;
    }
  }

  // Remove from favorites
  Future<void> removeFromFavorites(String userId, String movieId) async {
    if (!_favoriteMovieIds.contains(movieId)) return;

    _favoriteMovieIds.remove(movieId);
    notifyListeners();

    try {
      await _playlistService.removeMovieFromPlaylist(userId, movieId);
    } catch (e) {
      _favoriteMovieIds.add(movieId);
      notifyListeners();
      rethrow;
    }
  }

  void clear() {
    _favoriteMovieIds.clear();
    _isLoading = false;
    notifyListeners();
  }
}
