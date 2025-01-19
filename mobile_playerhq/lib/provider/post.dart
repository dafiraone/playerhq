import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/post.dart';

class PostProvider extends ChangeNotifier {
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/api/posts'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _posts = data.map((postJson) => Post.fromJson(postJson)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      log('Error fetching posts: $e');
      // throw e;
    }
  }
}
