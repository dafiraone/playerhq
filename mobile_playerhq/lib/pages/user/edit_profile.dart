import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/models/user.dart';
import 'package:mobile_playerhq/provider/user.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  final User user;

  const EditProfilePage({super.key, required this.user});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _bioController;
  bool passObscure = true;

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _passwordController = TextEditingController(text: widget.user.password);
    _bioController = TextEditingController(text: widget.user.bio);
  }

  void obscureText() {
    setState(() {
      passObscure = !passObscure;
    });
  }

  bool _isImagePickerActive = false;

  Future<void> _pickImage() async {
    if (_isImagePickerActive) return; // Prevent further calls if already active
    setState(() {
      _isImagePickerActive = true; // Set to true when picker starts
    });

    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      log('Error picking image: $e');
    } finally {
      setState(() {
        _isImagePickerActive = false; // Set back to false when picker finishes
      });
    }
  }

  Future<void> _saveChanges() async {
    final updatedUser = {
      'username': _usernameController.text,
      'email': _emailController.text,
      'password': _passwordController.text,
      'bio': _bioController.text,
    };

    if (_selectedImage != null) {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);
      updatedUser['image'] = base64Image;
    }

    final String apiUrl =
        '${dotenv.env['API_URL']}/api/users/${widget.user.userId}';

    try {
      final response = await http.put(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedUser),
      );

      if (response.statusCode == 200) {
        await Provider.of<UserProvider>(context, listen: false)
            .fetchUser(widget.user.userId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update profile')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0, // Flat AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Profile Image Preview
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : widget.user.imageBytes != null
                          ? MemoryImage(widget.user.imageBytes!)
                              as ImageProvider
                          : const AssetImage('assets/profile_placeholder.png'),
                ),
              ),
              const SizedBox(height: 16),

              // Username Field
              TextField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  isDense: true, // Compact design
                ),
              ),
              const SizedBox(height: 12),

              // Email Field
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  isDense: true, // Compact design
                ),
              ),
              const SizedBox(height: 12),

              // Password Field
              TextField(
                controller: _passwordController,
                obscureText: passObscure,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  isDense: true,
                  suffixIcon: IconButton(
                    icon: Icon(
                      passObscure ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: obscureText,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Bio Field
              TextField(
                controller: _bioController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                  isDense: true, // Compact design
                ),
              ),
              const SizedBox(height: 20),

              // Save Button
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  minimumSize: const Size(double.infinity, 40),
                ),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
