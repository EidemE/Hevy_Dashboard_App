import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/sidebar.dart';
import '../import/providers/import_provider.dart';

class MonthlyStatsPage extends StatefulWidget {
  const MonthlyStatsPage({super.key});

  @override
  State<MonthlyStatsPage> createState() => _MonthlyStatsPageState();
}

class _MonthlyStatsPageState extends State<MonthlyStatsPage> {
  String _selectedMetric = 'workouts';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.monthlyStatsTitle),
      ),
      drawer: const Sidebar(),
      body: Consumer<ImportProvider>(
        builder: (context, provider, child) {
          if (provider.data.isEmpty) {
            return SafeArea(
              top: false,
              child: _buildEmptyState(),
            );
          }

          final monthlyStats = _calculateMonthlyStats(provider);

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppLocalizations.of(context)!.monthlyStatsDesc,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 12),
                  _buildChart(monthlyStats, provider),
                  const SizedBox(height: 18),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1000
                          ? 3
                          : (constraints.maxWidth > 600 ? 2 : 1);
                      final isSingleColumn = crossAxisCount == 1;

                      if (isSingleColumn) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: monthlyStats.map((stat) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _buildMonthCard(
                                context,
                                stat,
                                provider,
                                isSingleColumn: true,
                              ),
                            );
                          }).toList(),
                        );
                      }

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisExtent: 220,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: monthlyStats.length,
                        itemBuilder: (context, index) {
                          return _buildMonthCard(
                            context,
                            monthlyStats[index],
                            provider,
                            isSingleColumn: false,
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChart(List<MonthStat> stats, ImportProvider provider) {
    if (stats.isEmpty) return const SizedBox.shrink();

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
                Text(
                  AppLocalizations.of(context)!.evolution,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                DropdownButton<String>(
                  value: _selectedMetric,
                  underline: const SizedBox(),
                  items: [
                    DropdownMenuItem(
                      value: 'workouts',
                      child: Text(AppLocalizations.of(context)!.sessions),
                    ),
                    DropdownMenuItem(
                      value: 'totalTime',
                      child: Text(AppLocalizations.of(context)!.totalTime),
                    ),
                    DropdownMenuItem(
                      value: 'avgTime',
                      child: Text(AppLocalizations.of(context)!.avgTime),
                    ),
                    DropdownMenuItem(
                      value: 'uniqueExercises',
                      child: Text(AppLocalizations.of(context)!.differentExercisesShort),
                    ),
                    DropdownMenuItem(
                      value: 'avgExercises',
                      child: Text(AppLocalizations.of(context)!.exercisesPerSession),
                    ),
                    DropdownMenuItem(
                      value: 'avgWeight',
                      child: Text(AppLocalizations.of(context)!.avgWeightPerSession),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedMetric = value;
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          if (spot.spotIndex >= 0 && spot.spotIndex < stats.length) {
                            final reversedStats = stats.reversed.toList();
                            final stat = reversedStats[spot.spotIndex];
                            final localeName = AppLocalizations.of(context)!.localeName;
                            final monthFormat = DateFormat('MMM yyyy', localeName);
                            final localizations = AppLocalizations.of(context)!;
                            String value;
                            switch (_selectedMetric) {
                              case 'workouts':
                                value = localizations.sessionCount(stat.workoutCount);
                                break;
                              case 'totalTime':
                                value = _formatDuration(stat.totalTime);
                                break;
                              case 'avgTime':
                                value = _formatDuration(stat.avgTime.round());
                                break;
                              case 'uniqueExercises':
                                value = localizations.exerciseCount(stat.uniqueExercises);
                                break;
                              case 'avgExercises':
                                value = stat.avgExercises.toStringAsFixed(1);
                                break;
                              case 'avgWeight':
                                value = '${stat.avgWeight.toStringAsFixed(0)} ${provider.weightUnitLabel}';
                                break;
                              default:
                                value = spot.y.toInt().toString();
                            }
                            return LineTooltipItem(
                              '${monthFormat.format(stat.month)}\n$value',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                          return null;
                        }).toList();
                      },
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 && value.toInt() < stats.length) {
                            final stat = stats.reversed.toList()[value.toInt()];
                            final localeName = AppLocalizations.of(context)!.localeName;
                            final monthName = DateFormat('MMMM', localeName).format(stat.month);
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                monthName[0].toUpperCase(),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 10,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: (stats.length - 1).toDouble(),
                  minY: 0,
                  maxY: _getMaxY(stats),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _getSpots(stats),
                      isCurved: false,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          final reversedStats = stats.reversed.toList();
                          final isEmpty = index >= 0 && index < reversedStats.length 
                              ? reversedStats[index].workoutCount == 0
                              : false;
                          return FlDotCirclePainter(
                            radius: 4,
                            color: isEmpty ? Colors.grey : Theme.of(context).colorScheme.primary,
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getSpots(List<MonthStat> stats) {
    final reversedStats = stats.reversed.toList();
    return List.generate(reversedStats.length, (index) {
      final stat = reversedStats[index];
      double value;
      switch (_selectedMetric) {
        case 'workouts':
          value = stat.workoutCount.toDouble();
          break;
        case 'totalTime':
          value = stat.totalTime.toDouble();
          break;
        case 'avgTime':
          value = stat.avgTime;
          break;
        case 'uniqueExercises':
          value = stat.uniqueExercises.toDouble();
          break;
        case 'avgExercises':
          value = stat.avgExercises;
          break;
        case 'avgWeight':
          value = stat.avgWeight;
          break;
        default:
          value = 0;
      }
      return FlSpot(index.toDouble(), value);
    });
  }

  double _getMaxY(List<MonthStat> stats) {
    double maxValue = 0;
    for (final stat in stats) {
      double value;
      switch (_selectedMetric) {
        case 'workouts':
          value = stat.workoutCount.toDouble();
          break;
        case 'totalTime':
          value = stat.totalTime.toDouble();
          break;
        case 'avgTime':
          value = stat.avgTime;
          break;
        case 'uniqueExercises':
          value = stat.uniqueExercises.toDouble();
          break;
        case 'avgExercises':
          value = stat.avgExercises;
          break;
        case 'avgWeight':
          value = stat.avgWeight;
          break;
        default:
          value = 0;
      }
      if (value > maxValue) maxValue = value;
    }
    return maxValue * 1.2;
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.noData,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  List<MonthStat> _calculateMonthlyStats(ImportProvider provider) {
    if (provider.data.isEmpty) return [];

    final allWorkouts = provider.data.expand((csvData) => csvData.workouts).toList();
    if (allWorkouts.isEmpty) return [];

    allWorkouts.sort((a, b) => a.dateStart.compareTo(b.dateStart));
    final firstMonth = DateTime(allWorkouts.first.dateStart.year, allWorkouts.first.dateStart.month, 1);
    final lastMonth = DateTime(allWorkouts.last.dateStart.year, allWorkouts.last.dateStart.month, 1);

    final List<MonthStat> stats = [];
    DateTime currentMonth = firstMonth;

    while (currentMonth.isBefore(lastMonth) || currentMonth.isAtSameMomentAs(lastMonth)) {
      final monthStart = DateTime(currentMonth.year, currentMonth.month, 1);
      final monthEnd = DateTime(currentMonth.year, currentMonth.month + 1, 0, 23, 59, 59);

      final monthWorkouts = allWorkouts
          .where((workout) =>
              workout.dateStart.isAfter(monthStart.subtract(const Duration(seconds: 1))) &&
              workout.dateStart.isBefore(monthEnd.add(const Duration(seconds: 1))))
          .toList();

      if (monthWorkouts.isNotEmpty) {
        final workoutCount = monthWorkouts.length;
        final totalTime = monthWorkouts.fold<int>(0, (sum, w) => sum + w.durationInMinutes);
        final uniqueExercises = monthWorkouts.expand((w) => w.exercises.map((e) => e.name)).toSet().length;
        final totalExercises = monthWorkouts.fold<int>(0, (sum, w) => sum + w.exercises.length);
        final totalWeight = monthWorkouts.fold<double>(0, (sum, w) => 
          sum + w.exercises.fold<double>(0, (sum2, e) => 
            sum2 + e.sets.fold<double>(0, (sum3, s) {
              final weight = s.weight ?? 0;
              return sum3 + (weight > 0 ? weight : 0);
            })));

        stats.add(MonthStat(
          month: currentMonth,
          workoutCount: workoutCount,
          totalTime: totalTime,
          avgTime: totalTime / workoutCount,
          uniqueExercises: uniqueExercises,
          avgExercises: totalExercises / workoutCount,
          avgWeight: totalWeight / workoutCount,
        ));
      } else {
        stats.add(MonthStat(
          month: currentMonth,
          workoutCount: 0,
          totalTime: 0,
          avgTime: 0,
          uniqueExercises: 0,
          avgExercises: 0,
          avgWeight: 0,
        ));
      }

      currentMonth = DateTime(currentMonth.year, currentMonth.month + 1, 1);
    }

    return stats.reversed.toList();
  }

  Widget _buildMonthCard(
    BuildContext context,
    MonthStat stat,
    ImportProvider provider,
    {required bool isSingleColumn}
  ) {
    final monthFormat = DateFormat('MMMM yyyy', AppLocalizations.of(context)!.localeName);
    final monthName = monthFormat.format(stat.month);
    final capitalizedMonth = monthName[0].toUpperCase() + monthName.substring(1);
    final isEmpty = stat.workoutCount == 0;

    final statRows = [
      _buildCompactStatRow(context, Icons.fitness_center, AppLocalizations.of(context)!.sessions, stat.workoutCount.toString()),
      _buildCompactStatRow(context, Icons.timer_outlined, AppLocalizations.of(context)!.totalTime, _formatDuration(stat.totalTime)),
      _buildCompactStatRow(context, Icons.schedule, AppLocalizations.of(context)!.avgTime, _formatDuration(stat.avgTime.round())),
      _buildCompactStatRow(context, Icons.category_outlined, AppLocalizations.of(context)!.differentExercisesShort, stat.uniqueExercises.toString()),
      _buildCompactStatRow(context, Icons.format_list_numbered, AppLocalizations.of(context)!.exercisesPerSession, stat.avgExercises.toStringAsFixed(1)),
      _buildCompactStatRow(context, Icons.scale, AppLocalizations.of(context)!.avgWeightPerSession, '${stat.avgWeight.toStringAsFixed(0)} ${provider.weightUnitLabel}'),
    ];

    Widget contentWidget;
    if (isEmpty) {
      final emptyText = Text(
        AppLocalizations.of(context)!.noSession,
        style: TextStyle(
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      );
      contentWidget = isSingleColumn 
          ? Center(child: emptyText)
          : Expanded(child: Center(child: emptyText));
    } else {
      contentWidget = isSingleColumn
          ? SizedBox(
              height: 132,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: statRows,
              ),
            )
          : Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: statRows,
              ),
            );
    }

    return Container(
      decoration: BoxDecoration(
        color: isEmpty ? Theme.of(context).colorScheme.surfaceContainerHighest : Theme.of(context).cardColor,
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
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizedMonth,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isEmpty ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6) : null,
                  ),
            ),
            const SizedBox(height: 12),
            contentWidget,
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStatRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
        ),
      ],
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
}

class MonthStat {
  final DateTime month;
  final int workoutCount;
  final int totalTime;
  final double avgTime;
  final int uniqueExercises;
  final double avgExercises;
  final double avgWeight;

  MonthStat({
    required this.month,
    required this.workoutCount,
    required this.totalTime,
    required this.avgTime,
    required this.uniqueExercises,
    required this.avgExercises,
    required this.avgWeight,
  });
}
