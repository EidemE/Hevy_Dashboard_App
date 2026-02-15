// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hevy Dashboard';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get exercises => 'Exercises';

  @override
  String get import => 'Import';

  @override
  String get monthlyStats => 'Monthly Stats';

  @override
  String get topExercises => 'Top Exercises';

  @override
  String get seeAll => 'See all';

  @override
  String get noExercise => 'No exercises';

  @override
  String get noExerciseDesc => 'Import your CSV data to get started';

  @override
  String get workoutsCompleted => 'Workouts completed';

  @override
  String get differentExercises => 'Different exercises';

  @override
  String get setsCompleted => 'Sets completed';

  @override
  String get totalWeight => 'Total weight lifted';

  @override
  String get sessions => 'Sessions';

  @override
  String get sets => 'Sets';

  @override
  String get max => 'Max';

  @override
  String get total => 'Total';

  @override
  String get last => 'Last';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get repsProgressionTitle => 'Reps progression';

  @override
  String get weightRepsProgressionTitle => 'Weight & reps progression';

  @override
  String get maxWeightProgressionTitle => 'Max weight progression';

  @override
  String get allExercises => 'All exercises';

  @override
  String allExercisesCount(int count) {
    return 'All exercises ($count)';
  }

  @override
  String get changeSorting => 'Change sorting';

  @override
  String get sortByWorkouts => 'Number of sessions';

  @override
  String get sortBySets => 'Number of sets';

  @override
  String get sortByMaxWeight => 'Maximum weight';

  @override
  String get sortByTotalWeight => 'Total weight';

  @override
  String get sortByName => 'Name';

  @override
  String get sortLabelWorkouts => 'By sessions';

  @override
  String get sortLabelSets => 'By sets';

  @override
  String get sortLabelWeight => 'By weight';

  @override
  String get sortLabelTotal => 'By total';

  @override
  String get sortLabelName => 'By name';

  @override
  String get searchExercises => 'Search exercises...';

  @override
  String get noExercisesFound => 'No exercises found';

  @override
  String get noExercisesFoundDesc => 'Try modifying your search';

  @override
  String get importData => 'Import my data';

  @override
  String get importDataDesc => 'Import your CSV file exported from Hevy';

  @override
  String get selectFile => 'Select file';

  @override
  String get importInProgress => 'Import in progress...';

  @override
  String get importSuccess => 'Import successful!';

  @override
  String importSuccessDesc(int count) {
    return '$count workouts imported';
  }

  @override
  String get importError => 'Import error';

  @override
  String get importErrorSavedDataCorrupted =>
      'Saved data was corrupted and has been cleared. Please reimport your CSV file.';

  @override
  String get importErrorNotHevy =>
      'This file is not from Hevy. Export your data from Hevy and try again.';

  @override
  String get importErrorEmptyCsv =>
      'The CSV file is empty. Check your export from Hevy.';

  @override
  String get importErrorNoData => 'The CSV file contains no data.';

  @override
  String get importErrorInvalidFormat =>
      'The file format is not valid. Make sure you import an unmodified CSV from Hevy.';

  @override
  String get importErrorReadFile =>
      'Unable to read the file. Please try again.';

  @override
  String get importErrorInvalidFilePath => 'Invalid file path.';

  @override
  String get importErrorGeneric =>
      'Unable to import the file. Make sure it is a Hevy CSV export.';

  @override
  String get dataAlreadyImported => 'Data already imported';

  @override
  String get dataAlreadyImportedDesc => 'Do you want to reimport?';

  @override
  String get reimport => 'Reimport';

  @override
  String get importCsv => 'Import CSV';

  @override
  String get reimportCsv => 'Reimport CSV';

  @override
  String get cancel => 'Cancel';

  @override
  String get monthlyStatsTitle => 'Monthly statistics';

  @override
  String get monthlyStatsDesc =>
      'Evolution of your performance over the months';

  @override
  String get noData => 'No data';

  @override
  String get noDataDesc => 'Import your CSV data to see your statistics';

  @override
  String get noSession => 'No session';

  @override
  String get totalTime => 'Total time';

  @override
  String get avgTime => 'Avg. time';

  @override
  String get differentExercisesShort => 'Diff. exercises';

  @override
  String get exercisesPerSession => 'Ex./session';

  @override
  String get avgWeightPerSession => 'Avg. weight/session';

  @override
  String get all => 'All';

  @override
  String get kg => 'kg';

  @override
  String get reps => 'reps';

  @override
  String get tons => 't';

  @override
  String get info => 'Info';

  @override
  String get openHevy => 'Open Hevy';

  @override
  String get cannotOpenHevy => 'Cannot open Hevy application';

  @override
  String get globalStats => 'Global statistics';

  @override
  String get activity => 'Activity';

  @override
  String get performance30Days => 'Performance (last 30 days)';

  @override
  String get seeMore => 'See more';

  @override
  String get clear => 'Clear';

  @override
  String get importReminderTitle => 'Did you work out?';

  @override
  String get importReminderBody =>
      'Don\"t forget to import them into your app to track your progress.';

  @override
  String get howToImportHevy => 'How to import your Hevy data';

  @override
  String get hideInstructions => 'Hide instructions';

  @override
  String get importInstructions =>
      'To analyze your workouts, you need to export your data from the Hevy application:';

  @override
  String get step1 => 'Open the Hevy app on your phone';

  @override
  String get step2 => 'Go to Profile > Settings';

  @override
  String get step3 => 'Select \"Export and Import Data\"';

  @override
  String get step4 => 'Tap \"Export Data\"';

  @override
  String get step5 => 'Choose \"Export Workouts\"';

  @override
  String get twoWaysToImport => 'Two ways to import';

  @override
  String get importWay1 => '• Click \"Import CSV\" above and select the file';

  @override
  String get importWay2 =>
      '• Share the CSV file directly from Hevy to this application';

  @override
  String get noDataImported => 'No data imported';

  @override
  String get clickToStart => 'Click \"Import CSV\" to start';

  @override
  String get confirmation => 'Confirmation';

  @override
  String get confirmClear =>
      'Are you sure you want to clear all imported data?';

  @override
  String workoutsImported(int count) {
    return '$count workout(s) imported';
  }

  @override
  String importedOn(String date) {
    return 'Imported on $date';
  }

  @override
  String get evolution => 'Evolution';

  @override
  String get close => 'Close';

  @override
  String get viewOnGithub => 'View the GitHub page';

  @override
  String get infoDialogDescription1 =>
      'Hevy Dashboard is an app that turns your Hevy workout exports into a clean, interactive statistics dashboard. Import your Hevy CSV and explore your training history, trends, and progress in one place.';

  @override
  String get infoDialogDescription2 =>
      'This app is open-source under MIT licence and is not official or affiliated with Hevy Studios.';

  @override
  String get infoDialogDisclaimer =>
      'You can use the GitHub page to propose changes, improvements, and report bugs.';

  @override
  String get infoDialogDeveloper => 'EidemE';

  @override
  String routeNotFound(String name) {
    return 'Route not found: $name';
  }

  @override
  String sessionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# sessions',
      one: '# session',
    );
    return '$_temp0';
  }

  @override
  String exerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '# exercises',
      one: '# exercise',
    );
    return '$_temp0';
  }
}
