import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieService {
  final String apiKey = dotenv.get("RAPID_API_KEY");
  final String apiHost = dotenv.get("RAPID_API_HOST");

  // Cache pour éviter les appels répétés
  final Map<String, dynamic> _movieCache = {};

  Future<List<dynamic>> getMovies() async {
    final url = Uri.parse("https://$apiHost/api/imdb/most-popular-movies");
    print('[MovieService] Fetching movies from: $url');

    final response = await http.get(
      url,
      headers: {
        "X-RapidAPI-Key": apiKey,
        "X-RapidAPI-Host": apiHost,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data is List) {
        return data;
      }
      return [];
    } else {
      throw Exception("Failed to fetch movies: ${response.body}");
    }
  }

  // NOUVELLE MÉTHODE: Récupérer un film par son ID
  Future<Map<String, dynamic>?> getMovieById(String movieId) async {
    try {
      // Vérifier le cache d'abord
      if (_movieCache.containsKey(movieId)) {
        print('[MovieService] ✅ Movie $movieId found in cache');
        return _movieCache[movieId];
      }

      print('[MovieService] 🔍 Fetching movie details for ID: $movieId');
      
      final url = Uri.parse("https://$apiHost/api/imdb/title/$movieId");
      
      final response = await http.get(
        url,
        headers: {
          "X-RapidAPI-Key": apiKey,
          "X-RapidAPI-Host": apiHost,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Transformer les données au format attendu
        final movieData = {
          'id': movieId,
          'title': data['title'] ?? 'Unknown',
          'imageUrl': data['image']?['url'] ?? data['primaryImage']?['url'],
          'year': data['releaseYear']?.toString() ?? data['year']?.toString(),
          'rating': data['rating']?['averageRating']?.toString() ?? data['averageRating']?.toString(),
          'description': data['plot'] ?? data['plotSummary']?['text'],
          'genre': data['genres'] ?? [],
        };

        // Mettre en cache
        _movieCache[movieId] = movieData;
        
        print('[MovieService] ✅ Movie fetched: ${movieData['title']}');
        return movieData;
      } else if (response.statusCode == 429) {
        print('[MovieService] ⚠️ Rate limit exceeded for movie $movieId');
        // Retourner un placeholder avec l'ID
        return {
          'id': movieId,
          'title': 'Movie $movieId',
          'imageUrl': null,
        };
      } else {
        print('[MovieService] ❌ Failed to fetch movie $movieId: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[MovieService] ❌ Error fetching movie $movieId: $e');
      // Retourner un placeholder en cas d'erreur
      return {
        'id': movieId,
        'title': 'Movie $movieId',
        'imageUrl': null,
      };
    }
  }

  // Récupérer plusieurs films par leurs IDs
  Future<List<Map<String, dynamic>>> getMoviesByIds(List<String> movieIds) async {
    final movies = <Map<String, dynamic>>[];
    
    print('[MovieService] 📥 Fetching ${movieIds.length} movies');
    
    for (var movieId in movieIds) {
      try {
        final movie = await getMovieById(movieId);
        if (movie != null) {
          movies.add(movie);
        }
        
        // Petit délai pour éviter le rate limiting
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (e) {
        print('[MovieService] ❌ Error fetching movie $movieId: $e');
        // Ajouter un placeholder
        movies.add({
          'id': movieId,
          'title': 'Movie $movieId',
          'imageUrl': null,
        });
      }
    }
    
    print('[MovieService] ✅ Fetched ${movies.length} movies');
    return movies;
  }

  // Vider le cache si nécessaire
  void clearCache() {
    _movieCache.clear();
    print('[MovieService] 🗑️ Cache cleared');
  }
}