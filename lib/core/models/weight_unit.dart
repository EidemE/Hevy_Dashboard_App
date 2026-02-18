enum WeightUnit {
  kg,
  lb,
}

extension WeightUnitParsing on WeightUnit {
  static WeightUnit fromCsvWeightHeader(String? header) {
    final normalized = header?.trim().toLowerCase();
    if (normalized == 'weight_lbs') {
      return WeightUnit.lb;
    }
    return WeightUnit.kg;
  }

  static WeightUnit fromStorageValue(String? value) {
    switch (value) {
      case 'kg':
        return WeightUnit.kg;
      case 'lb':
        return WeightUnit.lb;
      default:
        return WeightUnit.kg;
    }
  }
}