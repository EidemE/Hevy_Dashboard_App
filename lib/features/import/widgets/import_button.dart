import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/import_provider.dart';

class ImportButton extends StatelessWidget {
  const ImportButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ImportProvider>(
      builder: (context, provider, child) {
        return ElevatedButton.icon(
          onPressed: provider.isLoading ? null : () => provider.importCsv(),
          icon: provider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload_file),
          label: Text(
            provider.hasData ? 'Réimporter CSV' : 'Importer CSV',
          ),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
        );
      },
    );
  }
}
