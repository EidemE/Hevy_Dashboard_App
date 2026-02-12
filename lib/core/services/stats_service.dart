import '../models/csv_data.dart';
import '../models/exercise_stats.dart';
import '../models/workout.dart';
import '../models/exercise.dart';
import '../models/set.dart' as exercise_set;
import '../utils/exercise_utils.dart';

class StatsService {
  // Stats aggregation
  List<ExerciseStats> calculateExerciseStats(List<CsvData> csvDataList) {
    if (csvDataList.isEmpty) return [];

    final Map<String, _ExerciseAggregator> exerciseMap = {};

    for (final csvData in csvDataList) {
      for (final Workout workout in csvData.workouts) {
        for (final Exercise exercise in workout.exercises) {
          final aggregator = exerciseMap.putIfAbsent(
            exercise.name,
            () => _ExerciseAggregator(name: exercise.name),
          );

          aggregator.addExercise(exercise, workout.dateStart);
        }
      }
    }

    final List<ExerciseStats> statsList = exerciseMap.values
        .map((aggregator) => aggregator.toStats())
        .toList();

    statsList.sort((a, b) => b.totalWorkouts.compareTo(a.totalWorkouts));

    return statsList;
  }
}

class _ExerciseAggregator {
  final String name;
  double? maxWeight;
  double lastWeight = 0.0;
  int totalSets = 0;
  double totalWeight = 0.0;
  final Set<DateTime> workoutDates = {};
  DateTime? firstDate;
  DateTime? lastDate;
  DateTime? lastWeightDate;

  _ExerciseAggregator({required this.name});

  void addExercise(Exercise exercise, DateTime workoutDate) {
    totalSets += exercise.sets.length;

    final isClassic = ExerciseUtils.isClassic(exercise.name);

    for (final set in exercise.sets) {
      if (set.type == exercise_set.SetType.classic && set.weight != null) {
        if (maxWeight == null || set.weight! > maxWeight!) {
          maxWeight = set.weight!;
        }

        if (lastWeightDate == null || workoutDate.isAfter(lastWeightDate!)) {
          lastWeight = set.weight!;
          lastWeightDate = workoutDate;
        } else if (workoutDate == lastWeightDate) {
          lastWeight = set.weight!;
        }

        if (isClassic && set.weight! > 0) {
          totalWeight += set.weight!;
        }
      }
    }

    workoutDates.add(workoutDate);

    if (firstDate == null || workoutDate.isBefore(firstDate!)) {
      firstDate = workoutDate;
    }
    if (lastDate == null || workoutDate.isAfter(lastDate!)) {
      lastDate = workoutDate;
    }
  }

  ExerciseStats toStats() {
    return ExerciseStats(
      name: name,
      maxWeight: maxWeight ?? 0.0,
      lastWeight: lastWeight,
      lastWeightDate: lastWeightDate,
      totalSets: totalSets,
      totalWorkouts: workoutDates.length,
      firstPerformed: firstDate ?? DateTime.now(),
      lastPerformed: lastDate ?? DateTime.now(),
      totalWeight: totalWeight,
    );
  }
}
