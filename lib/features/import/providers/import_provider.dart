import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/csv_data.dart';
import '../../../core/models/exercise_stats.dart';
import '../../../core/services/csv_service.dart';
import '../../../core/services/stats_service.dart';
import '../../../core/services/storage_service.dart';

class ImportProvider extends ChangeNotifier {
  final CsvService _csvService = CsvService();
  final StatsService _statsService = StatsService();
  final StorageService _storageService = StorageService();

  List<CsvData> _data = [];
  List<ExerciseStats> _exerciseStats = [];
  bool _isLoading = false;
  String? _error;
  DateTime? _lastImportDate;

  List<CsvData> get data => _data;
  List<ExerciseStats> get exerciseStats => _exerciseStats;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get lastImportDate => _lastImportDate;
  bool get hasData => _data.isNotEmpty;

  // Charger les données au démarrage
  Future<void> loadSavedData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _data = await _storageService.loadCsvData();
      _exerciseStats = await _storageService.loadExerciseStats();
      if (_data.isNotEmpty) {
        _lastImportDate = _data.first.importedAt;
      }
    } catch (e) {
      // Si les données sont corrompues, les effacer
      debugPrint('Erreur lors du chargement des données: $e');
      _error = 'Les données sauvegardées sont corrompues et ont été effacées. Veuillez réimporter votre fichier CSV.';
      await _storageService.clearCsvData();
      _data = [];
      _exerciseStats = [];
      _lastImportDate = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Importer un nouveau fichier CSV
  Future<void> importCsv() async {
    try {
      // Sélectionner le fichier
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['csv'],
        withData: true, // Important pour Web
      );

      if (result == null || result.files.isEmpty) {
        return; // L'utilisateur a annulé
      }

      _isLoading = true;
      _error = null;
      notifyListeners();

      final PlatformFile file = result.files.first;
      
      // Lire le contenu du fichier
      final String csvContent;
      if (kIsWeb) {
        // Sur Web, utiliser bytes
        if (file.bytes == null) {
          throw Exception('Impossible de lire le fichier');
        }
        csvContent = utf8.decode(file.bytes!);
      } else {
        // Sur mobile, utiliser le chemin
        if (file.bytes == null) {
          throw Exception('Chemin de fichier invalide');
        }
        csvContent = utf8.decode(file.bytes!);
      }

      // Parser le CSV
      final List<CsvData> parsedData = await _csvService.parseCsv(csvContent);

      // Valider les données
      if (!_csvService.validateCsvFormat(parsedData)) {
        throw Exception('Format CSV invalide');
      }

      // Sauvegarder (écrase les données précédentes)
      _data = parsedData;
      _lastImportDate = DateTime.now();
      await _storageService.saveCsvData(_data);

      // Calculer et sauvegarder les statistiques d'exercices
      _exerciseStats = _statsService.calculateExerciseStats(_data);
      await _storageService.saveExerciseStats(_exerciseStats);

      _error = null;
    } catch (e) {
      debugPrint('Erreur technique lors de l\'importation: $e');
      if (e.toString().contains('Vous devez importer un fichier CSV')) {
        _error = 'Ce fichier ne provient pas de l\'application Hevy. Veuillez exporter vos données depuis Hevy et réessayer.';
      } else if (e.toString().contains('CSV est vide')) {
        _error = 'Le fichier CSV est vide. Veuillez vérifier votre export depuis Hevy.';
      } else if (e.toString().contains('Format CSV invalide')) {
        _error = 'Le format du fichier n\'est pas valide. Assurez-vous d\'importer un fichier CSV non modifié depuis Hevy.';
      } else {
        _error = 'Impossible d\'importer le fichier. Vérifiez qu\'il s\'agit bien d\'un export Hevy au format CSV.';
      }
      // Ne pas effacer les données existantes en cas d'erreur
      // _data reste inchangé pour conserver l'import précédent
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Importer depuis un chemin de fichier (pour le partage Android)
  Future<void> importCsvFromPath(String filePath) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Lire le fichier depuis le chemin
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final csvContent = utf8.decode(bytes);

      // Parser le CSV
      final List<CsvData> parsedData = await _csvService.parseCsv(csvContent);

      // Valider les données
      if (!_csvService.validateCsvFormat(parsedData)) {
        throw Exception('Format CSV invalide');
      }

      // Sauvegarder
      _data = parsedData;
      _lastImportDate = DateTime.now();
      await _storageService.saveCsvData(_data);

      // Calculer et sauvegarder les statistiques
      _exerciseStats = _statsService.calculateExerciseStats(_data);
      await _storageService.saveExerciseStats(_exerciseStats);

      _error = null;
    } catch (e) {
      debugPrint('Erreur technique lors de l\'importation depuis le partage: $e');
      if (e.toString().contains('Vous devez importer un fichier CSV')) {
        _error = 'Ce fichier ne provient pas de l\'application Hevy. Veuillez exporter vos données depuis Hevy et réessayer.';
      } else if (e.toString().contains('CSV est vide')) {
        _error = 'Le fichier CSV est vide. Veuillez vérifier votre export depuis Hevy.';
      } else if (e.toString().contains('Format CSV invalide')) {
        _error = 'Le format du fichier n\'est pas valide. Assurez-vous d\'importer un fichier CSV non modifié depuis Hevy.';
      } else {
        _error = 'Impossible d\'importer le fichier. Vérifiez qu\'il s\'agit bien d\'un export Hevy au format CSV.';
      }
      // Ne pas effacer les données existantes en cas d'erreur
      // _data reste inchangé pour conserver l'import précédent
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Effacer toutes les données
  Future<void> clearData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _storageService.clearCsvData();
      _data = [];
      _exerciseStats = [];
      _lastImportDate = null;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Effacer l'erreur
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
