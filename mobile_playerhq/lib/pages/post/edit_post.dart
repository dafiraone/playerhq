import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/models/post.dart';
import 'package:mobile_playerhq/provider/post.dart';
import 'package:provider/provider.dart';

class EditPostPage extends StatefulWidget {
  final Post post;

  const EditPostPage({super.key, required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController _contentController;
  bool _isUpdating = false;
  String errorMessage = '';
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.post.content ?? '');
  }

  // Image picker logic
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    }
  }

  Future<void> _updatePost() async {
    setState(() {
      _isUpdating = true;
    });

    final String content = _contentController.text.trim();

    if (content.isNotEmpty || _selectedImage != null) {
      try {
        final updatedPost = {
          'content': content,
        };

        // Convert image to base64 if it's selected
        if (_selectedImage != null) {
          final bytes = await _selectedImage!.readAsBytes();
          final base64Image = base64Encode(bytes);
          updatedPost['image'] = base64Image;
        }

        final String apiUrl =
            '${dotenv.env['API_URL']}/api/posts/${widget.post.postId}';
        final response = await http.put(
          Uri.parse(apiUrl),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(updatedPost),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Post updated successfully")),
          );

          await Provider.of<PostProvider>(context, listen: false).fetchPosts();
          Navigator.pushNamed(
            context,
            '/home',
          );
        } else {
          setState(() {
            errorMessage = 'Failed to update post';
          });
        }
      } catch (error) {
        setState(() {
          errorMessage = 'Error updating post: $error';
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please enter content or select an image to update';
      });
    }

    setState(() {
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Post", style: TextStyle(fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0, // No elevation for a flat design
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Content TextField
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: "Edit Post Content",
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                ),
                maxLines: 5,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              // Image Preview (if image is selected)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[200],
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                          size: 40,
                        ),
                ),
              ),
              const SizedBox(height: 16),

              // Error message if any
              if (errorMessage.isNotEmpty)
                Text(
                  errorMessage,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              const SizedBox(height: 16),

              // Update Button
              _isUpdating
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.black))
                  : Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: EdgeInsets.symmetric(
                              vertical: 16, horizontal: 80),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.black, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _updatePost,
                        child: const Text("Update Post"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
