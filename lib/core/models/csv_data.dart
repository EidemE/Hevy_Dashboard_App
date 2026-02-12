import 'package:intl/intl.dart';
import 'workout.dart';
import 'exercise.dart';
import 'set.dart';
import '../utils/exercise_utils.dart';

class CsvData {
  final List<Workout> workouts;
  final DateTime importedAt;

  CsvData({required this.workouts, required this.importedAt});

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'workouts': workouts
          .map(
            (Workout workout) => {
              'name': workout.name,
              'description': workout.description,
              'dateStart': workout.dateStart.toIso8601String(),
              'dateEnd': workout.dateEnd.toIso8601String(),
              'exercises': workout.exercises
                  .map(
                    (Exercise exercise) => {
                      'name': exercise.name,
                      'comment': exercise.comment,
                      'sets': exercise.sets
                          .map(
                            (Set set) => {
                              'type': set.type.toString().split('.').last,
                              'repetitions': set.repetitions,
                              'weight': set.weight,
                              'rpe': set.rpe,
                            },
                          )
                          .toList(),
                    },
                  )
                  .toList(),
            },
          )
          .toList(),
      'importedAt': importedAt.toIso8601String(),
    };
  }

  // JSON parsing
  factory CsvData.fromJson(Map<String, dynamic> json) {
    return CsvData(
      workouts: (json['workouts'] as List<dynamic>).map((dynamic workoutJson) {
        final Map<String, dynamic> workoutMap =
            workoutJson as Map<String, dynamic>;
        return Workout(
          name: workoutMap['name'] as String,
          description: workoutMap['description'] as String,
          dateStart: DateTime.parse(workoutMap['dateStart'] as String),
          dateEnd: DateTime.parse(workoutMap['dateEnd'] as String),
          exercises: (workoutMap['exercises'] as List<dynamic>).map((
            dynamic exerciseJson,
          ) {
            final Map<String, dynamic> exerciseMap =
                exerciseJson as Map<String, dynamic>;
            return Exercise(
              name: exerciseMap['name'] as String,
              comment: exerciseMap['comment'] as String,
              sets: (exerciseMap['sets'] as List<dynamic>).map((
                dynamic setJson,
              ) {
                final Map<String, dynamic> setMap =
                    setJson as Map<String, dynamic>;
                return Set(
                  type: SetType.values.firstWhere(
                    (SetType type) =>
                        type.toString().split('.').last == setMap['type'],
                  ),
                  repetitions: setMap['repetitions'] as int,
                  weight: setMap['weight'] != null ? (setMap['weight'] as num).toDouble() : null,
                  rpe: setMap['rpe'] != null ? (setMap['rpe'] as num).toDouble() : null,
                );
              }).toList(),
            );
          }).toList(),
        );
      }).toList(),
      importedAt: DateTime.parse(json['importedAt'] as String),
    );
  }

  // Date parsing
  static DateTime _parseFrenchDate(String dateStr) {
    try {
      final DateFormat format = DateFormat("d MMM. yyyy, HH:mm", "fr_FR");
      return format.parse(dateStr);
    } catch (e) {
      try {
        final DateFormat format = DateFormat("d MMM yyyy, HH:mm", "fr_FR");
        return format.parse(dateStr);
      } catch (e2) {
        return DateTime.parse(dateStr);
      }
    }
  }

  // CSV parsing
  factory CsvData.fromCsv(List<String> headers, List<List<dynamic>> dataRows) {
    List<Workout> workouts = [];
    Workout? currentWorkout;

    for (final List<dynamic> row in dataRows) {
      if (row.isNotEmpty) {
        if (row[0].toString() != currentWorkout?.name) {
          if (currentWorkout != null && currentWorkout.exercises.isNotEmpty) {
            workouts.add(currentWorkout);
          }

          currentWorkout = Workout(
            name: row[0].toString(),
            description: row[3].toString(),
            dateStart: _parseFrenchDate(row[1].toString()),
            dateEnd: _parseFrenchDate(row[2].toString()),
            exercises: [],
          );
        }

        final int? repetitions = int.tryParse(row[10].toString());
        if (repetitions == null) {
          continue;
        }

        if (currentWorkout!.exercises.isEmpty || row[4].toString() != currentWorkout.exercises.last.name) {
          currentWorkout.exercises.add(
            Exercise(
              name: row[4].toString(),
              comment: row[6].toString(),
              sets: [],
            ),
          );
        }

        // Assisted weight normalization
        double? weight;
        final weightStr = row[9].toString().trim();
        if (weightStr.isNotEmpty) {
          weight = double.tryParse(weightStr);
          if (weight != null && weight != 0.0 && ExerciseUtils.isAssisted(currentWorkout.exercises.last.name)) {
            weight = -weight;
          }
        }

        final Set currentSet = Set(
          type: SetType.fromCsv(row[8].toString()),
          repetitions: repetitions,
          weight: weight,
          rpe: double.tryParse(row[13].toString()),
        );
        currentWorkout.exercises.last.sets.add(currentSet);
      }
    }

    return CsvData(workouts: workouts, importedAt: DateTime.now());
  }
}
