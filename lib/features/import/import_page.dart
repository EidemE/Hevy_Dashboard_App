import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import 'providers/import_provider.dart';
import 'widgets/import_button.dart';
import '../../widgets/sidebar.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  bool _showInstructions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.importData),
      ),
      drawer: const Sidebar(),
      body: Consumer<ImportProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Header
                _buildHeader(context, provider),
                const SizedBox(height: 16),

                // Error
                if (provider.error != null) ...[
                  _buildErrorCard(provider.error!),
                  const SizedBox(height: 16),
                ],

                // Import info
                if (provider.hasData) ...[
                  _buildInfoCard(provider),
                  const SizedBox(height: 16),
                ],

                // Instructions
                if ((!provider.hasData || provider.error != null) && !provider.isLoading && _showInstructions) ...[
                  _buildInstructionsCard(),
                  const SizedBox(height: 16),
                ],

                // Empty state
                if (!provider.hasData && !provider.isLoading && provider.error == null)
                  _buildEmptyState(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ImportProvider provider) {
    return Row(
      children: [
        const ImportButton(),
        const SizedBox(width: 16),
        if (provider.hasData)
          ElevatedButton.icon(
            onPressed: () => _showClearConfirmation(context, provider),
            icon: const Icon(Icons.delete_outline),
            label: Text(AppLocalizations.of(context)!.clear),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            ),
          ),
      ],
    );
  }

  Widget _buildErrorCard(String error) {
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.onErrorContainer,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Erreur d\'importation',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Provider.of<ImportProvider>(context, listen: false).clearError();
              },
              color: Theme.of(context).colorScheme.onErrorContainer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(ImportProvider provider) {
    final dateFormat = DateFormat('dd/MM/yyyy à HH:mm');
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      color: isDark ? Colors.green[900]!.withValues(alpha: 0.2) : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.workoutsImported(provider.data.fold<int>(0, (sum, csvData) => sum + csvData.workouts.length)),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green[300] : Colors.green[700],
                    ),
                  ),
                  if (provider.lastImportDate != null)
                    Text(
                      AppLocalizations.of(context)!.importedOn(dateFormat.format(provider.lastImportDate!)),
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.green[400] : Colors.green[700],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.howToImportHevy,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    setState(() {
                      _showInstructions = false;
                    });
                  },
                  tooltip: AppLocalizations.of(context)!.hideInstructions,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.importInstructions,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildInstructionStep(
              '1',
              AppLocalizations.of(context)!.step1,
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '2',
              AppLocalizations.of(context)!.step2,
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '3',
              AppLocalizations.of(context)!.step3,
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '4',
              AppLocalizations.of(context)!.step4,
            ),
            const SizedBox(height: 12),
            _buildInstructionStep(
              '5',
              AppLocalizations.of(context)!.step5,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline, 
                        size: 20, 
                        color: const Color.fromARGB(255, 5, 56, 133)
                      ),
                      const SizedBox(width: 6),
                      Text(
                        AppLocalizations.of(context)!.twoWaysToImport,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.importWay1,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppLocalizations.of(context)!.importWay2,
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionStep(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.upload_file,
            size: 64,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noDataImported,
            style: TextStyle(
              fontSize: 18,
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.clickToStart,
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, ImportProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.confirmation),
        content: Text(
          'Êtes-vous sûr de vouloir effacer toutes les données importées ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              provider.clearData();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(AppLocalizations.of(context)!.clear),
          ),
        ],
      ),
    );
  }
}
