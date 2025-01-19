import 'dart:convert';
import 'dart:typed_data';

class User {
  final int userId;
  final String username;
  final String email;
  final String password;
  final String? image; // This is the regular image filename or URL
  final String? bio;
  final String? ownedGames;
  final String role;
  final String createdAt;
  final String? imageBase64; // Base64 encoded image data (if present)

  User({
    required this.userId,
    required this.username,
    required this.email,
    required this.password,
    this.image,
    this.bio,
    this.ownedGames,
    required this.role,
    required this.createdAt,
    this.imageBase64,
  });

  // Factory constructor to parse the JSON response
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      password: json['password'],
      image: json['image'], // regular image field (filename or URL)
      bio: json['bio'],
      ownedGames: json['ownedGames'],
      role: json['role'],
      createdAt: json['created_at'],
      imageBase64: json['image_base64'], // Base64 image field (optional)
    );
  }

  // Returns the profile picture as a byte array (if base64 encoded)
  Uint8List? get imageBytes {
    if (imageBase64 == null || imageBase64!.isEmpty) return null;

    // If the image is base64-encoded
    if (imageBase64!.startsWith('data:image')) {
      // Strip out the base64 prefix if it exists
      final base64Data = imageBase64!
          .replaceFirst('data:image/png;base64,', '')
          .replaceFirst('data:image/jpg;base64,', '')
          .replaceFirst('data:image/jpeg;base64,', '');
      // Decode Base64 to Uint8List
      return base64Decode(base64Data);
    }

    return null; // Return null if it's not base64-encoded
  }
}
