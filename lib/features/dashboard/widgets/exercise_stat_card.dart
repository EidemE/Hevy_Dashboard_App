import 'package:flutter/material.dart';
import '../../../core/models/exercise_stats.dart';
import '../../../widgets/exercise_stats_header.dart';

class ExerciseStatCard extends StatelessWidget {
  final ExerciseStats stats;

  const ExerciseStatCard({
    super.key,
    required this.stats
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExerciseStatsHeader(
            stats: stats,
            showLastWeight: true,
          ),
        ),
      ),
    );
  }
}
