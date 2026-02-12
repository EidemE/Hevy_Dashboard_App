/// Exercise type helpers.
class ExerciseUtils {
  static const List<String> _weightedTokens = ['(Lesté', '(Weighted)'];
  static const List<String> _assistedTokens = ['(Assisté', '(Assisted)'];

  static bool _containsAny(String exerciseName, List<String> tokens) {
    final lowerName = exerciseName.toLowerCase();
    return tokens.any(lowerName.contains);
  }

  static bool isWeighted(String exerciseName) {
    return _containsAny(exerciseName, _weightedTokens);
  }

  static bool isAssisted(String exerciseName) {
    return _containsAny(exerciseName, _assistedTokens);
  }

  static bool isDualChart(String exerciseName) {
    return isWeighted(exerciseName) || isAssisted(exerciseName);
  }

  static bool isClassic(String exerciseName) {
    return !isDualChart(exerciseName);
  }
}
