import 'dart:convert';
import 'dart:typed_data';

class Post {
  final int postId;
  final int userId;
  final String? content;
  final String? image; // Image URL or file name (nullable)
  final String createdAt;
  final String updatedAt;
  final String?
      imageBase64; // Optional field for base64 image string (nullable)

  Post({
    required this.postId,
    required this.userId,
    this.content,
    this.image,
    required this.createdAt,
    required this.updatedAt,
    this.imageBase64,
  });

  // Factory constructor to parse the JSON response
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['post_id'],
      userId: json['user_id'],
      content: json['content'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      // Only include `image_base64` if it's in the response
      imageBase64:
          json.containsKey('image_base64') ? json['image_base64'] : null,
    );
  }

  // Optionally, you can implement a method to check for the image base64 string.
  bool get hasImageBase64 => imageBase64 != null;

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
