class ExerciseStats {
  final String name;
  final double maxWeight;
  final double lastWeight;
  final DateTime? lastWeightDate;
  final int totalSets;
  final int totalWorkouts;
  final DateTime firstPerformed;
  final DateTime lastPerformed;
  final double totalWeight;

  ExerciseStats({
    required this.name,
    required this.maxWeight,
    required this.lastWeight,
    this.lastWeightDate,
    required this.totalSets,
    required this.totalWorkouts,
    required this.firstPerformed,
    required this.lastPerformed,
    required this.totalWeight,
  });

  // Convertir en JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'maxWeight': maxWeight,
      'lastWeight': lastWeight,
      'lastWeightDate': lastWeightDate?.toIso8601String(),
      'totalSets': totalSets,
      'totalWorkouts': totalWorkouts,
      'firstPerformed': firstPerformed.toIso8601String(),
      'lastPerformed': lastPerformed.toIso8601String(),
      'totalWeight': totalWeight,
    };
  }

  // Créer depuis JSON
  factory ExerciseStats.fromJson(Map<String, dynamic> json) {
    return ExerciseStats(
      name: json['name'] as String,
      maxWeight: (json['maxWeight'] as num).toDouble(),
      lastWeight: (json['lastWeight'] as num).toDouble(),
      lastWeightDate: json['lastWeightDate'] != null 
          ? DateTime.parse(json['lastWeightDate'] as String)
          : null,
      totalSets: json['totalSets'] as int,
      totalWorkouts: json['totalWorkouts'] as int,
      firstPerformed: DateTime.parse(json['firstPerformed'] as String),
      lastPerformed: DateTime.parse(json['lastPerformed'] as String),
      totalWeight: json.containsKey('totalWeight') 
          ? (json['totalWeight'] as num).toDouble() 
          : 0.0,
    );
  }
}
