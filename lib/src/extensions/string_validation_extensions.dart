import '../field_validator.dart';

/// Convenience getters for validating nullable [String] values in place.
///
/// These read like plain English and are handy for quick checks outside of a
/// form:
///
/// ```dart
/// if (input.isValidEmail) {
///   // ...
/// }
/// ```
///
/// Each getter builds a single-rule [FieldValidator] internally, so empty
/// values are treated as valid (the rule is skipped). Combine with
/// [isNotBlank] when a value is required.
extension NullableStringValidationX on String? {
  /// Whether the value is `null`, empty, or whitespace-only.
  bool get isBlank => this == null || this!.trim().isEmpty;

  /// Whether the value contains at least one non-whitespace character.
  bool get isNotBlank => !isBlank;

  /// Whether the value is a valid email address.
  bool get isValidEmail => FieldValidator().email().isValid(this);

  /// Whether the value is a valid URL.
  bool get isValidUrl => FieldValidator().url().isValid(this);

  /// Whether the value is a valid number (integer or decimal).
  bool get isNumeric => FieldValidator().numeric().isValid(this);

  /// Whether the value is a valid whole number.
  bool get isInteger => FieldValidator().integer().isValid(this);

  /// Whether the value is a strong password using the default rules.
  bool get isStrongPassword => FieldValidator().strongPassword().isValid(this);

  /// Runs [validator] against this value and returns `null` or the error.
  ///
  /// ```dart
  /// final error = input.validateWith(
  ///   FieldValidator().required().email(),
  /// );
  /// ```
  String? validateWith(FieldValidator validator) => validator.validate(this);
}

/// Convenience getters for validating non-null [String] values.
extension StringValidationX on String {
  /// Whether the value contains only letters.
  bool get isAlphabetic => FieldValidator().alphabetic().isValid(this);

  /// Whether the value contains only letters and digits.
  bool get isAlphanumeric => FieldValidator().alphanumeric().isValid(this);

  /// Whether the trimmed value is empty.
  bool get isBlankString => trim().isEmpty;

  /// The value with surrounding whitespace removed, or `null` when blank.
  ///
  /// Useful for normalizing optional form input before it is saved.
  String? get trimmedOrNull => trim().isEmpty ? null : trim();
}
