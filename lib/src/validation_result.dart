/// The outcome of validating a value against a [FieldValidator].
///
/// A result is considered [isValid] when [errors] is empty. When one or more
/// rules fail, [errors] contains every message that was produced (useful when
/// aggregation is enabled) while [firstError] always exposes the first one.
class ValidationResult {
  /// Creates a result from a list of [errors].
  ///
  /// The list is defensively copied and made unmodifiable so a result is
  /// always safe to share and never mutates unexpectedly.
  ValidationResult(Iterable<String> errors)
    : errors = List<String>.unmodifiable(errors);

  /// Creates a valid result with no errors.
  const ValidationResult.valid() : errors = const <String>[];

  /// The error messages produced by the failed rules, in evaluation order.
  ///
  /// The list is empty when the value is valid.
  final List<String> errors;

  /// Whether the validated value passed every rule.
  bool get isValid => errors.isEmpty;

  /// Whether the validated value failed at least one rule.
  bool get isInvalid => errors.isNotEmpty;

  /// The first error message, or `null` when the value is valid.
  String? get firstError => errors.isEmpty ? null : errors.first;

  /// Alias for [firstError], for readability at call sites.
  String? get error => firstError;

  /// The number of failed rules.
  int get errorCount => errors.length;

  @override
  String toString() =>
      isValid ? 'ValidationResult.valid()' : 'ValidationResult($errors)';

  @override
  bool operator ==(Object other) =>
      other is ValidationResult &&
      other.errors.length == errors.length &&
      _listEquals(other.errors, errors);

  @override
  int get hashCode => Object.hashAll(errors);

  static bool _listEquals(List<String> a, List<String> b) {
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}
