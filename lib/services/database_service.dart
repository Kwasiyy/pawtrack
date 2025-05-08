import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/pet.dart';

/// Service for handling local data storage
class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  
  DatabaseService._internal();
  
  /// Generic method to save data to SharedPreferences
  Future<void> saveData(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      throw Exception('Error saving data: $e');
    }
  }

  Future<void> savePet(Pet pet) async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      final petsList = sharedPrefs.getStringList('pets') ?? [];
      
      petsList.add(jsonEncode(pet.toJson()));
      await sharedPrefs.setStringList('pets', petsList);
    } catch (e) {
      throw Exception('Error saving pet: $e');
    }
  }

  Future<bool> deletePet(String petId) async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      final petsList = sharedPrefs.getStringList('pets') ?? [];
      
      // Find and remove the pet with matching ID
      final updatedPets = petsList.where((petJson) {
        final pet = Pet.fromJson(jsonDecode(petJson));
        return pet.id != petId;
      }).toList();
      
      // Save the updated list
      await sharedPrefs.setStringList('pets', updatedPets);
      return true;
    } catch (e) {
      print('Error deleting pet: $e');
      return false;
    }
  }

  Future<void> clearAllData() async {
    try {
      final sharedPrefs = await SharedPreferences.getInstance();
      // Clear pets
      await sharedPrefs.remove('pets');
      // Clear walks
      final keys = sharedPrefs.getKeys();
      for (final key in keys) {
        if (key.startsWith('walks_')) {
          await sharedPrefs.remove(key);
        }
      }
    } catch (e) {
      print('DatabaseService.clearAllData error: $e');
      rethrow;
    }
  }

  /// Generic method to get data from SharedPreferences
  Future<String?> getData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    } catch (e) {
      throw Exception('Error getting data: $e');
    }
  }

  /// Generic method to save a list of strings
  Future<void> saveStringList(String key, List<String> values) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, values);
    } catch (e) {
      throw Exception('Error saving string list: $e');
    }
  }

  /// Generic method to get a list of strings
  Future<List<String>> getStringList(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(key) ?? [];
    } catch (e) {
      throw Exception('Error getting string list: $e');
    }
  }
}
