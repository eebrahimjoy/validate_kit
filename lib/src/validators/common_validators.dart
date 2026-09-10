import '../field_validator.dart';

/// Ready-made, single-rule validator functions.
///
/// These helpers are ideal when you only need one rule and want a
/// `String? Function(String?)` to hand straight to a `TextFormField`:
///
/// ```dart
/// TextFormField(
///   validator: Validators.email(),
/// );
/// ```
///
/// For anything more than a single rule, prefer the fluent [FieldValidator]:
///
/// ```dart
/// final validator = FieldValidator().required().email();
/// ```
abstract final class Validators {
  /// Returns a validator that requires a non-empty value.
  static String? Function(String?) required([String? message]) =>
      FieldValidator().required(message).asFunction;

  /// Returns a validator that requires a valid email address.
  static String? Function(String?) email([String? message]) =>
      FieldValidator().email(message).asFunction;

  /// Returns a validator that requires a valid URL.
  static String? Function(String?) url([String? message]) =>
      FieldValidator().url(message).asFunction;

  /// Returns a validator that requires a number.
  static String? Function(String?) numeric([String? message]) =>
      FieldValidator().numeric(message).asFunction;

  /// Returns a validator that requires a whole number.
  static String? Function(String?) integer([String? message]) =>
      FieldValidator().integer(message).asFunction;

  /// Returns a validator that requires at least [min] characters.
  static String? Function(String?) minLength(int min, [String? message]) =>
      FieldValidator().minLength(min, message).asFunction;

  /// Returns a validator that requires at most [max] characters.
  static String? Function(String?) maxLength(int max, [String? message]) =>
      FieldValidator().maxLength(max, message).asFunction;

  /// Returns a validator that requires a strong password.
  static String? Function(String?) strongPassword({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialCharacter = true,
    String? message,
  }) => FieldValidator()
      .strongPassword(
        minLength: minLength,
        requireUppercase: requireUppercase,
        requireLowercase: requireLowercase,
        requireNumber: requireNumber,
        requireSpecialCharacter: requireSpecialCharacter,
        message: message,
      )
      .asFunction;

  /// Returns a validator that runs an arbitrary [check].
  static String? Function(String?) custom(
    ValidationFunction check, {
    bool skipOnEmpty = true,
  }) => FieldValidator().custom(check, skipOnEmpty: skipOnEmpty).asFunction;
}

/// Signature accepted by [Validators.custom].
///
/// Mirrors [ValidationChecker] from the core library so callers of this file
/// do not need an extra import.
typedef ValidationFunction = String? Function(String? value);
