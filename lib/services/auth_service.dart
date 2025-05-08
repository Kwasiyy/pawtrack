// lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  AuthService() {
    // Clear token on app start to ensure fresh login
    SharedPreferences.getInstance().then((prefs) => prefs.remove(_tokenKey));
  }
  //  ─── CHANGE THIS: ───────────────────────────────────────────────────────────
  //  If using the Android emulator on your dev machine:
  static const _baseUrl = 'http://10.0.2.2:8000/api/auth';
  //
  //  If you’re on a real device on Wi-Fi and your machine’s IP is 192.168.1.42:
  //  static const _baseUrl = 'http://192.168.1.42:8000/api/auth';
  //  ───────────────────────────────────────────────────────────────────────────

  static const _tokenKey = 'auth_token';
  static const _usersKey = 'mock_users';

  Future<Map<String, Map<String, String>>> _getUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson == null) return {};

    final usersMap = jsonDecode(usersJson) as Map<String, dynamic>;
    return Map<String, Map<String, String>>.from(
      usersMap.map((key, value) => MapEntry(
            key,
            Map<String, String>.from(value as Map),
          )),
    );
  }

  Future<void> _saveUsers(Map<String, Map<String, String>> users) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usersKey, jsonEncode(users));
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    final users = await _getUsers();
    final user = users[email];
    if (user != null && user['password'] == password) {
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      return true;
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    final users = await _getUsers();
    if (users.containsKey(email)) {
      return false; // Email already exists
    }

    users[email] = {
      'name': name,
      'password': password,
    };

    await _saveUsers(users);

    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    return true;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    // Don't clear users in production, this is just for testing
    // await prefs.remove(_usersKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Mock API methods
  Future<Map<String, dynamic>> getRequest(String path) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized');
    }
    return {'success': true, 'data': {}};
  }

  Future<Map<String, dynamic>> postRequest(String path, Map<String, dynamic> body) async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Unauthorized');
    }
    return {'success': true, 'data': body};
  }
}
