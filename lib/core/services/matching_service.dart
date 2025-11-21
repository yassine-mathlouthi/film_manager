import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_match_model.dart';
import 'playlist_service.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlaylistService _playlistService = PlaylistService();

  // Find users with matching preferences (>75% match)
  Future<List<UserMatch>> findMatches(String userId) async {
    try {
      // Get current user's playlist
      final userPlaylist = await _playlistService.getUserPlaylist(userId);
      if (userPlaylist == null || userPlaylist.movieIds.isEmpty) {
        return [];
      }

      // Get all users
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isActive', isEqualTo: true)
          .get();

      final matches = <UserMatch>[];

      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id == userId) continue; // Skip current user

        // Get other user's playlist
        final otherPlaylist = await _playlistService.getUserPlaylist(userDoc.id);
        if (otherPlaylist == null || otherPlaylist.movieIds.isEmpty) continue;

        // Calculate match percentage
        final commonMovies = userPlaylist.movieIds
            .where((movieId) => otherPlaylist.movieIds.contains(movieId))
            .toList();

        final totalMovies = {...userPlaylist.movieIds, ...otherPlaylist.movieIds}.length;
        final matchPercentage = (commonMovies.length / totalMovies) * 100;

        // Only include matches >75%
        if (matchPercentage > 75) {
          final userData = userDoc.data();
          matches.add(UserMatch(
            userId: userDoc.id,
            userName: '${userData['firstName']} ${userData['lastName']}',
            userPhoto: userData['profileImageUrl'],
            userAge: userData['age'],
            matchPercentage: matchPercentage,
            commonMovieIds: commonMovies,
          ));
        }
      }

      // Sort by match percentage (highest first)
      matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

      return matches;
    } catch (e) {
      throw 'Failed to find matches: $e';
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Failed to get user: $e';
    }
  }

  // Calculate match percentage between two users
  Future<double> calculateMatchPercentage(String userId1, String userId2) async {
    try {
      final playlist1 = await _playlistService.getUserPlaylist(userId1);
      final playlist2 = await _playlistService.getUserPlaylist(userId2);

      if (playlist1 == null || playlist2 == null) return 0;
      if (playlist1.movieIds.isEmpty || playlist2.movieIds.isEmpty) return 0;

      final commonMovies = playlist1.movieIds
          .where((movieId) => playlist2.movieIds.contains(movieId))
          .length;

      final totalMovies = {...playlist1.movieIds, ...playlist2.movieIds}.length;
      return (commonMovies / totalMovies) * 100;
    } catch (e) {
      return 0;
    }
  }
}
