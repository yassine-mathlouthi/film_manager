import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/user_match_model.dart';
import 'playlist_service.dart';

class MatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final PlaylistService _playlistService = PlaylistService();

  /// Find users with matching preferences (>75% match) and save to Firestore
  Future<List<UserMatch>> findMatches(String userId) async {
    try {
      // Get current user's playlist
      final userPlaylist = await _playlistService.getUserPlaylist(userId);
      
      if (userPlaylist == null || userPlaylist.movieIds.isEmpty) {
        await _clearUserMatches(userId);
        return [];
      }

      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();
      final matches = <UserMatch>[];

      for (var userDoc in usersSnapshot.docs) {
        if (userDoc.id == userId) continue;

        final userData = userDoc.data();
        if (userData['isActive'] == false) continue;

        final otherPlaylist = await _playlistService.getUserPlaylist(userDoc.id);
        if (otherPlaylist == null || otherPlaylist.movieIds.isEmpty) continue;

        // Calculate match
        final commonMovies = userPlaylist.movieIds
            .where((movieId) => otherPlaylist.movieIds.contains(movieId))
            .toList();

        if (commonMovies.isEmpty) continue;

        final user1MatchPercent = (commonMovies.length / userPlaylist.movieIds.length) * 100;
        final user2MatchPercent = (commonMovies.length / otherPlaylist.movieIds.length) * 100;
        final matchPercentage = (user1MatchPercent + user2MatchPercent) / 2;

        if (matchPercentage > 75) {
          final userName = '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();
          
          final match = UserMatch(
            userId: userDoc.id,
            userName: userName.isNotEmpty ? userName : 'Unknown User',
            userPhoto: userData['profileImageUrl'] as String?,
            userAge: userData['age'] as int?,
            matchPercentage: matchPercentage,
            commonMovieIds: commonMovies,
          );
          
          matches.add(match);
        }
      }

      // Sort by match percentage
      matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));

      // Save matches to Firestore
      await _saveUserMatches(userId, matches);

      return matches;
    } catch (e) {
      throw 'Failed to find matches: $e';
    }
  }

  /// Save user matches to Firestore
  Future<void> _saveUserMatches(String userId, List<UserMatch> matches) async {
    try {
      final userMatchesRef = _firestore.collection('user_matches').doc(userId);
      
      await userMatchesRef.set({
        'userId': userId,
        'matches': matches.map((match) => match.toJson()).toList(),
        'totalMatches': matches.length,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Don't throw - matching can work without saving
    }
  }

  /// Clear user matches
  Future<void> _clearUserMatches(String userId) async {
    try {
      await _firestore.collection('user_matches').doc(userId).delete();
    } catch (e) {
      // Ignore errors when clearing
    }
  }

  /// Get saved matches from Firestore
  Future<List<UserMatch>> getSavedMatches(String userId) async {
    try {
      final doc = await _firestore.collection('user_matches').doc(userId).get();
      
      if (!doc.exists) {
        return [];
      }

      final data = doc.data()!;
      final matchesData = data['matches'] as List<dynamic>;
      
      final matches = matchesData
          .map((matchData) => UserMatch.fromJson(matchData as Map<String, dynamic>))
          .toList();
      
      return matches;
    } catch (e) {
      return [];
    }
  }

  // Get user by ID
  Future<User?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        final data = doc.data()!;
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          firstName: data['firstName'] ?? '',
          lastName: data['lastName'] ?? '',
          role: data['role'] ?? 'user',
          isActive: data['isActive'] ?? true,
          age: data['age'],
          profileImageUrl: data['profileImageUrl'],
          createdAt: _parseDateTime(data['createdAt']),
          lastLoginAt: data['lastLoginAt'] != null 
              ? _parseDateTime(data['lastLoginAt']) 
              : null,
        );
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

      final user1MatchPercent = (commonMovies / playlist1.movieIds.length) * 100;
      final user2MatchPercent = (commonMovies / playlist2.movieIds.length) * 100;

      return (user1MatchPercent + user2MatchPercent) / 2;
    } catch (e) {
      return 0;
    }
  }

  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    }
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return DateTime.now();
  }
}