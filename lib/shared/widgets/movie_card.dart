import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/ui_constants.dart';
import '../../core/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final dynamic movie;
  final VoidCallback onTap;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Handle both Movie objects and Map (for API movies)
    String title;
    String? imageUrl;
    List<dynamic>? genres;
    double? rating;
    int? year;

    if (movie is Movie) {
      // Firestore movie (admin-created)
      title = movie.title;
      imageUrl = movie.posterUrl;
      genres = movie.genres;
      rating = movie.rating;
      year = movie.year;
    } else if (movie is Map) {
      // API movie or converted Firestore movie
      title = movie['title'] ?? movie['primaryTitle'] ?? 'Unknown Title';
      imageUrl = movie['image'] ?? movie['posterUrl'] ?? movie['primaryImage'];
      genres = movie['genres'];
      
      // Handle rating conversion (could be double, int, or String)
      final ratingValue = movie['rating'] ?? movie['averageRating'];
      if (ratingValue != null) {
        if (ratingValue is num) {
          rating = ratingValue.toDouble();
        } else if (ratingValue is String) {
          rating = double.tryParse(ratingValue);
        }
      } else {
        rating = null;
      }
      
      // Handle year conversion (could be int or String)
      final yearValue = movie['year'] ?? movie['startYear'];
      if (yearValue != null) {
        if (yearValue is int) {
          year = yearValue;
        } else if (yearValue is String) {
          year = int.tryParse(yearValue);
        }
      } else {
        year = null;
      }
    } else {
      title = 'Unknown Title';
      imageUrl = null;
      genres = null;
      rating = null;
      year = null;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: UIConstants.spacingXLarge),
      elevation: UIConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusLarge),
        child: Padding(
          padding: const EdgeInsets.all(UIConstants.paddingMedium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPoster(imageUrl),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMovieInfo(
                  title: title,
                  rating: rating,
                  year: year,
                  genres: genres,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPoster(String? imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
      child: imageUrl != null
          ? Image.network(
              imageUrl,
              width: UIConstants.moviePosterWidth,
              height: UIConstants.moviePosterHeight,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholderPoster();
              },
            )
          : _buildPlaceholderPoster(),
    );
  }

  Widget _buildPlaceholderPoster() {
    return Container(
      width: UIConstants.moviePosterWidth,
      height: UIConstants.moviePosterHeight,
      color: Colors.grey[300],
      child: Icon(
        PhosphorIcons.filmStrip(),
        size: UIConstants.iconSizeXLarge,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildMovieInfo({
    required String title,
    required double? rating,
    required int? year,
    required List<dynamic>? genres,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.titleStyle.copyWith(fontSize: 16),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        _buildRatingAndYear(rating: rating, year: year),
        const SizedBox(height: 8),
        if (genres != null && genres.isNotEmpty) _buildGenres(genres),
      ],
    );
  }

  Widget _buildRatingAndYear({
    required double? rating,
    required int? year,
  }) {
    return Row(
      children: [
        if (rating != null) ...[
          Icon(
            PhosphorIcons.star(PhosphorIconsStyle.fill),
            size: 16,
            color: Colors.amber,
          ),
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: AppTheme.bodyStyle.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (year != null) ...[
          Icon(
            PhosphorIcons.calendar(),
            size: 16,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            year.toString(),
            style: AppTheme.bodyStyle.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenres(List<dynamic> genres) {
    return Wrap(
      spacing: UIConstants.spacingSmall,
      runSpacing: UIConstants.spacingSmall,
      children: genres.take(UIConstants.maxGenresOnCard).map((genre) {
        return GenreChip(genre: genre.toString());
      }).toList(),
    );
  }
}

class GenreChip extends StatelessWidget {
  final String genre;

  const GenreChip({
    super.key,
    required this.genre,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.spacingMedium,
        vertical: UIConstants.spacingXSmall,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(UIConstants.borderRadiusMedium),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        genre,
        style: AppTheme.captionStyle.copyWith(
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
