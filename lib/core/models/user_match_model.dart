class UserMatch {
  final String userId;
  final String userName;
  final String? userPhoto;
  final int? userAge;
  final double matchPercentage;
  final List<String> commonMovieIds;

  const UserMatch({
    required this.userId,
    required this.userName,
    this.userPhoto,
    this.userAge,
    required this.matchPercentage,
    required this.commonMovieIds,
  });

  factory UserMatch.fromJson(Map<String, dynamic> json) {
    return UserMatch(
      userId: json['userId'] as String,
      userName: json['userName'] as String,
      userPhoto: json['userPhoto'] as String?,
      userAge: json['userAge'] as int?,
      matchPercentage: (json['matchPercentage'] as num).toDouble(),
      commonMovieIds: List<String>.from(json['commonMovieIds'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userPhoto': userPhoto,
      'userAge': userAge,
      'matchPercentage': matchPercentage,
      'commonMovieIds': commonMovieIds,
    };
  }
}
