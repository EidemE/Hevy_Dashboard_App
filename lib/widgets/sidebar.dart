import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/routing/app_router.dart';
import 'info_dialog.dart';

class Sidebar extends StatelessWidget {
  const Sidebar({super.key});

  Future<void> _openHevyApp(BuildContext context) async {
    try {
      // Android deep link + fallback
      if (!kIsWeb && Platform.isAndroid) {
        final Uri appUri = Uri.parse("android-app://com.hevy");
        if (await canLaunchUrl(appUri)) {
          await launchUrl(
            appUri,
            mode: LaunchMode.externalApplication,
          );
        }
      
        final playStoreUri = Uri.parse('https://play.google.com/store/apps/details?id=com.hevy');
        if (await canLaunchUrl(playStoreUri)) {
          await launchUrl(playStoreUri, mode: LaunchMode.externalApplication);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.cannotOpenHevy)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentRoute = ModalRoute.of(context)?.settings.name;
    
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          SafeArea(
            bottom: false,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.appTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  context,
                  icon: Icons.dashboard,
                  title: AppLocalizations.of(context)!.dashboard,
                  isSelected: currentRoute == AppRouter.dashboard,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(AppRouter.dashboard);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.upload_file,
                  title: AppLocalizations.of(context)!.import,
                  isSelected: currentRoute == AppRouter.import,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(AppRouter.import);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.fitness_center,
                  title: AppLocalizations.of(context)!.exercises,
                  isSelected: currentRoute == AppRouter.exercises,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(AppRouter.exercises);
                  },
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.show_chart_outlined,
                  title: AppLocalizations.of(context)!.monthlyStats,
                  isSelected: currentRoute == AppRouter.monthlyStats,
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushReplacementNamed(AppRouter.monthlyStats);
                  },
                ),
                const Divider(),
                _buildMenuItem(
                  context,
                  icon: Icons.info_outline,
                  title: AppLocalizations.of(context)!.info,
                  onTap: () => showInfoDialog(context),
                ),
              ],
            ),
          ),
          if (!kIsWeb && Platform.isAndroid)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                child: OutlinedButton.icon(
                  onPressed: () => _openHevyApp(context),
                  icon: const Icon(Icons.fitness_center),
                  label: Text(AppLocalizations.of(context)!.openHevy),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    bool isSelected = false,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor:
          Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
      onTap: onTap,
    );
  }
}
