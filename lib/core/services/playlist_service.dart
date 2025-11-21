import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/playlist_model.dart';

class PlaylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get user's playlist (stores RapidAPI movie IDs)
  Future<Playlist?> getUserPlaylist(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('playlists')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Playlist.fromJson({...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
      }
      
      // Create playlist if doesn't exist
      return await _createPlaylist(userId);
    } catch (e) {
      throw 'Failed to get playlist: $e';
    }
  }

  // Create playlist for user
  Future<Playlist> _createPlaylist(String userId) async {
    try {
      final playlistData = {
        'userId': userId,
        'movieIds': [],
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      };

      final docRef = await _firestore.collection('playlists').add(playlistData);
      return Playlist.fromJson({...playlistData, 'id': docRef.id});
    } catch (e) {
      throw 'Failed to create playlist: $e';
    }
  }

  // Add movie to playlist
  Future<void> addMovieToPlaylist(String userId, String movieId) async {
    try {
      final playlist = await getUserPlaylist(userId);
      if (playlist == null) return;

      if (!playlist.movieIds.contains(movieId)) {
        final updatedMovieIds = [...playlist.movieIds, movieId];
        await _firestore.collection('playlists').doc(playlist.id).update({
          'movieIds': updatedMovieIds,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw 'Failed to add movie to playlist: $e';
    }
  }

  // Remove movie from playlist
  Future<void> removeMovieFromPlaylist(String userId, String movieId) async {
    try {
      final playlist = await getUserPlaylist(userId);
      if (playlist == null) return;

      if (playlist.movieIds.contains(movieId)) {
        final updatedMovieIds = playlist.movieIds.where((id) => id != movieId).toList();
        await _firestore.collection('playlists').doc(playlist.id).update({
          'movieIds': updatedMovieIds,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw 'Failed to remove movie from playlist: $e';
    }
  }

  // Get movie IDs in user's playlist
  Future<List<String>> getPlaylistMovieIds(String userId) async {
    try {
      final playlist = await getUserPlaylist(userId);
      return playlist?.movieIds ?? [];
    } catch (e) {
      throw 'Failed to get playlist movie IDs: $e';
    }
  }

  // Check if movie is in playlist
  Future<bool> isMovieInPlaylist(String userId, String movieId) async {
    try {
      final playlist = await getUserPlaylist(userId);
      return playlist?.movieIds.contains(movieId) ?? false;
    } catch (e) {
      return false;
    }
  }

  // Get playlist stream
  Stream<Playlist?> getPlaylistStream(String userId) {
    return _firestore
        .collection('playlists')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return Playlist.fromJson({...snapshot.docs.first.data(), 'id': snapshot.docs.first.id});
          }
          return null;
        });
  }
}
