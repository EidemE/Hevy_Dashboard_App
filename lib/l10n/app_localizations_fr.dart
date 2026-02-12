// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Hevy Dashboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get exercises => 'Exercices';

  @override
  String get import => 'Importer';

  @override
  String get monthlyStats => 'Stats mensuelles';

  @override
  String get topExercises => 'Top Exercices';

  @override
  String get seeAll => 'Voir tout';

  @override
  String get noExercise => 'Aucun exercice';

  @override
  String get noExerciseDesc => 'Importez vos données CSV pour commencer';

  @override
  String get workoutsCompleted => 'Entraînements effectués';

  @override
  String get differentExercises => 'Exercices différents';

  @override
  String get setsCompleted => 'Sets effectués';

  @override
  String get totalWeight => 'Poids total soulevé';

  @override
  String get sessions => 'Séances';

  @override
  String get sets => 'Sets';

  @override
  String get max => 'Max';

  @override
  String get total => 'Total';

  @override
  String get last => 'Dernier';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get yesterday => 'Hier';

  @override
  String get repsProgressionTitle => 'Progression des répétitions';

  @override
  String get weightRepsProgressionTitle => 'Progression poids & reps';

  @override
  String get maxWeightProgressionTitle => 'Progression du poids maximum';

  @override
  String get allExercises => 'Tous les exercices';

  @override
  String allExercisesCount(int count) {
    return 'Tous les exercices ($count)';
  }

  @override
  String get changeSorting => 'Changer le tri';

  @override
  String get sortByWorkouts => 'Nombre de séances';

  @override
  String get sortBySets => 'Nombre de sets';

  @override
  String get sortByMaxWeight => 'Poids maximum';

  @override
  String get sortByTotalWeight => 'Poids total';

  @override
  String get sortByName => 'Nom';

  @override
  String get sortLabelWorkouts => 'Par séances';

  @override
  String get sortLabelSets => 'Par sets';

  @override
  String get sortLabelWeight => 'Par poids';

  @override
  String get sortLabelTotal => 'Par total';

  @override
  String get sortLabelName => 'Par nom';

  @override
  String get searchExercises => 'Rechercher un exercice...';

  @override
  String get noExercisesFound => 'Aucun exercice trouvé';

  @override
  String get noExercisesFoundDesc => 'Essayez de modifier votre recherche';

  @override
  String get importData => 'Importer mes données';

  @override
  String get importDataDesc => 'Importez votre fichier CSV exporté depuis Hevy';

  @override
  String get selectFile => 'Sélectionner un fichier';

  @override
  String get importInProgress => 'Import en cours...';

  @override
  String get importSuccess => 'Import réussi !';

  @override
  String importSuccessDesc(int count) {
    return '$count séances importées';
  }

  @override
  String get importError => 'Erreur d\'import';

  @override
  String get dataAlreadyImported => 'Données déjà importées';

  @override
  String get dataAlreadyImportedDesc => 'Voulez-vous réimporter ?';

  @override
  String get reimport => 'Réimporter';

  @override
  String get cancel => 'Annuler';

  @override
  String get monthlyStatsTitle => 'Statistiques mensuelles';

  @override
  String get monthlyStatsDesc =>
      'Évolution de vos performances à travers les mois';

  @override
  String get noData => 'Aucune donnée';

  @override
  String get noDataDesc =>
      'Importez vos données CSV pour voir vos statistiques';

  @override
  String get noSession => 'Aucune séance';

  @override
  String get totalTime => 'Temps total';

  @override
  String get avgTime => 'Temps moy.';

  @override
  String get differentExercisesShort => 'Exercices diff.';

  @override
  String get exercisesPerSession => 'Exo./séance';

  @override
  String get avgWeightPerSession => 'Poids moy./séance';

  @override
  String get all => 'Toutes';

  @override
  String get kg => 'kg';

  @override
  String get reps => 'reps';

  @override
  String get tons => 't';

  @override
  String get info => 'Infos';

  @override
  String get openHevy => 'Ouvrir Hevy';

  @override
  String get cannotOpenHevy => 'Impossible d\'ouvrir l\'application Hevy';

  @override
  String get globalStats => 'Statistiques globales';

  @override
  String get activity => 'Activité';

  @override
  String get performance30Days => 'Performance (30 derniers jours)';

  @override
  String get seeMore => 'Voir plus';

  @override
  String get clear => 'Effacer';

  @override
  String get howToImportHevy => 'Comment importer vos données Hevy';

  @override
  String get hideInstructions => 'Masquer les instructions';

  @override
  String get importInstructions =>
      'Pour analyser vos entraînements, vous devez exporter vos données depuis l\'application Hevy :';

  @override
  String get step1 => 'Ouvrez l\'application Hevy sur votre téléphone';

  @override
  String get step2 => 'Allez dans Profil > Paramètres';

  @override
  String get step3 => 'Sélectionnez \"Exporter et importer des données\"';

  @override
  String get step4 => 'Appuyez sur \"Exporter les données\"';

  @override
  String get step5 => 'Choisissez \"Exporter les entraînements\"';

  @override
  String get twoWaysToImport => 'Deux façons d\'importer';

  @override
  String get importWay1 =>
      '• Cliquez sur \"Importer CSV\" ci-dessus et sélectionnez le fichier';

  @override
  String get importWay2 =>
      '• Partagez directement le fichier CSV depuis Hevy vers cette application';

  @override
  String get noDataImported => 'Aucune donnée importée';

  @override
  String get clickToStart => 'Cliquez sur \"Importer CSV\" pour commencer';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get confirmClear =>
      'Êtes-vous sûr de vouloir effacer toutes les données importées ?';

  @override
  String workoutsImported(int count) {
    return '$count entraînement(s) importé(s)';
  }

  @override
  String importedOn(String date) {
    return 'Importé(s) le $date';
  }

  @override
  String get evolution => 'Évolution';

  @override
  String get close => 'Fermer';

  @override
  String get viewOnGithub => 'Voir la page GitHub';

  @override
  String get infoDialogDescription1 =>
      'Hevy Dashboard est une application qui transforme vos exports d\'entraînement Hevy en un tableau de bord de statistiques clair et interactif. Importez votre CSV Hevy et explorez votre historique, vos tendances et vos progrès en un seul endroit.';

  @override
  String get infoDialogDescription2 =>
      'Cette application est open-source sous licence MIT et n\'est ni officielle ni affiliée à Hevy Studios.';

  @override
  String get infoDialogDisclaimer =>
      'Vous pouvez sur la page GitHub proposer des modifications, des améliorations et signaler des bugs avec l\'application.';

  @override
  String get infoDialogDeveloper => 'EidemE';

  @override
  String routeNotFound(String name) {
    return 'Route non trouvée : $name';
  }

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# séances',
      one: '# séance',
    );
    return '$_temp0';
  }

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# exercices',
      one: '# exercice',
    );
    return '$_temp0';
  }
}
