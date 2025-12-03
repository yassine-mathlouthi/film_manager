import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_theme.dart';

class MoviesSearchFilter extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedGenre;
  final ValueChanged<String> onGenreChanged;

  const MoviesSearchFilter({
    super.key,
    required this.searchController,
    required this.selectedGenre,
    required this.onGenreChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search movies...',
              prefixIcon: Icon(PhosphorIcons.magnifyingGlass()),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(PhosphorIcons.x()),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.textLight),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.textLight.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
            ),
          ),
          const SizedBox(height: 12),
          
          // Genre filter
          Row(
            children: [
              Icon(
                PhosphorIcons.funnel(),
                size: 20,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'Genre:',
                style: AppTheme.bodyStyle.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildGenreChip('all', 'All'),
                      _buildGenreChip('Action', 'Action'),
                      _buildGenreChip('Comedy', 'Comedy'),
                      _buildGenreChip('Drama', 'Drama'),
                      _buildGenreChip('Horror', 'Horror'),
                      _buildGenreChip('Sci-Fi', 'Sci-Fi'),
                      _buildGenreChip('Romance', 'Romance'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenreChip(String value, String label) {
    final isSelected = selectedGenre == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onGenreChanged(value),
        backgroundColor: AppTheme.surfaceColor,
        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
        checkmarkColor: AppTheme.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          fontSize: 12,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      ),
    );
  }
}