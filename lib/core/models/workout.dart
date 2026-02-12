import 'exercise.dart';

class Workout {
  final String name;
  final String description;
  final DateTime dateStart;
  final DateTime dateEnd;
  final List<Exercise> exercises;
  
  Workout({
    required this.name,
    required this.description,
    required this.dateStart,
    required this.dateEnd,
    required this.exercises,
  });

  // Durée totale de l'entrainement en minutes
  int get durationInMinutes {
    return dateEnd.difference(dateStart).inMinutes;
  }

  // Durée formatée (ex: "1h 30min" ou "45min")
  String get formattedDuration {
    final duration = dateEnd.difference(dateStart);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    
    if (hours > 0) {
      return '${hours}h ${minutes}min';
    } else {
      return '${minutes}min';
    }
  }
}

