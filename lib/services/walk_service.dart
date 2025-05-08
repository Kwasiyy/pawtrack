// lib/services/walk_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/walk.dart';

/// Service to save Walk data to backend and local storage
class WalkService {
  // Use environment variable or configuration for this in production
  static const _baseUrl = String.fromEnvironment('API_URL', 
    defaultValue: 'http://10.0.2.2:8000/api/walks');
  
  static const _offlineWalksKey = 'offline_walks';
  static const _savedWalksKey = 'saved_walks';

  /// Saves a walk both locally and attempts to sync with backend
  Future<bool> saveWalk(Walk walk) async {
    try {
      // Always save locally first
      await _saveLocally(walk);
      
      // Try to sync with backend
      final success = await _syncWithBackend(walk);
      if (!success) {
        // If backend sync fails, queue for later sync
        await _queueForSync(walk);
      }
      
      return true;
    } catch (e) {
      print('WalkService.saveWalk error: $e');
      // Even if there's an error, we've saved locally
      return true;
    }
  }

  /// Get all walks for a specific pet
  Future<List<Walk>> getWalks(String petId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedWalks = prefs.getStringList(_savedWalksKey) ?? [];
      final offlineWalks = prefs.getStringList(_offlineWalksKey) ?? [];
      
      // Combine and parse all walks
      final allWalks = [...savedWalks, ...offlineWalks]
          .map((walkJson) => Walk.fromJson(jsonDecode(walkJson)))
          .where((walk) => walk.petId == petId)
          .toList();
      
      // Sort by start time, most recent first
      allWalks.sort((a, b) => b.startTime.compareTo(a.startTime));
      
      return allWalks;
    } catch (e) {
      print('WalkService.getWalks error: $e');
      return [];
    }
  }

  /// Save walk data locally
  Future<void> _saveLocally(Walk walk) async {
    final prefs = await SharedPreferences.getInstance();
    final savedWalks = prefs.getStringList(_savedWalksKey) ?? [];
    savedWalks.add(jsonEncode(walk.toJson()));
    await prefs.setStringList(_savedWalksKey, savedWalks);
  }

  /// Attempt to sync with backend
  Future<bool> _syncWithBackend(Walk walk) async {
    try {
      final uri = Uri.parse('$_baseUrl/create.php');
      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(walk.toJsonForCreate()),
      );
      return resp.statusCode == 200 || resp.statusCode == 201;
    } catch (e) {
      print('WalkService._syncWithBackend error: $e');
      return false;
    }
  }

  /// Queue walk for later sync with backend
  Future<void> _queueForSync(Walk walk) async {
    final prefs = await SharedPreferences.getInstance();
    final offlineWalks = prefs.getStringList(_offlineWalksKey) ?? [];
    offlineWalks.add(jsonEncode(walk.toJson()));
    await prefs.setStringList(_offlineWalksKey, offlineWalks);
  }
}