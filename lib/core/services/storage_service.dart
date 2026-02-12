import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/csv_data.dart';
import '../models/exercise_stats.dart';

class StorageService {
  static const String _csvDataKey = 'csv_data';
  static const String _exerciseStatsKey = 'exercise_stats';

  // Sauvegarder les données CSV
  Future<void> saveCsvData(List<CsvData> data) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList = data.map((CsvData item) => item.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await prefs.setString(_csvDataKey, jsonString);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde: $e');
    }
  }

  // Charger les données CSV
  Future<List<CsvData>> loadCsvData() async {
    try {
      // Forcer un reload pour avoir les données les plus récentes
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
      throw Exception('Erreur lors du chargement: $e');
    }
  }

  // Effacer toutes les données
  Future<void> clearCsvData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_csvDataKey);
    await prefs.remove(_exerciseStatsKey);
  }

  // Vérifier si des données existent
  Future<bool> hasCsvData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_csvDataKey);
  }

  // Sauvegarder les statistiques d'exercices
  Future<void> saveExerciseStats(List<ExerciseStats> stats) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final List<Map<String, dynamic>> jsonList =
          stats.map((ExerciseStats item) => item.toJson()).toList();
      final String jsonString = jsonEncode(jsonList);
      await prefs.setString(_exerciseStatsKey, jsonString);
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde des stats: $e');
    }
  }

  // Charger les statistiques d'exercices
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
      throw Exception('Erreur lors du chargement des stats: $e');
    }
  }
}
