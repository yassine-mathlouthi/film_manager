import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MoviesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch all movies
  Future<List<Movie>> getAllMovies() async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Movie(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'],
          posterUrl: data['posterUrl'],
          year: data['year'],
          genres: data['genres'] != null
              ? List<String>.from(data['genres'] as List)
              : [],
          rating: data['rating'] != null 
              ? (data['rating'] as num).toDouble() 
              : null,
          createdAt: _parseDateTime(data['createdAt']),
          createdBy: data['createdBy'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch movies: $e');
    }
  }

  // Stream all movies (real-time updates)
  Stream<List<Movie>> streamMovies() {
    return _firestore
        .collection('movies')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Movie(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'],
          posterUrl: data['posterUrl'],
          year: data['year'],
          genres: data['genres'] != null
              ? List<String>.from(data['genres'] as List)
              : [],
          rating: data['rating'] != null 
              ? (data['rating'] as num).toDouble() 
              : null,
          createdAt: _parseDateTime(data['createdAt']),
          createdBy: data['createdBy'] ?? '',
        );
      }).toList();
    });
  }

  // Get movie by ID
  Future<Movie?> getMovieById(String movieId) async {
    try {
      final doc = await _firestore.collection('movies').doc(movieId).get();

      if (!doc.exists) return null;

      final data = doc.data()!;
      return Movie(
        id: doc.id,
        title: data['title'] ?? '',
        description: data['description'],
        posterUrl: data['posterUrl'],
        year: data['year'],
        genres: data['genres'] != null
            ? List<String>.from(data['genres'] as List)
            : [],
        rating: data['rating'] != null 
            ? (data['rating'] as num).toDouble() 
            : null,
        createdAt: _parseDateTime(data['createdAt']),
        createdBy: data['createdBy'] ?? '',
      );
    } catch (e) {
      throw Exception('Failed to fetch movie: $e');
    }
  }

  // Add new movie
  Future<String> addMovie(Movie movie) async {
    try {
      final docRef = await _firestore.collection('movies').add({
        'title': movie.title,
        'description': movie.description,
        'posterUrl': movie.posterUrl,
        'year': movie.year,
        'genres': movie.genres,
        'rating': movie.rating,
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': movie.createdBy,
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add movie: $e');
    }
  }

  // Update movie
  Future<void> updateMovie(String movieId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('movies').doc(movieId).update(updates);
    } catch (e) {
      throw Exception('Failed to update movie: $e');
    }
  }

  // Delete movie
  Future<void> deleteMovie(String movieId) async {
    try {
      await _firestore.collection('movies').doc(movieId).delete();
    } catch (e) {
      throw Exception('Failed to delete movie: $e');
    }
  }

  // Search movies by title
  Future<List<Movie>> searchMovies(String query) async {
    try {
      final snapshot = await _firestore.collection('movies').get();

      final allMovies = snapshot.docs.map((doc) {
        final data = doc.data();
        return Movie(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'],
          posterUrl: data['posterUrl'],
          year: data['year'],
          genres: data['genres'] != null
              ? List<String>.from(data['genres'] as List)
              : [],
          rating: data['rating'] != null 
              ? (data['rating'] as num).toDouble() 
              : null,
          createdAt: _parseDateTime(data['createdAt']),
          createdBy: data['createdBy'] ?? '',
        );
      }).toList();

      // Filter locally
      final lowerQuery = query.toLowerCase();
      return allMovies.where((movie) {
        final title = movie.title.toLowerCase();
        return title.contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search movies: $e');
    }
  }

  // Get movies by genre
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      final snapshot = await _firestore
          .collection('movies')
          .where('genres', arrayContains: genre)
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Movie(
          id: doc.id,
          title: data['title'] ?? '',
          description: data['description'],
          posterUrl: data['posterUrl'],
          year: data['year'],
          genres: data['genres'] != null
              ? List<String>.from(data['genres'] as List)
              : [],
          rating: data['rating'] != null 
              ? (data['rating'] as num).toDouble() 
              : null,
          createdAt: _parseDateTime(data['createdAt']),
          createdBy: data['createdBy'] ?? '',
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch movies by genre: $e');
    }
  }

  // Helper method to parse DateTime from various formats
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return DateTime.now();
      }
    } else if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    
    return DateTime.now();
  }
}