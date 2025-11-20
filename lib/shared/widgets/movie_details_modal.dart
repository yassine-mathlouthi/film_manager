import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_theme.dart';

class MovieDetailsModal extends StatelessWidget {
  final dynamic movie;

  const MovieDetailsModal({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    final String title = movie['primaryTitle'] ?? 'Unknown Title';
    final String? imageUrl = movie['primaryImage'];
    final String? type = movie['type'];
    final String? description = movie['description'];
    final String? originalTitle = movie['originalTitle'];
    final List<dynamic>? genres = movie['genres'];
    final double? rating = movie['averageRating']?.toDouble();
    final int? numVotes = movie['numVotes'];
    final int? year = movie['startYear'];
    final int? runtime = movie['runtimeMinutes'];
    final String? releaseDate = movie['releaseDate'];
    final String? contentRating = movie['contentRating'];
    final List<dynamic>? interests = movie['interests'];

    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDragHandle(),
              const SizedBox(height: 20),
              if (imageUrl != null) _buildPoster(imageUrl),
              const SizedBox(height: 20),
              _buildTitle(title),
              const SizedBox(height: 12),
              _buildMetrics(
                rating: rating,
                numVotes: numVotes,
                year: year,
                runtime: runtime,
              ),
              const SizedBox(height: 16),
              if (genres != null && genres.isNotEmpty)
                _buildGenresSection(genres),
              _buildDetailsSection(
                type: type,
                contentRating: contentRating,
                releaseDate: releaseDate,
                originalTitle: originalTitle,
                title: title,
              ),
              if (description != null)
                _buildDescriptionSection(description),
              if (interests != null && interests.isNotEmpty)
                _buildInterestsSection(interests),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildPoster(String imageUrl) {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.network(
          imageUrl,
          width: 200,
          height: 300,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: 200,
              height: 300,
              color: Colors.grey[300],
              child: Icon(
                PhosphorIcons.filmStrip(),
                size: 60,
                color: Colors.grey[600],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(title, style: AppTheme.headlineStyle);
  }

  Widget _buildMetrics({
    required double? rating,
    required int? numVotes,
    required int? year,
    required int? runtime,
  }) {
    return Row(
      children: [
        if (rating != null) ...[
          Icon(
            PhosphorIcons.star(PhosphorIconsStyle.fill),
            size: 24,
            color: Colors.amber,
          ),
          const SizedBox(width: 6),
          Text(
            rating.toStringAsFixed(1),
            style: AppTheme.titleStyle.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (numVotes != null) ...[
            const SizedBox(width: 4),
            Text(
              '(${_formatNumber(numVotes)})',
              style: AppTheme.bodyStyle.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
          const SizedBox(width: 16),
        ],
        if (year != null) ...[
          Icon(
            PhosphorIcons.calendar(),
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            year.toString(),
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
        if (runtime != null) ...[
          const SizedBox(width: 16),
          Icon(
            PhosphorIcons.clock(),
            size: 20,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 4),
          Text(
            '${runtime}min',
            style: AppTheme.bodyStyle.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGenresSection(List<dynamic> genres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: genres.map((genre) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                genre.toString(),
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailsSection({
    required String? type,
    required String? contentRating,
    required String? releaseDate,
    required String? originalTitle,
    required String title,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (type != null) _buildDetailRow('Type', type),
        if (contentRating != null) _buildDetailRow('Rating', contentRating),
        if (releaseDate != null) _buildDetailRow('Release Date', releaseDate),
        if (originalTitle != null && originalTitle != title)
          _buildDetailRow('Original Title', originalTitle),
      ],
    );
  }

  Widget _buildDescriptionSection(String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Description',
          style: AppTheme.titleStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Text(description, style: AppTheme.bodyStyle),
      ],
    );
  }

  Widget _buildInterestsSection(List<dynamic> interests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(
          'Tags',
          style: AppTheme.titleStyle.copyWith(fontSize: 18),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: interests.map((interest) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                interest.toString(),
                style: AppTheme.captionStyle.copyWith(
                  color: Colors.grey[700],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTheme.bodyStyle.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}
