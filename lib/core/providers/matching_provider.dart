import 'package:flutter/foundation.dart';
import '../models/user_match_model.dart';
import '../services/matching_service.dart';

class MatchingProvider extends ChangeNotifier {
  final MatchingService _matchingService = MatchingService();
  
  List<UserMatch> _matches = [];
  bool _isLoading = false;
  String? _error;

  List<UserMatch> get matches => _matches;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load matches for a user
  Future<void> loadMatches(String userId) async {
    _setLoading(true);
    _clearError();
    
    print('[MatchingProvider] Loading matches for user: $userId');

    try {
      _matches = await _matchingService.findMatches(userId);
      
      print('[MatchingProvider] Received ${_matches.length} matches');
      
      // Sort by match percentage (descending order - highest first)
      _matches.sort((a, b) => b.matchPercentage.compareTo(a.matchPercentage));
    } catch (e) {
      print('[MatchingProvider] ERROR: $e');
      _setError(e.toString());
    }

    _setLoading(false);
  }

  // Calculate match percentage between two users
  Future<double> calculateMatch(String userId1, String userId2) async {
    try {
      return await _matchingService.calculateMatchPercentage(userId1, userId2);
    } catch (e) {
      return 0;
    }
  }

  // Get perfect matches (100%)
  List<UserMatch> get perfectMatches {
    return _matches.where((match) => match.matchPercentage == 100).toList();
  }

  // Get excellent matches (90-99%)
  List<UserMatch> get excellentMatches {
    return _matches.where((match) => match.matchPercentage >= 90 && match.matchPercentage < 100).toList();
  }

  // Get great matches (80-89%)
  List<UserMatch> get greatMatches {
    return _matches.where((match) => match.matchPercentage >= 80 && match.matchPercentage < 90).toList();
  }

  // Get good matches (75-79%)
  List<UserMatch> get goodMatches {
    return _matches.where((match) => match.matchPercentage >= 75 && match.matchPercentage < 80).toList();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clear() {
    _matches = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}