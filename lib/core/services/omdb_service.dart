import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OmdbService {
  final String _apiKey = dotenv.get("OMDB_API_KEY");
  final String _baseUrl = "http://www.omdbapi.com/";
  
  // Cache pour éviter les appels répétés
  final Map<String, Map<String, dynamic>> _cache = {};

  /// Récupérer un film par son ID IMDB
  Future<Map<String, dynamic>?> getMovieById(String imdbId) async {
    try {
      // Vérifier le cache
      if (_cache.containsKey(imdbId)) {
        print('[OMDB] ✅ Cache hit for $imdbId');
        return _cache[imdbId];
      }

      print('[OMDB] 🌐 Fetching movie: $imdbId');
      
      final url = Uri.parse('$_baseUrl?i=$imdbId&apikey=$_apiKey');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Vérifier si le film existe
        if (data['Response'] == 'True') {
          final movieData = {
            'id': imdbId,
            'title': data['Title'] ?? 'Unknown',
            'imageUrl': data['Poster'] != 'N/A' ? data['Poster'] : null,
            'year': data['Year'],
            'rating': data['imdbRating'],
            'plot': data['Plot'],
            'genre': data['Genre'],
          };
          
          // Mettre en cache
          _cache[imdbId] = movieData;
          
          print('[OMDB] ✅ Found: ${movieData['title']}');
          return movieData;
        } else {
          print('[OMDB] ❌ Movie not found: ${data['Error']}');
          return null;
        }
      } else {
        print('[OMDB] ❌ HTTP Error: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('[OMDB] ❌ Error: $e');
      return null;
    }
  }

  /// Récupérer plusieurs films par leurs IDs
  Future<List<Map<String, dynamic>>> getMoviesByIds(List<String> imdbIds) async {
    final movies = <Map<String, dynamic>>[];
    
    for (var id in imdbIds) {
      final movie = await getMovieById(id);
      if (movie != null) {
        movies.add(movie);
      }
      
      // Petit délai pour respecter le rate limit
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    return movies;
  }

  /// Vider le cache
  void clearCache() {
    _cache.clear();
  }
}