class AuthResponse {
  final String token;
  final Map<String, dynamic> user;
  final String message;

  const AuthResponse({
    required this.token,
    required this.user,
    required this.message,
  });

  // Simple fromJson without code generation
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: json['user'] as Map<String, dynamic>,
      message: json['message'] as String,
    );
  }

  // Simple toJson without code generation
  Map<String, dynamic> toJson() {
    return {'token': token, 'user': user, 'message': message};
  }
}
