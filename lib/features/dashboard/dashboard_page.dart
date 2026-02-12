import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sidebar.dart';
import '../import/providers/import_provider.dart';
import 'widgets/exercise_stat_card.dart';
import '../../core/routing/app_router.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.dashboard),
      ),
      drawer: const Sidebar(),
      body: Consumer<ImportProvider>(
        builder: (context, provider, child) {
          final isWideScreen = MediaQuery.of(context).size.width > 900;
          
          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: isWideScreen
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Layout
                      Flexible(
                        flex: 4,
                        child: _buildTopExercises(context, provider),
                      ),
                      const SizedBox(width: 16),
                      Flexible(
                        flex: 7,
                        child: _buildRightSection(context, provider),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRightSection(context, provider),
                      const SizedBox(height: 16),
                      _buildTopExercises(context, provider),
                    ],
                  ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopExercises(BuildContext context, ImportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.topExercises,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.exercises);
              },
              icon: const Icon(Icons.arrow_forward),
              label: Text(AppLocalizations.of(context)!.seeAll),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (provider.exerciseStats.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.fitness_center_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.noExercise,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.noExerciseDesc,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...provider.exerciseStats.take(5).map((stat) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ExerciseStatCard(stats: stat),
            );
          }),
      ],
    );
  }

  Widget _buildRightSection(BuildContext context, ImportProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (provider.hasData) ...[
          _buildActivityCalendar(context, provider),
          const SizedBox(height: 16),
          _buildStatsComparison(context, provider),
          const SizedBox(height: 24),
        ],
        Text(
          AppLocalizations.of(context)!.globalStats,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        if (provider.hasData) ...[
          LayoutBuilder(
            builder: (context, constraints) {
              // Global stats
              double totalWeight = 0;
              for (var csvData in provider.data) {
                for (var workout in csvData.workouts) {
                  for (var exercise in workout.exercises) {
                    for (var set in exercise.sets) {
                      final weight = set.weight ?? 0;
                      if (weight > 0) {
                        totalWeight += weight;
                      }
                    }
                  }
                }
              }
              
              String weightValue;
              if (totalWeight >= 1000) {
                weightValue = '${(totalWeight / 1000).toStringAsFixed(1)} t';
              } else {
                weightValue = '${totalWeight.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kg}';
              }
              
              final cards = [
                _buildSummaryCard(
                  context,
                  AppLocalizations.of(context)!.workoutsCompleted,
                  '${provider.data.first.workouts.length}',
                  Icons.calendar_today,
                  Colors.blue,
                ),
                _buildSummaryCard(
                  context,
                  AppLocalizations.of(context)!.differentExercises,
                  '${provider.exerciseStats.length}',
                  Icons.fitness_center,
                  Colors.green,
                ),
                _buildSummaryCard(
                  context,
                  AppLocalizations.of(context)!.setsCompleted,
                  '${provider.exerciseStats.fold<int>(0, (sum, stat) => sum + stat.totalSets)}',
                  Icons.repeat,
                  Colors.orange,
                ),
                _buildSummaryCard(
                  context,
                  AppLocalizations.of(context)!.totalWeight,
                  weightValue,
                  Icons.scale,
                  Colors.purple,
                ),
              ];

              Widget buildRow(int leftIndex, int rightIndex) {
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: cards[leftIndex]),
                      const SizedBox(width: 12),
                      Expanded(child: cards[rightIndex]),
                    ],
                  ),
                );
              }

              return Column(
                children: [
                  buildRow(0, 1),
                  const SizedBox(height: 12),
                  buildRow(2, 3),
                ],
              );
            },
          ),
        ] else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!.noData,
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActivityCalendar(BuildContext context, ImportProvider provider) {
    // Activity data
    final now = DateTime.now();
    final last10Days = List.generate(10, (index) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 9 - index));
    });

    final workoutDurations = <DateTime, int>{};
    for (var csvData in provider.data) {
      for (var workout in csvData.workouts) {
        final workoutDate = DateTime(
          workout.dateStart.year,
          workout.dateStart.month,
          workout.dateStart.day,
        );
        workoutDurations[workoutDate] = (workoutDurations[workoutDate] ?? 0) + workout.durationInMinutes;
      }
    }

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.activity,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 500;
                
                if (isNarrow) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: last10Days.skip(3).map((date) {
                      return _buildDayCircle(context, date, workoutDurations, now, isNarrow);
                    }).toList(),
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: last10Days.map((date) {
                      return _buildDayCircle(context, date, workoutDurations, now);
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCircle(BuildContext context, DateTime date, Map<DateTime, int> workoutDurations, DateTime now, [bool isNarrow = false]) {
    final totalMinutes = workoutDurations[date] ?? 0;
    final hasWorkout = totalMinutes > 0;
    final isToday = DateTime(now.year, now.month, now.day) == date;
    
    String formattedDuration = '';
    if (hasWorkout) {
      if (totalMinutes >= 60) {
        final hours = totalMinutes ~/ 60;
        final minutes = totalMinutes % 60;
        if (minutes > 0) {
          formattedDuration = '${hours}h${minutes.toString().padLeft(2, '0')}';
        } else {
          formattedDuration = '${hours}h';
        }
      } else {
        formattedDuration = '${totalMinutes}m';
      }
    }
    
    return Column(
      children: [
        Container(
          width: isNarrow ? 34 : 40,
          height: isNarrow ? 34 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hasWorkout ? Colors.green : Colors.grey[300],
            border: isToday ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Center(
            child: hasWorkout
                ? Text(
                    formattedDuration,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isNarrow ? 8 : 10,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Icon(
                    Icons.close,
                    color: Colors.grey[500],
                    size: isNarrow ? 18 : 20,
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DateFormat('EEE', AppLocalizations.of(context)!.localeName).format(date),
          style: TextStyle(
            fontSize: 10,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          DateFormat('dd', AppLocalizations.of(context)!.localeName).format(date),
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsComparison(BuildContext context, ImportProvider provider) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last30DaysStart = today.subtract(const Duration(days: 29));
    final previous30DaysStart = today.subtract(const Duration(days: 59));
    final previous30DaysEnd = today.subtract(const Duration(days: 30));

    // 30-day comparison
    final allWorkouts = <({DateTime date, int duration, Set<String> exercises, double totalWeight})>[];
    for (var csvData in provider.data) {
      for (var workout in csvData.workouts) {
        final workoutDate = DateTime(
          workout.dateStart.year,
          workout.dateStart.month,
          workout.dateStart.day,
        );
        final exercises = workout.exercises.map((e) => e.name).toSet();
        final totalWeight = workout.exercises.fold<double>(0, (sum, e) => 
          sum + e.sets.fold<double>(0, (sum2, s) {
            final weight = s.weight ?? 0;
            return sum2 + (weight > 0 ? weight : 0);
          }));
        allWorkouts.add((
          date: workoutDate,
          duration: workout.durationInMinutes,
          exercises: exercises,
          totalWeight: totalWeight,
        ));
      }
    }

    final last30Workouts = allWorkouts.where((w) => 
      w.date.isAfter(last30DaysStart.subtract(const Duration(days: 1))) && 
      w.date.isBefore(today.add(const Duration(days: 1)))
    ).toList();

    final previous30Workouts = allWorkouts.where((w) => 
      w.date.isAfter(previous30DaysStart.subtract(const Duration(days: 1))) && 
      w.date.isBefore(previous30DaysEnd.add(const Duration(days: 1)))
    ).toList();

    final last30Count = last30Workouts.length;
    final last30TotalTime = last30Workouts.fold<int>(0, (sum, w) => sum + w.duration);
    final last30AvgTime = last30Count > 0 ? last30TotalTime / last30Count : 0.0;
    final last30UniqueExercises = last30Workouts.fold<Set<String>>(
      {},
      (set, w) => set..addAll(w.exercises)
    ).length;
    final last30AvgExercises = last30Count > 0 
      ? last30Workouts.fold<int>(0, (sum, w) => sum + w.exercises.length) / last30Count 
      : 0.0;
    final last30TotalWeight = last30Workouts.fold<double>(0, (sum, w) => sum + w.totalWeight);
    final last30AvgWeight = last30Count > 0 ? last30TotalWeight / last30Count : 0.0;

    final prev30Count = previous30Workouts.length;
    final prev30TotalTime = previous30Workouts.fold<int>(0, (sum, w) => sum + w.duration);
    final prev30AvgTime = prev30Count > 0 ? prev30TotalTime / prev30Count : 0.0;
    final prev30UniqueExercises = previous30Workouts.fold<Set<String>>(
      {},
      (set, w) => set..addAll(w.exercises)
    ).length;
    final prev30AvgExercises = prev30Count > 0 
      ? previous30Workouts.fold<int>(0, (sum, w) => sum + w.exercises.length) / prev30Count 
      : 0.0;
    final prev30TotalWeight = previous30Workouts.fold<double>(0, (sum, w) => sum + w.totalWeight);
    final prev30AvgWeight = prev30Count > 0 ? prev30TotalWeight / prev30Count : 0.0;

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
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.performance30Days,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.monthlyStats);
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16),
                  label: Text(AppLocalizations.of(context)!.seeMore),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.sessions,
              last30Count.toString(),
              prev30Count.toDouble(),
              last30Count.toDouble(),
              prev30Count.toString(),
              isHigherBetter: true,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.totalTime,
              _formatDuration(last30TotalTime),
              prev30TotalTime.toDouble(),
              last30TotalTime.toDouble(),
              _formatDuration(prev30TotalTime),
              isHigherBetter: true,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.avgTime,
              _formatDuration(last30AvgTime.round()),
              prev30AvgTime,
              last30AvgTime,
              _formatDuration(prev30AvgTime.round()),
              isHigherBetter: true,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.differentExercisesShort,
              last30UniqueExercises.toString(),
              prev30UniqueExercises.toDouble(),
              last30UniqueExercises.toDouble(),
              prev30UniqueExercises.toString(),
              isHigherBetter: true,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.exercisesPerSession,
              last30AvgExercises.toStringAsFixed(1),
              prev30AvgExercises,
              last30AvgExercises,
              prev30AvgExercises.toStringAsFixed(1),
              isHigherBetter: true,
            ),
            const Divider(height: 24),
            _buildStatRow(
              context,
              AppLocalizations.of(context)!.avgWeightPerSession,
              '${last30AvgWeight.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kg}',
              prev30AvgWeight,
              last30AvgWeight,
              '${prev30AvgWeight.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kg}',
              isHigherBetter: true,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int minutes) {
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final mins = minutes % 60;
      return '${hours}h${mins > 0 ? ' ${mins}min' : ''}';
    } else {
      return '${minutes}min';
    }
  }

  Widget _buildStatRow(
    BuildContext context,
    String label,
    String value,
    double previousValue,
    double currentValue,
    String previousValueFormatted,
    {required bool isHigherBetter}
  ) {
    final hasChange = previousValue != 0;
    final percentChange = hasChange 
      ? ((currentValue - previousValue) / previousValue * 100) 
      : 0.0;
    
    final isImprovement = (isHigherBetter && percentChange > 0) || 
                          (!isHigherBetter && percentChange < 0);
    final color = percentChange == 0 
      ? Colors.grey 
      : (isImprovement ? Colors.green : Colors.red);
    final icon = percentChange > 0 
      ? Icons.trending_up 
      : (percentChange < 0 ? Icons.trending_down : Icons.trending_flat);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 2,
          child: hasChange
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Icon(icon, color: color, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${percentChange.abs().toStringAsFixed(0)}%',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '($previousValueFormatted)',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              )
            : Text(
                'N/A',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                textAlign: TextAlign.end,
              ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
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
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 12.0 : 16.0),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: isMobile ? 24 : 32),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 20 : 28,
                        ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: isMobile ? 12 : 14,
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
}
