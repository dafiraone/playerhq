import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/provider/post.dart';
import 'package:provider/provider.dart';
import 'package:mobile_playerhq/provider/user.dart';

class CreatePostPage extends StatefulWidget {
  const CreatePostPage({super.key});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _contentController = TextEditingController();
  bool _isLoading = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Create a function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Create a function to send the post data to the API
  Future<void> _createPost() async {
    final content = _contentController.text.trim();

    // Retrieve the user_id from UserProvider
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userId = userProvider.user?.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID is missing')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Prepare the post data, make content nullable
    final postData = {
      'user_id': userId,
      'content': content.isEmpty ? null : content, // Handle nullable content
    };

    // If an image is selected, convert it to base64 and add to the post data
    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      postData['image'] = base64Image; // Ensure this key matches the API
    }

    try {
      final response = await http.post(
        Uri.parse(
            '${dotenv.env['API_URL']}/api/posts'), // Replace with your actual API URL
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(postData),
      );

      if (response.statusCode == 200) {
        // Successfully created post
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Post created successfully!")),
        );
        await Provider.of<PostProvider>(context, listen: false).fetchPosts();
        Navigator.pop(context); // Navigate back to the HomePage
      } else {
        // Log raw response to help debug
        log("Response body: ${response.body}");

        final responseJson = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(responseJson['message'] ?? 'Something went wrong')),
        );
      }
    } catch (error) {
      // Log the error and print the raw response body
      log("Error: $error");

      // If it's a known JSON decoding error, print the raw response body
      if (error is FormatException) {
        log("Invalid JSON response: ${error.message}");
      }

      // Handle error (e.g., network issues)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create post')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Post content text field
            TextField(
              maxLines: 3,
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Post Content',
              ),
            ),
            const SizedBox(height: 20),

            // Image picker button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _pickImage,
              child: const Text('Pick an Image'),
            ),
            const SizedBox(height: 10),

            if (_selectedImage != null)
              Stack(
                children: [
                  Image.file(
                    _selectedImage!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                        });
                      },
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),

            // Create post button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 80),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.black, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _isLoading
                  ? null
                  : () {
                      _createPost();
                    },
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.black)
                  : const Text('Create Post'),
            ),
          ],
        ),
      ),
    );
  }
}
