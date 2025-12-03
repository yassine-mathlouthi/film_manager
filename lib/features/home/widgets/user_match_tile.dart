import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/models/user_match_model.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/movies_service.dart';

class UserMatchTile extends StatefulWidget {
  final UserMatch userMatch;

  const UserMatchTile({super.key, required this.userMatch});

  @override
  State<UserMatchTile> createState() => _UserMatchTileState();
}

class _UserMatchTileState extends State<UserMatchTile> {
  bool _isExpanded = false;
  List<Movie> _commonMovies = [];
  bool _isLoadingMovies = false;

  @override
  void initState() {
    super.initState();
    if (widget.userMatch.commonMovieIds.isNotEmpty) {
      _loadCommonMovies();
    }
  }

  Future<void> _loadCommonMovies() async {
    setState(() => _isLoadingMovies = true);
    
    print('[UserMatchTile] Loading ${widget.userMatch.commonMovieIds.length} common movies');
    print('[UserMatchTile] Movie IDs: ${widget.userMatch.commonMovieIds}');

    try {
      final moviesService = MoviesService();
      final movies = await moviesService.getMoviesByIds(widget.userMatch.commonMovieIds);
      
      print('[UserMatchTile] Successfully loaded ${movies.length} movies');
      for (var movie in movies) {
        print('[UserMatchTile] Movie: ${movie.title} - ${movie.posterUrl}');
      }

      if (mounted) {
        setState(() {
          _commonMovies = movies;
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      print('[UserMatchTile] ERROR loading movies: $e');
      if (mounted) {
        setState(() => _isLoadingMovies = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getMatchColor().withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() => _isExpanded = !_isExpanded);
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile Photo
                  Stack(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _getMatchColor(),
                              _getMatchColor().withOpacity(0.7),
                            ],
                          ),
                        ),
                        child: widget.userMatch.userPhoto != null
                            ? ClipOval(
                                child: Image.network(
                                  widget.userMatch.userPhoto!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildDefaultAvatar();
                                  },
                                ),
                              )
                            : _buildDefaultAvatar(),
                      ),
                      // Match indicator
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _getMatchColor(),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            _getMatchIcon(),
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  
                  // User Info - AVEC EXPANDED POUR ÉVITER LE DÉBORDEMENT
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.userMatch.userName,
                          style: AppTheme.subtitleStyle.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
                              size: 14,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                '${widget.userMatch.commonMovieIds.length} movie${widget.userMatch.commonMovieIds.length > 1 ? 's' : ''} in common',
                                style: AppTheme.captionStyle.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (widget.userMatch.userAge != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                PhosphorIconsRegular.cake,
                                size: 14,
                                color: AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${widget.userMatch.userAge} years old',
                                style: AppTheme.captionStyle.copyWith(fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Match Badge - TAILLE FIXE
                  Container(
                    width: 70,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _getMatchColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${widget.userMatch.matchPercentage.round()}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _getMatchLabel(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Expand Icon
                  Icon(
                    _isExpanded 
                        ? PhosphorIconsRegular.caretUp 
                        : PhosphorIconsRegular.caretDown,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded Section - Common Movies
          if (_isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _getMatchColor().withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        PhosphorIconsRegular.popcorn,
                        size: 20,
                        color: _getMatchColor(),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Movies in Common',
                        style: AppTheme.subtitleStyle.copyWith(
                          fontSize: 16,
                          color: _getMatchColor(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (_isLoadingMovies)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_commonMovies.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Could not load movie details',
                          style: AppTheme.captionStyle,
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 130,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _commonMovies.length,
                        itemBuilder: (context, index) {
                          final movie = _commonMovies[index];
                          return _buildMovieCard(movie);
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(Movie movie) {
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.posterUrl != null
                  ? Image.network(
                      movie.posterUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildMoviePlaceholder();
                      },
                    )
                  : _buildMoviePlaceholder(),
            ),
          ),
          const SizedBox(height: 6),
          // Movie Title
          Text(
            movie.title,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMoviePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          PhosphorIcons.filmStrip(PhosphorIconsStyle.fill),
          color: Colors.grey[500],
          size: 32,
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    final initials = widget.userMatch.userName
        .split(' ')
        .map((e) => e.isNotEmpty ? e[0] : '')
        .take(2)
        .join()
        .toUpperCase();
    
    return Center(
      child: Text(
        initials.isNotEmpty ? initials : '?',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _getMatchColor() {
    final percentage = widget.userMatch.matchPercentage;
    if (percentage == 100) return const Color(0xFFEF4444); // ROUGE au lieu de rose
    if (percentage >= 90) return const Color(0xFFF59E0B); // Orange - Excellent
    if (percentage >= 80) return const Color(0xFF10B981); // Green - Great
    return const Color(0xFF6366F1); // Blue - Good
  }

  IconData _getMatchIcon() {
    final percentage = widget.userMatch.matchPercentage;
    if (percentage == 100) return PhosphorIconsFill.heart;
    if (percentage >= 90) return PhosphorIconsFill.fire;
    if (percentage >= 80) return PhosphorIconsFill.star;
    return PhosphorIconsFill.thumbsUp;
  }

  String _getMatchLabel() {
    final percentage = widget.userMatch.matchPercentage;
    if (percentage == 100) return 'PERFECT';
    if (percentage >= 90) return 'EXCELLENT';
    if (percentage >= 80) return 'GREAT';
    return 'GOOD';
  }
}