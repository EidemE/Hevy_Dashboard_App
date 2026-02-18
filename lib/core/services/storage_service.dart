import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/csv_data.dart';
import '../models/exercise_stats.dart';
import '../models/weight_unit.dart';

class StorageService {
  static const String _csvDataKey = 'csv_data';
  static const String _exerciseStatsKey = 'exercise_stats';
  static const String _weightUnitKey = 'weight_unit';

  // Save CSV data
  Future<void> saveCsvData(List<CsvData> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = data.map((CsvData item) => item.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await prefs.setString(_csvDataKey, jsonString);
    } catch (e) {
      throw Exception('Error during backup: $e');
    }
  }

  // Load CSV data
  Future<List<CsvData>> loadCsvData() async {
    try {
      // Force a reload to get the most recent data
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      
      final String? jsonString = prefs.getString(_csvDataKey);
      
      if (jsonString == null || jsonString.isEmpty) {
        return <CsvData>[];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((dynamic json) => CsvData.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error during loading: $e');
    }
  }

  // Clear all data
  Future<void> clearCsvData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_csvDataKey);
    await prefs.remove(_exerciseStatsKey);
    await prefs.remove(_weightUnitKey);
  }

  // Check whether data exists
  Future<bool> hasCsvData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_csvDataKey);
  }

  // Save exercise statistics
  Future<void> saveExerciseStats(List<ExerciseStats> stats) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          stats.map((ExerciseStats item) => item.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await prefs.setString(_exerciseStatsKey, jsonString);
    } catch (e) {
      throw Exception('Error during stats save: $e');
    }
  }

  // Load exercise statistics
  Future<List<ExerciseStats>> loadExerciseStats() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();
      
      final String? jsonString = prefs.getString(_exerciseStatsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return <ExerciseStats>[];
      }

      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      return jsonList
          .map((dynamic json) =>
              ExerciseStats.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Error during stats loading: $e');
    }
  }

  Future<void> saveWeightUnit(WeightUnit unit) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(_weightUnitKey, unit.name);
    } catch (e) {
      throw Exception('Error during weight unit save: $e');
    }
  }

  Future<WeightUnit> loadWeightUnit() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.reload();

      final String? rawValue = prefs.getString(_weightUnitKey);
      return WeightUnitParsing.fromStorageValue(rawValue);
    } catch (e) {
      throw Exception('Error during weight unit loading: $e');
    }
  }
}
