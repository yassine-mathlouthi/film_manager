import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/models/user_match_model.dart';
import '../../../core/models/simple_movie_info.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/movies_service.dart';
import '../../../core/services/omdb_service.dart';

class UserMatchTile extends StatefulWidget {
  final UserMatch userMatch;

  const UserMatchTile({super.key, required this.userMatch});

  @override
  State<UserMatchTile> createState() => _UserMatchTileState();
}

class _UserMatchTileState extends State<UserMatchTile> {
  bool _isExpanded = false;
  List<SimpleMovieInfo> _commonMovies = [];
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
    
    print('\n🎬 Loading ${widget.userMatch.commonMovieIds.length} common movies');

    try {
      final moviesService = MoviesService();
      final omdbService = OmdbService();
      final loadedMovies = <SimpleMovieInfo>[];

      for (var movieId in widget.userMatch.commonMovieIds) {
        // ÉTAPE 1: Essayer Firestore (movies admin)
        try {
          final firestoreMovies = await moviesService.getMoviesByIds([movieId]);
          
          if (firestoreMovies.isNotEmpty) {
            final movie = firestoreMovies.first;
            loadedMovies.add(SimpleMovieInfo.fromMovie(movie));
            print('✅ Firestore: ${movie.title}');
            continue;
          }
        } catch (e) {
          // Pas dans Firestore, continuer
        }

        // ÉTAPE 2: Essayer OMDB (avec ID IMDB)
        if (movieId.startsWith('tt')) {
          try {
            final omdbMovie = await omdbService.getMovieById(movieId);
            
            if (omdbMovie != null) {
              loadedMovies.add(SimpleMovieInfo.fromRapidApi(omdbMovie));
              print('✅ OMDB: ${omdbMovie['title']}');
              continue;
            }
          } catch (e) {
            print('⚠️ OMDB error for $movieId: $e');
          }
        }

        // ÉTAPE 3: Placeholder si rien trouvé
        print('❌ Not found: $movieId');
        loadedMovies.add(SimpleMovieInfo(
          id: movieId,
          title: 'Movie ${movieId.substring(0, 8)}...',
          imageUrl: null,
          source: 'placeholder',
        ));
      }

      print('📊 Loaded: ${loadedMovies.length}/${widget.userMatch.commonMovieIds.length}\n');

      if (mounted) {
        setState(() {
          _commonMovies = loadedMovies;
          _isLoadingMovies = false;
        });
      }
    } catch (e) {
      print('❌ Error: $e');
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
                  
                  // User Info
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
                  
                  // Match Badge
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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 12),
                            Text(
                              'Loading movies...',
                              style: AppTheme.captionStyle,
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (_commonMovies.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Icon(
                              PhosphorIconsRegular.filmSlate,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No movies to display',
                              style: AppTheme.captionStyle,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 140,
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

  Widget _buildMovieCard(SimpleMovieInfo movie) {
    final isPlaceholder = movie.source == 'placeholder' || movie.source == 'error';
    
    return Container(
      width: 90,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          Container(
            height: 100,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: isPlaceholder ? Colors.grey[300] : Colors.grey[200],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: movie.imageUrl != null && !isPlaceholder
                  ? Image.network(
                      movie.imageUrl!,
                      fit: BoxFit.cover,
                      width: 90,
                      height: 100,
                      errorBuilder: (context, error, stackTrace) {
                        return _buildMoviePlaceholder();
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : _buildMoviePlaceholder(),
            ),
          ),
          const SizedBox(height: 6),
          // Movie Title
          Text(
            movie.title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isPlaceholder ? Colors.grey[600] : Colors.black87,
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
    if (percentage == 100) return const Color(0xFFEF4444);
    if (percentage >= 90) return const Color(0xFFF59E0B);
    if (percentage >= 80) return const Color(0xFF10B981);
    return const Color(0xFF6366F1);
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