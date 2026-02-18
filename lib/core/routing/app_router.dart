import 'package:flutter/material.dart';
import '../../features/dashboard/dashboard_page.dart';
import '../../features/dashboard/monthly_stats_page.dart';
import '../../features/import/import_page.dart';
import '../../features/exercises/exercises_page.dart';
import '../../l10n/app_localizations.dart';

class AppRouter {
  static const String dashboard = '/';
  static const String import = '/import';
  static const String exercises = '/exercises';
  static const String monthlyStats = '/monthly-stats';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case dashboard:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const DashboardPage(),
        );
      case import:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ImportPage(),
        );
      case exercises:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ExercisesPage(),
        );
      case monthlyStats:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const MonthlyStatsPage(),
        );
      default:
        return MaterialPageRoute(
          builder: (context) => Scaffold(
            body: Center(
              child: Text(
                AppLocalizations.of(context)!.routeNotFound(settings.name ?? ''),
              ),
            ),
          ),
        );
    }
  }
}
