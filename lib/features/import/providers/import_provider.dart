import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/models/csv_data.dart';
import '../../../core/models/exercise_stats.dart';
import '../../../core/models/weight_unit.dart';
import '../../../core/services/csv_service.dart';
import '../../../core/services/stats_service.dart';
import '../../../core/services/storage_service.dart';

enum ImportErrorType {
  savedDataCorrupted,
  notHevy,
  emptyCsv,
  noData,
  invalidFormat,
  readFile,
  invalidFilePath,
  generic,
}

class ImportException implements Exception {
  final ImportErrorType type;

  ImportException(this.type);

  @override
  String toString() => 'ImportException($type)';
}

class ImportProvider extends ChangeNotifier {
  final CsvService _csvService = CsvService();
  final StatsService _statsService = StatsService();
  final StorageService _storageService = StorageService();

  List<CsvData> _data = [];
  List<ExerciseStats> _exerciseStats = [];
  bool _isLoading = false;
  ImportErrorType? _errorType;
  DateTime? _lastImportDate;
  WeightUnit _weightUnit = WeightUnit.kg;

  List<CsvData> get data => _data;
  List<ExerciseStats> get exerciseStats => _exerciseStats;
  bool get isLoading => _isLoading;
  ImportErrorType? get errorType => _errorType;
  DateTime? get lastImportDate => _lastImportDate;
  bool get hasData => _data.isNotEmpty;
  WeightUnit get weightUnit => _weightUnit;
  String get weightUnitLabel => _weightUnit.name;
  double get tonsDivisor => _weightUnit == WeightUnit.lb ? 2000.0 : 1000.0;
  String get tonsUnitLabel => _weightUnit == WeightUnit.lb ? 'ton' : 't';

  void _setWeightUnit(WeightUnit unit) {
    _weightUnit = unit;
  }

  // Charger les données au démarrage
  Future<void> loadSavedData() async {
    _isLoading = true;
    _errorType = null;
    notifyListeners();

    try {
      _data = await _storageService.loadCsvData();
      _exerciseStats = await _storageService.loadExerciseStats();
      _setWeightUnit(await _storageService.loadWeightUnit());
      if (_data.isNotEmpty) {
        _lastImportDate = _data.first.importedAt;
      }
    } catch (e) {
      // Si les données sont corrompues, les effacer
      debugPrint('Erreur lors du chargement des données: $e');
      _errorType = ImportErrorType.savedDataCorrupted;
      await _storageService.clearCsvData();
      _data = [];
      _exerciseStats = [];
      _lastImportDate = null;
      _setWeightUnit(WeightUnit.kg);
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
      _errorType = null;
      notifyListeners();

      final PlatformFile file = result.files.first;
      
      // Lire le contenu du fichier
      final String csvContent;
      if (kIsWeb) {
        // Sur Web, utiliser bytes
        if (file.bytes == null) {
          throw ImportException(ImportErrorType.readFile);
        }
        csvContent = utf8.decode(file.bytes!);
      } else {
        // Sur mobile, utiliser le chemin
        if (file.bytes == null) {
          throw ImportException(ImportErrorType.invalidFilePath);
        }
        csvContent = utf8.decode(file.bytes!);
      }

      // Parser le CSV
      final List<CsvData> parsedData = await _csvService.parseCsv(csvContent);

      // Valider les données
      if (!_csvService.validateCsvFormat(parsedData)) {
        throw ImportException(ImportErrorType.invalidFormat);
      }

      // Sauvegarder (écrase les données précédentes)
      _data = parsedData;
      _setWeightUnit(_data.first.weightUnit);
      _lastImportDate = DateTime.now();
      await _storageService.saveCsvData(_data);
      await _storageService.saveWeightUnit(_weightUnit);

      // Calculer et sauvegarder les statistiques d'exercices
      _exerciseStats = _statsService.calculateExerciseStats(_data);
      await _storageService.saveExerciseStats(_exerciseStats);

      _errorType = null;
    } catch (e) {
      debugPrint('Erreur technique lors de l\'importation: $e');
      _errorType = _mapImportException(e);
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
    _errorType = null;
    notifyListeners();

    try {
      if (filePath.trim().isEmpty) {
        throw ImportException(ImportErrorType.invalidFilePath);
      }
      // Lire le fichier depuis le chemin
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final csvContent = utf8.decode(bytes);

      // Parser le CSV
      final List<CsvData> parsedData = await _csvService.parseCsv(csvContent);

      // Valider les données
      if (!_csvService.validateCsvFormat(parsedData)) {
        throw ImportException(ImportErrorType.invalidFormat);
      }

      // Sauvegarder
      _data = parsedData;
      _setWeightUnit(_data.first.weightUnit);
      _lastImportDate = DateTime.now();
      await _storageService.saveCsvData(_data);
      await _storageService.saveWeightUnit(_weightUnit);

      // Calculer et sauvegarder les statistiques
      _exerciseStats = _statsService.calculateExerciseStats(_data);
      await _storageService.saveExerciseStats(_exerciseStats);

      _errorType = null;
    } catch (e) {
      debugPrint('Erreur technique lors de l\'importation depuis le partage: $e');
      _errorType = _mapImportException(e);
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
      _setWeightUnit(WeightUnit.kg);
      _errorType = null;
    } catch (e) {
      _errorType = ImportErrorType.generic;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Effacer l'erreur
  void clearError() {
    _errorType = null;
    notifyListeners();
  }

  ImportErrorType _mapImportException(Object error) {
    if (error is ImportException) {
      return error.type;
    }
    if (error is FileSystemException || error is FormatException) {
      return ImportErrorType.readFile;
    }
    if (error is CsvParseException) {
      switch (error.type) {
        case CsvParseErrorType.emptyCsv:
          return ImportErrorType.emptyCsv;
        case CsvParseErrorType.invalidHeaderCount:
          return ImportErrorType.notHevy;
        case CsvParseErrorType.noDataRows:
          return ImportErrorType.noData;
        case CsvParseErrorType.parseFailed:
          return ImportErrorType.generic;
      }
    }
    return ImportErrorType.generic;
  }
}
