class Movie {
  final String id;
  final String title;
  final String? description;
  final String? posterUrl;
  final String? year;
  final List<String> genres;
  final double? rating;
  final DateTime createdAt;
  final String createdBy; // Admin who added it

  const Movie({
    required this.id,
    required this.title,
    this.description,
    this.posterUrl,
    this.year,
    this.genres = const [],
    this.rating,
    required this.createdAt,
    required this.createdBy,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      posterUrl: json['posterUrl'] as String?,
      year: json['year'] as String?,
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : [],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      createdBy: json['createdBy'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'posterUrl': posterUrl,
      'year': year,
      'genres': genres,
      'rating': rating,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  Movie copyWith({
    String? id,
    String? title,
    String? description,
    String? posterUrl,
    String? year,
    List<String>? genres,
    double? rating,
    DateTime? createdAt,
    String? createdBy,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      year: year ?? this.year,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
    );
  }
}
