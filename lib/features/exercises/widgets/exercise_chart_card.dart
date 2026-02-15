import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/models/exercise_stats.dart';
import '../../../core/models/csv_data.dart';
import '../../../core/models/set.dart' as exercise_set;
import '../../../widgets/exercise_stats_header.dart';
import '../../../core/utils/exercise_utils.dart';

class ExerciseChartCard extends StatefulWidget {
  final ExerciseStats stats;
  final List<CsvData> csvData;
  final VoidCallback? onTap;

  const ExerciseChartCard({
    super.key,
    required this.stats,
    required this.csvData,
    this.onTap,
  });

  @override
  State<ExerciseChartCard> createState() => _ExerciseChartCardState();
}

class _ExerciseChartCardState extends State<ExerciseChartCard> {
  String? _selectedYear;
  bool _initialized = false;
  bool _isMobile = false;

  // Exercise type flags
  bool get _isDualChart => ExerciseUtils.isDualChart(widget.stats.name);
  bool get _isBodyweight => widget.stats.maxWeight == 0 && !_isDualChart;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    if (!_initialized) {
      final screenWidth = MediaQuery.of(context).size.width;
      _isMobile = screenWidth < 600;
      
      if (_isMobile) {
        _selectedYear = DateTime.now().year.toString();
      } else {
        _selectedYear = 'all';
      }
      
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allHistory = _buildExerciseHistory();
    final availableYears = _getAvailableYears(allHistory);
    
    // Keep a valid year selection
    if (_selectedYear != null && _selectedYear != 'all' && !availableYears.contains(_selectedYear)) {
      _selectedYear = 'all';
    }
    
    final filteredHistory = _filterByYear(allHistory, _selectedYear ?? 'all');
    
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
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              ExerciseStatsHeader(stats: widget.stats),
              
              // Chart
              if (filteredHistory.length > 1) ...[
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 10),
                
                // Title + year filter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _getChartTitle(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (availableYears.length > 1) ...[
                      const SizedBox(width: 8),
                      DropdownButton<String>(
                        value: _selectedYear ?? 'all',
                        isDense: true,
                        underline: Container(),
                        items: [
                          DropdownMenuItem(
                            value: 'all',
                            child: Text(
                              AppLocalizations.of(context)!.all,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                          ...availableYears.map((year) => DropdownMenuItem(
                                value: year,
                                child: Text(year, style: const TextStyle(fontSize: 12)),
                              )),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedYear = value;
                            });
                          }
                        },
                      ),
                    ] else if (availableYears.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text(
                        availableYears.first,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Chart
                SizedBox(
                  height: 200,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: _buildChart(context, filteredHistory),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<_ExerciseDataPoint> _buildExerciseHistory() {
    final List<_ExerciseDataPoint> dataPoints = [];
    
    // Data extraction
    for (final csv in widget.csvData) {
      for (final workout in csv.workouts) {
        for (final exercise in workout.exercises) {
          if (exercise.name == widget.stats.name) {
            double maxWeight = 0.0;
            int maxReps = 0;
            
            if (_isDualChart) {
              double? rawMaxWeight;
              
              for (final set in exercise.sets) {
                if (set.type == exercise_set.SetType.classic && set.weight != null) {
                  if (rawMaxWeight == null || set.weight! > rawMaxWeight) {
                    rawMaxWeight = set.weight!;
                  }
                }
              }
              
              if (rawMaxWeight != null) {
                for (final set in exercise.sets) {
                  if (set.type == exercise_set.SetType.classic && 
                      set.weight != null && 
                      set.weight == rawMaxWeight) {
                    if (set.repetitions > maxReps) {
                      maxReps = set.repetitions;
                    }
                  }
                }
                maxWeight = rawMaxWeight;
              }
            } else {
              for (final set in exercise.sets) {
                if (set.type == exercise_set.SetType.classic) {
                  if (set.weight != null && (maxWeight == 0.0 || set.weight! > maxWeight)) {
                    maxWeight = set.weight!;
                  }
                  if (set.repetitions > maxReps) {
                    maxReps = set.repetitions;
                  }
                }
              }
            }
            
            if (maxWeight != 0.0 || maxReps > 0) {
              dataPoints.add(_ExerciseDataPoint(
                date: workout.dateStart,
                maxWeight: maxWeight,
                maxReps: maxReps,
              ));
            }
          }
        }
      }
    }
    
    dataPoints.sort((a, b) => a.date.compareTo(b.date));
    
    return dataPoints;
  }

  String _getChartTitle() {
    if (_isBodyweight) {
      return AppLocalizations.of(context)!.repsProgressionTitle;
    }
    if (_isDualChart) {
      return AppLocalizations.of(context)!.weightRepsProgressionTitle;
    }
    return AppLocalizations.of(context)!.maxWeightProgressionTitle;
  }

  List<String> _getAvailableYears(List<_ExerciseDataPoint> history) {
    if (history.isEmpty) return [];
    
    final years = <String>{};
    for (final point in history) {
      years.add(point.date.year.toString());
    }
    
    return years.toList()..sort((a, b) => b.compareTo(a));
  }

  List<_ExerciseDataPoint> _filterByYear(List<_ExerciseDataPoint> history, String year) {
    if (year == 'all') {
      if (history.length > 30) {
        return history.sublist(history.length - 30);
      }
      return history;
    }
    
    return history.where((point) => point.date.year.toString() == year).toList();
  }

  Widget _buildChart(BuildContext context, List<_ExerciseDataPoint> history) {
    if (history.isEmpty) return const SizedBox();
    
    final firstDate = history.first.date;
    final lastDate = history.last.date;
    final totalDays = lastDate.difference(firstDate).inDays.toDouble();
    
    // Chart selection
    if (_isDualChart) {
      return _buildDualChart(context, history, firstDate, totalDays);
    } else if (_isBodyweight) {
      return _buildRepsOnlyChart(context, history, firstDate, totalDays);
    } else {
      return _buildWeightOnlyChart(context, history, firstDate, totalDays);
    }
  }

  // Helpers
  
  _ExerciseDataPoint? _findClosestPoint(List<_ExerciseDataPoint> history, DateTime firstDate, double daysSinceFirst) {
    _ExerciseDataPoint? closestPoint;
    double minDiff = double.infinity;
    
    for (final point in history) {
      final pointDays = point.date.difference(firstDate).inDays.toDouble();
      final diff = (pointDays - daysSinceFirst).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closestPoint = point;
      }
    }
    
    return closestPoint;
  }

  FlGridData _buildGridData(BuildContext context) {
    return FlGridData(
      show: true,
      drawVerticalLine: false,
      getDrawingHorizontalLine: (value) {
        return FlLine(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
          strokeWidth: 1,
        );
      },
    );
  }

  AxisTitles _buildBottomTitles(BuildContext context, DateTime firstDate, double totalDays) {
    return AxisTitles(
      sideTitles: SideTitles(
        showTitles: true,
        reservedSize: 30,
        interval: totalDays > 180 ? 60 : (totalDays > 90 ? 30 : (totalDays > 30 ? 14 : 7)),
        getTitlesWidget: (value, meta) {
          final date = firstDate.add(Duration(days: value.toInt()));
          return Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              DateFormat('MM/yy', AppLocalizations.of(context)!.localeName).format(date),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                  ),
            ),
          );
        },
      ),
    );
  }

  FlBorderData _buildBorderData(BuildContext context, {bool showRight = false}) {
    return FlBorderData(
      show: true,
      border: Border(
        bottom: BorderSide(color: Theme.of(context).dividerColor),
        left: BorderSide(color: Theme.of(context).dividerColor),
        right: showRight ? BorderSide(color: Theme.of(context).dividerColor) : BorderSide.none,
      ),
    );
  }

  LineChartBarData _buildLineChartBarData({
    required List<FlSpot> spots,
    required Color color,
    bool showBelowBar = true,
  }) {
    return LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) {
          return FlDotCirclePainter(
            radius: 4,
            color: color,
            strokeWidth: 2,
            strokeColor: Colors.white,
          );
        },
      ),
      belowBarData: BarAreaData(
        show: showBelowBar,
        color: showBelowBar ? color.withValues(alpha: 0.1) : Colors.transparent,
      ),
    );
  }
  
  Widget _buildRepsOnlyChart(BuildContext context, List<_ExerciseDataPoint> history, DateTime firstDate, double totalDays) {
    final maxReps = history.map((e) => e.maxReps).reduce((a, b) => a > b ? a : b);
    final yMax = (maxReps * 1.1).toDouble();
    
    final repsSpots = <FlSpot>[];
    for (final point in history) {
      final daysSinceFirst = point.date.difference(firstDate).inDays.toDouble();
      repsSpots.add(FlSpot(daysSinceFirst, point.maxReps.toDouble()));
    }
    
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipMargin: _isMobile ? 40 : 0,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final closestPoint = _findClosestPoint(history, firstDate, spot.x);
                if (closestPoint != null) {
                  final date = DateFormat(
                    'dd MMM yyyy',
                    AppLocalizations.of(context)!.localeName,
                  ).format(closestPoint.date);
                  return LineTooltipItem(
                    '$date\n${closestPoint.maxReps} ${AppLocalizations.of(context)!.reps}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        gridData: _buildGridData(context),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: _buildBottomTitles(context, firstDate, totalDays),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)} ${AppLocalizations.of(context)!.reps}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: _buildBorderData(context),
        minX: 0,
        maxX: totalDays,
        minY: 0,
        maxY: yMax,
        lineBarsData: [_buildLineChartBarData(spots: repsSpots, color: Colors.green)],
      ),
    );
  }
  
  Widget _buildDualChart(BuildContext context, List<_ExerciseDataPoint> history, DateTime firstDate, double totalDays) {
    final maxWeight = history.map((e) => e.maxWeight).reduce((a, b) => a > b ? a : b);
    final minWeight = history.map((e) => e.maxWeight).reduce((a, b) => a < b ? a : b);
    final maxReps = history.map((e) => e.maxReps).reduce((a, b) => a > b ? a : b);
    
    final weightSpots = <FlSpot>[];
    final repsSpots = <FlSpot>[];
    
    for (final point in history) {
      final daysSinceFirst = point.date.difference(firstDate).inDays.toDouble();
      weightSpots.add(FlSpot(daysSinceFirst, point.maxWeight));
      repsSpots.add(FlSpot(daysSinceFirst, point.maxReps.toDouble()));
    }
    
    final weightRange = (maxWeight - minWeight).abs();
    final yMinWeight = minWeight - (weightRange * 0.1);
    final yMaxWeight = maxWeight + (weightRange * 0.1);
    final yMaxReps = (maxReps * 1.1).toDouble();
    
    final normalizedRepsSpots = repsSpots.map((spot) {
      final normalizedY = ((spot.y / yMaxReps) * (yMaxWeight - yMinWeight)) + yMinWeight;
      return FlSpot(spot.x, normalizedY);
    }).toList();
    
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipMargin: _isMobile ? 40 : 0,
            getTooltipItems: (touchedSpots) {
              if (touchedSpots.isEmpty) return [];
              
              final closestPoint = _findClosestPoint(history, firstDate, touchedSpots.first.x);
              if (closestPoint != null) {
                final date = DateFormat(
                  'dd MMM yyyy',
                  AppLocalizations.of(context)!.localeName,
                ).format(closestPoint.date);
                return touchedSpots.map((spot) {
                  if (spot.barIndex == 0) {
                    return LineTooltipItem(
                      '$date\n',
                      const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      children: [
                        TextSpan(
                          text: '${closestPoint.maxWeight.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg}\n',
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        TextSpan(
                          text: '${closestPoint.maxReps} ${AppLocalizations.of(context)!.reps}',
                          style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    );
                  }
                  return null;
                }).toList();
              }
              return [];
            },
          ),
        ),
        gridData: _buildGridData(context),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                final realReps = ((value - yMinWeight) / (yMaxWeight - yMinWeight)) * yMaxReps;
                return Text(
                  '${realReps.toStringAsFixed(0)} ${AppLocalizations.of(context)!.reps}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.green),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: _buildBottomTitles(context, firstDate, totalDays),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kg}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.blue),
                );
              },
            ),
          ),
        ),
        borderData: _buildBorderData(context, showRight: true),
        minX: 0,
        maxX: totalDays,
        minY: yMinWeight,
        maxY: yMaxWeight,
        lineBarsData: [
          _buildLineChartBarData(spots: weightSpots, color: Colors.blue),
          _buildLineChartBarData(spots: normalizedRepsSpots, color: Colors.green),
        ],
      ),
    );
  }
  
  Widget _buildWeightOnlyChart(BuildContext context, List<_ExerciseDataPoint> history, DateTime firstDate, double totalDays) {
    final maxWeight = history.map((e) => e.maxWeight).reduce((a, b) => a > b ? a : b);
    final minWeight = history.map((e) => e.maxWeight).reduce((a, b) => a < b ? a : b);
    
    final weightSpots = <FlSpot>[];
    for (final point in history) {
      final daysSinceFirst = point.date.difference(firstDate).inDays.toDouble();
      weightSpots.add(FlSpot(daysSinceFirst, point.maxWeight));
    }
    
    final weightRange = (maxWeight - minWeight).abs();
    final yMin = minWeight - (weightRange * 0.1);
    final yMax = maxWeight + (weightRange * 0.1);
    
    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          enabled: true,
          touchTooltipData: LineTouchTooltipData(
            tooltipMargin: _isMobile ? 40 : 0,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final closestPoint = _findClosestPoint(history, firstDate, spot.x);
                if (closestPoint != null) {
                  final date = DateFormat(
                    'dd MMM yyyy',
                    AppLocalizations.of(context)!.localeName,
                  ).format(closestPoint.date);
                  return LineTooltipItem(
                    '$date\n${closestPoint.maxWeight.toStringAsFixed(1)} ${AppLocalizations.of(context)!.kg}',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        gridData: _buildGridData(context),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: _buildBottomTitles(context, firstDate, totalDays),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toStringAsFixed(0)} ${AppLocalizations.of(context)!.kg}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: _buildBorderData(context),
        minX: 0,
        maxX: totalDays,
        minY: yMin,
        maxY: yMax,
        lineBarsData: [_buildLineChartBarData(spots: weightSpots, color: Colors.blue)],
      ),
    );
  }
}

class _ExerciseDataPoint {
  final DateTime date;
  final double maxWeight;
  final int maxReps;

  _ExerciseDataPoint({
    required this.date,
    required this.maxWeight,
    required this.maxReps,
  });
}
