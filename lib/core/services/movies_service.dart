import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';
import './cloudinary_service.dart';

class MoviesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CloudinaryService _cloudinaryService = CloudinaryService();

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

  // Get multiple movies by IDs
  Future<List<Movie>> getMoviesByIds(List<String> movieIds) async {
    try {
      print('[MoviesService] getMoviesByIds called with ${movieIds.length} IDs');
      print('[MoviesService] Movie IDs: $movieIds');
      
      if (movieIds.isEmpty) {
        print('[MoviesService] No movie IDs provided');
        return [];
      }
      
      final movies = <Movie>[];
      
      // Fetch movies in batches (Firestore has a limit of 10 for 'in' queries)
      for (var i = 0; i < movieIds.length; i += 10) {
        final batch = movieIds.skip(i).take(10).toList();
        print('[MoviesService] Fetching batch ${i ~/ 10 + 1}: $batch');
        
        final snapshot = await _firestore
            .collection('movies')
            .where(FieldPath.documentId, whereIn: batch)
            .get();
        
        print('[MoviesService] Batch returned ${snapshot.docs.length} documents');
        
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final movie = Movie(
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
          movies.add(movie);
          print('[MoviesService] Added movie: ${movie.title}');
        }
      }
      
      print('[MoviesService] Total movies fetched: ${movies.length}');
      return movies;
    } catch (e) {
      print('[MoviesService] ERROR in getMoviesByIds: $e');
      throw Exception('Failed to fetch movies: $e');
    }
  }

  // Add new movie
  Future<String> addMovie(Movie movie) async {
    try {
      String? posterUrl = movie.posterUrl;
      
      // If posterUrl is a local file path, upload to Cloudinary
      if (posterUrl != null && posterUrl.isNotEmpty && !posterUrl.startsWith('http')) {
        final uploadedUrl = await _cloudinaryService.uploadMoviePoster(posterUrl);
        if (uploadedUrl != null) {
          posterUrl = uploadedUrl;
        }
      }
      
      final docRef = await _firestore.collection('movies').add({
        'title': movie.title,
        'description': movie.description,
        'posterUrl': posterUrl,
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
      // If posterUrl is a local file path, upload to Cloudinary
      if (updates.containsKey('posterUrl')) {
        final posterUrl = updates['posterUrl'] as String?;
        if (posterUrl != null && posterUrl.isNotEmpty && !posterUrl.startsWith('http')) {
          final uploadedUrl = await _cloudinaryService.uploadMoviePoster(posterUrl);
          if (uploadedUrl != null) {
            updates['posterUrl'] = uploadedUrl;
          }
        }
      }
      
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