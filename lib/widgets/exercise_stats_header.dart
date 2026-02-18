import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../core/models/exercise_stats.dart';
import '../core/utils/exercise_utils.dart';
import '../features/import/providers/import_provider.dart';

class ExerciseStatsHeader extends StatelessWidget {
  final ExerciseStats stats;
  final bool showLastWeight;

  const ExerciseStatsHeader({
    super.key,
    required this.stats,
    this.showLastWeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Row(
          children: [
            const Icon(
              Icons.fitness_center,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Tooltip(
                message: stats.name,
                child: Text(
                  stats.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Stats
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildStatItem(
              context,
              AppLocalizations.of(context)!.sessions,
              '${stats.totalWorkouts}',
              Icons.calendar_today,
            ),
            _buildStatItem(
              context,
              AppLocalizations.of(context)!.sets,
              '${stats.totalSets}',
              Icons.repeat,
            ),
            _buildStatItem(
              context,
              AppLocalizations.of(context)!.max,
              _formatWeight(context, stats.maxWeight, stats.name),
              Icons.trending_up,
            ),
            _buildStatItem(
              context,
              AppLocalizations.of(context)!.total,
              _formatTotalWeight(context, stats.totalWeight, stats.name),
              Icons.scale,
            ),
          ],
        ),
        
        // Last weight
        if (showLastWeight) ...[
          const SizedBox(height: 12),
          _buildLastWeight(context),
        ],
      ],
    );
  }

  Widget _buildLastWeight(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          '${AppLocalizations.of(context)!.last} : ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
              ),
        ),
        Text(
          _formatWeight(context, stats.lastWeight, stats.name),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
        ),
        if (stats.lastWeightDate != null) ...[
          const SizedBox(width: 6),
          Text(
            '(${_formatDate(context, stats.lastWeightDate!)})',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
          ),
        ],
      ],
    );
  }

  String _formatWeight(BuildContext context, double weight, String exerciseName) {
    final provider = Provider.of<ImportProvider>(context, listen: false);
    final unitLabel = provider.weightUnitLabel;
    final label = '${weight.toStringAsFixed(1)} $unitLabel';
    if (ExerciseUtils.isWeighted(exerciseName)) return '+$label';
    return label;
  }

  String _formatTotalWeight(BuildContext context, double totalWeight, String exerciseName) {
    if (ExerciseUtils.isDualChart(exerciseName) || totalWeight == 0) {
      return '-';
    }

    final provider = Provider.of<ImportProvider>(context, listen: false);
    final tonsDivisor = provider.tonsDivisor;
    final tonsUnitLabel = provider.tonsUnitLabel;
    if (totalWeight >= tonsDivisor) {
      return '${(totalWeight / tonsDivisor).toStringAsFixed(1)} $tonsUnitLabel';
    }
    final unitLabel = provider.weightUnitLabel;
    return '${totalWeight.toStringAsFixed(0)} $unitLabel';
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return AppLocalizations.of(context)!.today;
    } else if (dateOnly == yesterday) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (date.year == now.year) {
      return DateFormat('dd MMM', AppLocalizations.of(context)!.localeName).format(date);
    } else {
      return DateFormat('dd MMM yyyy', AppLocalizations.of(context)!.localeName).format(date);
    }
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }
}
