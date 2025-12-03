import 'dart:io';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/movie_model.dart';

class MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MovieCard({
    super.key,
    required this.movie,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Poster image
          _buildPoster(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and menu
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          movie.title,
                          style: AppTheme.subtitleStyle.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildMenu(context),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Year & rating
                  Row(
                    children: [
                      if (movie.year != null && movie.year!.isNotEmpty) ...[
                        Icon(
                          PhosphorIcons.calendar(),
                          size: 14,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(movie.year!, style: AppTheme.captionStyle),
                        const SizedBox(width: 12),
                      ],
                      if (movie.rating != null) ...[
                        Icon(
                          PhosphorIcons.star(PhosphorIconsStyle.fill),
                          size: 14,
                          color: AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.rating!.toStringAsFixed(1),
                          style: AppTheme.captionStyle.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),

                  // Genres
                  if (movie.genres.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: movie.genres.take(3).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            genre,
                            style: AppTheme.captionStyle.copyWith(
                              color: AppTheme.primaryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],

                  // Description
                  if (movie.description != null && movie.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      movie.description!,
                      style: AppTheme.captionStyle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Created at
                  const SizedBox(height: 8),
                  Text(
                    'Added ${_formatDate(movie.createdAt)}',
                    style: AppTheme.captionStyle.copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build poster image with proper handling
  Widget _buildPoster() {
    // If posterUrl is null or empty, show placeholder
    if (movie.posterUrl == null || movie.posterUrl!.isEmpty) {
      return _buildPlaceholder();
    }

    // Check if posterUrl is a remote URL
    if (movie.posterUrl!.startsWith('http')) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Image.network(
          movie.posterUrl!,
          width: 100,
          height: 150,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 100,
              height: 150,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        ),
      );
    }

    // Otherwise, treat as local file path
    final file = File(movie.posterUrl!);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        child: Image.file(
          file,
          width: 100,
          height: 150,
          fit: BoxFit.cover,
        ),
      );
    }

    // Fallback to placeholder if file doesn't exist
    return _buildPlaceholder();
  }

  /// Placeholder widget
  Widget _buildPlaceholder() {
    return Container(
      width: 100,
      height: 150,
      color: AppTheme.textLight.withOpacity(0.1),
      child: Icon(PhosphorIcons.filmStrip(), size: 40, color: AppTheme.textLight),
    );
  }

  /// Popup menu (edit/delete)
  Widget _buildMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(PhosphorIcons.dotsThreeVertical(), color: AppTheme.textSecondary, size: 20),
      onSelected: (value) {
        switch (value) {
          case 'edit':
            onEdit();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(PhosphorIcons.pencil(), size: 18),
              const SizedBox(width: 8),
              const Text('Edit')
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(PhosphorIcons.trash(), color: AppTheme.errorColor, size: 18),
              const SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: AppTheme.errorColor)),
            ],
          ),
        ),
      ],
    );
  }

  /// Format createdAt to "X days/months/years ago"
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) return '${(difference.inDays / 365).floor()} years ago';
    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()} months ago';
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    return 'Today';
  }
}
