import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static final CloudinaryService _instance = CloudinaryService._internal();
  factory CloudinaryService() => _instance;
  CloudinaryService._internal();

  // Cloudinary credentials from environment
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  String get _uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'ml_default';
  String get _apiKey => dotenv.env['CLOUDINARY_API_KEY'] ?? '';
  String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET'] ?? '';

  /// Generates a signature for signed uploads
  String _generateSignature(Map<String, String> params, String apiSecret) {
    // Sort parameters alphabetically
    final sortedParams = params.keys.toList()..sort();
    
    // Create the string to sign
    final stringToSign = sortedParams
        .map((key) => '$key=${params[key]}')
        .join('&');
    
    // Generate SHA-1 hash
    final bytes = utf8.encode('$stringToSign$apiSecret');
    final digest = sha1.convert(bytes);
    
    return digest.toString();
  }

  /// Uploads an image to Cloudinary using signed upload and returns the secure URL
  /// 
  /// [imagePath] - The local file path of the image to upload
  /// [folder] - Optional folder name in Cloudinary (e.g., 'profile_images')
  /// 
  /// Returns the secure URL of the uploaded image, or null if upload fails
  Future<String?> uploadImageSigned(String imagePath, {String? folder}) async {
    try {
      if (_cloudName.isEmpty || _apiKey.isEmpty || _apiSecret.isEmpty) {
        return null;
      }
      
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload'
      );

      final request = http.MultipartRequest('POST', uri);
      
      // Add the file
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      
      // Prepare signature parameters
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final signatureParams = <String, String>{
        'timestamp': timestamp,
      };
      
      if (folder != null && folder.isNotEmpty) {
        signatureParams['folder'] = folder;
      }
      
      // Generate signature
      final signature = _generateSignature(signatureParams, _apiSecret);
      
      // Add all parameters to request
      request.fields['timestamp'] = timestamp;
      request.fields['api_key'] = _apiKey;
      request.fields['signature'] = signature;
      
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'] as String;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Uploads an image to Cloudinary and returns the secure URL
  /// 
  /// [imagePath] - The local file path of the image to upload
  /// [folder] - Optional folder name in Cloudinary (e.g., 'profile_images')
  /// 
  /// Returns the secure URL of the uploaded image, or null if upload fails
  Future<String?> uploadImage(String imagePath, {String? folder}) async {
    try {
      if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
        return null;
      }
      
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$_cloudName/image/upload'
      );

      final request = http.MultipartRequest('POST', uri);
      
      // Add the file
      final file = File(imagePath);
      if (!await file.exists()) {
        return null;
      }
      
      request.files.add(await http.MultipartFile.fromPath('file', imagePath));
      
      // Add upload preset (required for unsigned uploads)
      request.fields['upload_preset'] = _uploadPreset;
      
      // Add optional folder
      if (folder != null && folder.isNotEmpty) {
        request.fields['folder'] = folder;
      }

      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseData);
        return jsonResponse['secure_url'] as String;
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Uploads a profile image for a user
  /// 
  /// [imagePath] - The local file path of the image
  /// [userId] - The user ID for organizing the image
  /// 
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadProfileImage(String imagePath, String userId) async {
    return uploadImageSigned(imagePath, folder: 'film_manager/profile_images');
  }

  /// Uploads a movie poster
  /// 
  /// [imagePath] - The local file path of the image
  /// 
  /// Returns the secure URL of the uploaded image
  Future<String?> uploadMoviePoster(String imagePath) async {
    return uploadImageSigned(imagePath, folder: 'film_manager/movie_posters');
  }
}
