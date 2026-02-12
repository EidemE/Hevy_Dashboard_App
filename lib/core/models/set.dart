class Set {
  final SetType type;
  final int repetitions;
  final double? weight;
  final double? rpe;

  Set({
    required this.type,
    required this.repetitions,
    this.weight,
    this.rpe,
  });
}

enum SetType {
  classic('normal'),
  warmup('warmup'),
  drop('dropset'),
  failure('failure');

  final String csvValue;
  const SetType(this.csvValue);

  static SetType fromCsv(String value) {
    return SetType.values.firstWhere(
      (SetType type) => type.csvValue == value,
      orElse: () => SetType.classic,
    );
  }
}
