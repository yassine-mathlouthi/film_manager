// Modèle simple pour afficher les films (RapidAPI ou Firestore)
class SimpleMovieInfo {
  final String id;
  final String title;
  final String? imageUrl;
  final String source; // 'firestore' ou 'rapidapi'

  const SimpleMovieInfo({
    required this.id,
    required this.title,
    this.imageUrl,
    this.source = 'unknown',
  });

  // Créer depuis RapidAPI response
  factory SimpleMovieInfo.fromRapidApi(Map<String, dynamic> json) {
    return SimpleMovieInfo(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Unknown',
      imageUrl: json['imageUrl'] ?? json['image']?['url'],
      source: 'rapidapi',
    );
  }

  // Créer depuis Movie Firestore
  factory SimpleMovieInfo.fromMovie(dynamic movie) {
    return SimpleMovieInfo(
      id: movie.id,
      title: movie.title,
      imageUrl: movie.posterUrl,
      source: 'firestore',
    );
  }
}