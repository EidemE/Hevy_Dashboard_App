import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'core/theme/app_theme.dart';
import 'core/routing/app_router.dart';
import 'features/import/providers/import_provider.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR', null);
  await initializeDateFormatting('en_US', null);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  StreamSubscription? _intentSubscription;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  late final ImportProvider _importProvider;

  @override
  void initState() {
    super.initState();
    
    // Provider
    _importProvider = ImportProvider()..loadSavedData();
    
    // Lifecycle
    WidgetsBinding.instance.addObserver(this);

    // Sharing (mobile only)
    if (!kIsWeb) {
      _initializeSharing();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.resumed) {
      _importProvider.loadSavedData();
    }
  }

  void _initializeSharing() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ReceiveSharingIntent.instance.getInitialMedia().then((List<SharedMediaFile> value) {
        if (value.isNotEmpty) {
          _handleSharedFiles(value);
        }
      }).catchError((err) {
        debugPrint("Erreur getInitialMedia: $err");
      });
    });

    _intentSubscription = ReceiveSharingIntent.instance.getMediaStream().listen(
      (List<SharedMediaFile> value) {
        _handleSharedFiles(value);
      },
      onError: (err) {
        debugPrint("Erreur lors de la réception du fichier: $err");
      },
    );
  }

  void _handleSharedFiles(List<SharedMediaFile> files) {
    if (files.isEmpty) return;

    final csvFile = files.firstWhere(
      (file) => file.path.toLowerCase().endsWith('.csv'),
      orElse: () => files.first,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _importProvider.importCsvFromPath(csvFile.path).then((_) {
        navigatorKey.currentState?.pushReplacementNamed(AppRouter.import);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _intentSubscription?.cancel();
    _importProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _importProvider,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Hevy Dashboard',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''),
          Locale('fr', ''),
        ],
        localeResolutionCallback: (locale, supportedLocales) {
          // Locale resolution
          if (locale == null) {
            return supportedLocales.first;
          }
          
          for (final supportedLocale in supportedLocales) {
            if (supportedLocale.languageCode == locale.languageCode) {
              return supportedLocale;
            }
          }
          
          return supportedLocales.first;
        },
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        initialRoute: AppRouter.dashboard,
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
