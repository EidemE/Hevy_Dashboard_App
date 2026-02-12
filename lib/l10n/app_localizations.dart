import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Hevy Dashboard'**
  String get appTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @import.
  ///
  /// In en, this message translates to:
  /// **'Import'**
  String get import;

  /// No description provided for @monthlyStats.
  ///
  /// In en, this message translates to:
  /// **'Monthly Stats'**
  String get monthlyStats;

  /// No description provided for @topExercises.
  ///
  /// In en, this message translates to:
  /// **'Top Exercises'**
  String get topExercises;

  /// No description provided for @seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get seeAll;

  /// No description provided for @noExercise.
  ///
  /// In en, this message translates to:
  /// **'No exercises'**
  String get noExercise;

  /// No description provided for @noExerciseDesc.
  ///
  /// In en, this message translates to:
  /// **'Import your CSV data to get started'**
  String get noExerciseDesc;

  /// No description provided for @workoutsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Workouts completed'**
  String get workoutsCompleted;

  /// No description provided for @differentExercises.
  ///
  /// In en, this message translates to:
  /// **'Different exercises'**
  String get differentExercises;

  /// No description provided for @setsCompleted.
  ///
  /// In en, this message translates to:
  /// **'Sets completed'**
  String get setsCompleted;

  /// No description provided for @totalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total weight lifted'**
  String get totalWeight;

  /// No description provided for @sessions.
  ///
  /// In en, this message translates to:
  /// **'Sessions'**
  String get sessions;

  /// No description provided for @sets.
  ///
  /// In en, this message translates to:
  /// **'Sets'**
  String get sets;

  /// No description provided for @max.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @last.
  ///
  /// In en, this message translates to:
  /// **'Last'**
  String get last;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @repsProgressionTitle.
  ///
  /// In en, this message translates to:
  /// **'Reps progression'**
  String get repsProgressionTitle;

  /// No description provided for @weightRepsProgressionTitle.
  ///
  /// In en, this message translates to:
  /// **'Weight & reps progression'**
  String get weightRepsProgressionTitle;

  /// No description provided for @maxWeightProgressionTitle.
  ///
  /// In en, this message translates to:
  /// **'Max weight progression'**
  String get maxWeightProgressionTitle;

  /// No description provided for @allExercises.
  ///
  /// In en, this message translates to:
  /// **'All exercises'**
  String get allExercises;

  /// Title with exercise count
  ///
  /// In en, this message translates to:
  /// **'All exercises ({count})'**
  String allExercisesCount(int count);

  /// No description provided for @changeSorting.
  ///
  /// In en, this message translates to:
  /// **'Change sorting'**
  String get changeSorting;

  /// No description provided for @sortByWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Number of sessions'**
  String get sortByWorkouts;

  /// No description provided for @sortBySets.
  ///
  /// In en, this message translates to:
  /// **'Number of sets'**
  String get sortBySets;

  /// No description provided for @sortByMaxWeight.
  ///
  /// In en, this message translates to:
  /// **'Maximum weight'**
  String get sortByMaxWeight;

  /// No description provided for @sortByTotalWeight.
  ///
  /// In en, this message translates to:
  /// **'Total weight'**
  String get sortByTotalWeight;

  /// No description provided for @sortByName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortByName;

  /// No description provided for @sortLabelWorkouts.
  ///
  /// In en, this message translates to:
  /// **'By sessions'**
  String get sortLabelWorkouts;

  /// No description provided for @sortLabelSets.
  ///
  /// In en, this message translates to:
  /// **'By sets'**
  String get sortLabelSets;

  /// No description provided for @sortLabelWeight.
  ///
  /// In en, this message translates to:
  /// **'By weight'**
  String get sortLabelWeight;

  /// No description provided for @sortLabelTotal.
  ///
  /// In en, this message translates to:
  /// **'By total'**
  String get sortLabelTotal;

  /// No description provided for @sortLabelName.
  ///
  /// In en, this message translates to:
  /// **'By name'**
  String get sortLabelName;

  /// No description provided for @searchExercises.
  ///
  /// In en, this message translates to:
  /// **'Search exercises...'**
  String get searchExercises;

  /// No description provided for @noExercisesFound.
  ///
  /// In en, this message translates to:
  /// **'No exercises found'**
  String get noExercisesFound;

  /// No description provided for @noExercisesFoundDesc.
  ///
  /// In en, this message translates to:
  /// **'Try modifying your search'**
  String get noExercisesFoundDesc;

  /// No description provided for @importData.
  ///
  /// In en, this message translates to:
  /// **'Import my data'**
  String get importData;

  /// No description provided for @importDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Import your CSV file exported from Hevy'**
  String get importDataDesc;

  /// No description provided for @selectFile.
  ///
  /// In en, this message translates to:
  /// **'Select file'**
  String get selectFile;

  /// No description provided for @importInProgress.
  ///
  /// In en, this message translates to:
  /// **'Import in progress...'**
  String get importInProgress;

  /// No description provided for @importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Import successful!'**
  String get importSuccess;

  /// No description provided for @importSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'{count} workouts imported'**
  String importSuccessDesc(int count);

  /// No description provided for @importError.
  ///
  /// In en, this message translates to:
  /// **'Import error'**
  String get importError;

  /// No description provided for @dataAlreadyImported.
  ///
  /// In en, this message translates to:
  /// **'Data already imported'**
  String get dataAlreadyImported;

  /// No description provided for @dataAlreadyImportedDesc.
  ///
  /// In en, this message translates to:
  /// **'Do you want to reimport?'**
  String get dataAlreadyImportedDesc;

  /// No description provided for @reimport.
  ///
  /// In en, this message translates to:
  /// **'Reimport'**
  String get reimport;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @monthlyStatsTitle.
  ///
  /// In en, this message translates to:
  /// **'Monthly statistics'**
  String get monthlyStatsTitle;

  /// No description provided for @monthlyStatsDesc.
  ///
  /// In en, this message translates to:
  /// **'Evolution of your performance over the months'**
  String get monthlyStatsDesc;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @noDataDesc.
  ///
  /// In en, this message translates to:
  /// **'Import your CSV data to see your statistics'**
  String get noDataDesc;

  /// No description provided for @noSession.
  ///
  /// In en, this message translates to:
  /// **'No session'**
  String get noSession;

  /// No description provided for @totalTime.
  ///
  /// In en, this message translates to:
  /// **'Total time'**
  String get totalTime;

  /// No description provided for @avgTime.
  ///
  /// In en, this message translates to:
  /// **'Avg. time'**
  String get avgTime;

  /// No description provided for @differentExercisesShort.
  ///
  /// In en, this message translates to:
  /// **'Diff. exercises'**
  String get differentExercisesShort;

  /// No description provided for @exercisesPerSession.
  ///
  /// In en, this message translates to:
  /// **'Ex./session'**
  String get exercisesPerSession;

  /// No description provided for @avgWeightPerSession.
  ///
  /// In en, this message translates to:
  /// **'Avg. weight/session'**
  String get avgWeightPerSession;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'reps'**
  String get reps;

  /// No description provided for @tons.
  ///
  /// In en, this message translates to:
  /// **'t'**
  String get tons;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @openHevy.
  ///
  /// In en, this message translates to:
  /// **'Open Hevy'**
  String get openHevy;

  /// No description provided for @cannotOpenHevy.
  ///
  /// In en, this message translates to:
  /// **'Cannot open Hevy application'**
  String get cannotOpenHevy;

  /// No description provided for @globalStats.
  ///
  /// In en, this message translates to:
  /// **'Global statistics'**
  String get globalStats;

  /// No description provided for @activity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activity;

  /// No description provided for @performance30Days.
  ///
  /// In en, this message translates to:
  /// **'Performance (last 30 days)'**
  String get performance30Days;

  /// No description provided for @seeMore.
  ///
  /// In en, this message translates to:
  /// **'See more'**
  String get seeMore;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @howToImportHevy.
  ///
  /// In en, this message translates to:
  /// **'How to import your Hevy data'**
  String get howToImportHevy;

  /// No description provided for @hideInstructions.
  ///
  /// In en, this message translates to:
  /// **'Hide instructions'**
  String get hideInstructions;

  /// No description provided for @importInstructions.
  ///
  /// In en, this message translates to:
  /// **'To analyze your workouts, you need to export your data from the Hevy application:'**
  String get importInstructions;

  /// No description provided for @step1.
  ///
  /// In en, this message translates to:
  /// **'Open the Hevy app on your phone'**
  String get step1;

  /// No description provided for @step2.
  ///
  /// In en, this message translates to:
  /// **'Go to Profile > Settings'**
  String get step2;

  /// No description provided for @step3.
  ///
  /// In en, this message translates to:
  /// **'Select \"Export and import data\"'**
  String get step3;

  /// No description provided for @step4.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Export data\"'**
  String get step4;

  /// No description provided for @step5.
  ///
  /// In en, this message translates to:
  /// **'Choose \"Export workouts\"'**
  String get step5;

  /// No description provided for @twoWaysToImport.
  ///
  /// In en, this message translates to:
  /// **'Two ways to import'**
  String get twoWaysToImport;

  /// No description provided for @importWay1.
  ///
  /// In en, this message translates to:
  /// **'• Click \"Import CSV\" above and select the file'**
  String get importWay1;

  /// No description provided for @importWay2.
  ///
  /// In en, this message translates to:
  /// **'• Share the CSV file directly from Hevy to this application'**
  String get importWay2;

  /// No description provided for @noDataImported.
  ///
  /// In en, this message translates to:
  /// **'No data imported'**
  String get noDataImported;

  /// No description provided for @clickToStart.
  ///
  /// In en, this message translates to:
  /// **'Click \"Import CSV\" to start'**
  String get clickToStart;

  /// No description provided for @confirmation.
  ///
  /// In en, this message translates to:
  /// **'Confirmation'**
  String get confirmation;

  /// No description provided for @confirmClear.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all imported data?'**
  String get confirmClear;

  /// No description provided for @workoutsImported.
  ///
  /// In en, this message translates to:
  /// **'{count} workout(s) imported'**
  String workoutsImported(int count);

  /// No description provided for @importedOn.
  ///
  /// In en, this message translates to:
  /// **'Imported on {date}'**
  String importedOn(String date);

  /// No description provided for @evolution.
  ///
  /// In en, this message translates to:
  /// **'Evolution'**
  String get evolution;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @viewOnGithub.
  ///
  /// In en, this message translates to:
  /// **'View the GitHub page'**
  String get viewOnGithub;

  /// No description provided for @infoDialogDescription1.
  ///
  /// In en, this message translates to:
  /// **'Hevy Dashboard is an app that turns your Hevy workout exports into a clean, interactive statistics dashboard. Import your Hevy CSV and explore your training history, trends, and progress in one place.'**
  String get infoDialogDescription1;

  /// No description provided for @infoDialogDescription2.
  ///
  /// In en, this message translates to:
  /// **'This app is open-source under MIT licence and is not official or affiliated with Hevy Studios.'**
  String get infoDialogDescription2;

  /// No description provided for @infoDialogDisclaimer.
  ///
  /// In en, this message translates to:
  /// **'You can use the GitHub page to propose changes, improvements, and report bugs.'**
  String get infoDialogDisclaimer;

  /// No description provided for @infoDialogDeveloper.
  ///
  /// In en, this message translates to:
  /// **'EidemE'**
  String get infoDialogDeveloper;

  /// No description provided for @routeNotFound.
  ///
  /// In en, this message translates to:
  /// **'Route not found: {name}'**
  String routeNotFound(String name);

  /// No description provided for @sessionCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# session} other{# sessions}}'**
  String sessionCount(int count);

  /// No description provided for @exerciseCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{# exercise} other{# exercises}}'**
  String exerciseCount(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
