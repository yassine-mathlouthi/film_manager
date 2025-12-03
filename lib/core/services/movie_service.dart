import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MovieService {
  final String apiKey = dotenv.get("RAPID_API_KEY");
  final String apiHost = dotenv.get("RAPID_API_HOST");

  Future<List<dynamic>> getMovies() async {
    final url = Uri.parse("https://$apiHost/api/imdb/most-popular-movies");

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
}
