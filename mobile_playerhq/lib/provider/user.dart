import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_playerhq/models/user.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  String _errorMessage = '';
  bool _isLoading = false;

  User? get user => _user;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  // Set the logged-in user
  void setUser(User user) {
    _user = user;
    _errorMessage = '';
    notifyListeners();
  }

  // Clear the logged-in user (used for logout)
  void clearUser() {
    _user = null;
    _errorMessage = ''; // Clear any error message on logout
    notifyListeners();
  }

  Future<void> fetchUser(int id) async {
    _isLoading = true;
    _errorMessage = ''; // Reset error message before making the request
    notifyListeners();

    try {
      final response =
          await http.get(Uri.parse('${dotenv.env['API_URL']}/api/users/$id'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _user = User.fromJson(data);
        _errorMessage = ''; // Clear any previous error
      } else {
        _errorMessage = 'Failed to load user: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'Error fetching user: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
