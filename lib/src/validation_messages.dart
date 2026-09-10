/// Default, localization-ready error messages used by the built-in rules.
///
/// Every message is exposed as a mutable static field (or a small factory
/// function). Override the relevant members once at application start-up to
/// localize the whole package, instead of passing a custom message to every
/// single rule:
///
/// ```dart
/// void main() {
///   ValidationMessages.required = 'Este campo es obligatorio.';
///   ValidationMessages.email = 'Introduce un correo válido.';
///   runApp(const MyApp());
/// }
/// ```
///
/// Rules always accept an explicit per-call `message` argument, which takes
/// precedence over these defaults. That makes it easy to mix global defaults
/// with one-off overrides.
abstract final class ValidationMessages {
  /// Message used by [FieldValidator.required] when no override is supplied.
  static String required = 'This field is required.';

  /// Message used by [FieldValidator.email] when no override is supplied.
  static String email = 'Enter a valid email address.';

  /// Message used by [FieldValidator.url] when no override is supplied.
  static String url = 'Enter a valid URL.';

  /// Message used by [FieldValidator.numeric] when no override is supplied.
  static String numeric = 'Enter a valid number.';

  /// Message used by [FieldValidator.integer] when no override is supplied.
  static String integer = 'Enter a whole number.';

  /// Message used by [FieldValidator.matches] and [FieldValidator.matchesValue]
  /// when no override is supplied.
  static String mismatch = 'Values do not match.';

  /// Message used by [FieldValidator.pattern] when no override is supplied.
  static String pattern = 'The value has an invalid format.';

  /// Message used by [FieldValidator.alphabetic] when no override is supplied.
  static String alphabetic = 'Only letters are allowed.';

  /// Message used by [FieldValidator.alphanumeric] when no override is
  /// supplied.
  static String alphanumeric = 'Only letters and numbers are allowed.';

  /// Builds the message for a minimum-length rule.
  static String minLength(int min) => 'Must be at least $min characters.';

  /// Builds the message for a maximum-length rule.
  static String maxLength(int max) => 'Must be at most $max characters.';

  /// Builds the message for an inclusive length-range rule.
  static String lengthBetween(int min, int max) =>
      'Must be between $min and $max characters.';

  /// Builds the message for an exact-length rule.
  static String exactLength(int length) =>
      'Must be exactly $length characters.';

  /// Builds the message for a numeric range rule.
  ///
  /// Handles open-ended ranges (`min == null` or `max == null`) gracefully.
  static String numericRange(num? min, num? max) {
    if (min != null && max != null) {
      return 'Must be between $min and $max.';
    }
    if (min != null) {
      return 'Must be greater than or equal to $min.';
    }
    if (max != null) {
      return 'Must be less than or equal to $max.';
    }
    return numeric;
  }

  /// Builds the message for a "must contain" rule.
  static String contains(String substring) => "Must contain '$substring'.";

  /// Builds the message for a "must equal" rule.
  static String equals(String value) => 'Must be equal to $value.';

  /// Builds the message for a "one of" rule.
  static String oneOf(Iterable<String> values) =>
      'Must be one of: ${values.join(', ')}.';

  /// Builds a descriptive message for a strong-password rule.
  ///
  /// The message lists only the requirements that are actually enabled, so it
  /// stays accurate when callers relax the defaults.
  static String strongPassword({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialCharacter = true,
  }) {
    final requirements = <String>['at least $minLength characters'];
    if (requireUppercase) {
      requirements.add('an uppercase letter');
    }
    if (requireLowercase) {
      requirements.add('a lowercase letter');
    }
    if (requireNumber) {
      requirements.add('a number');
    }
    if (requireSpecialCharacter) {
      requirements.add('a special character');
    }
    if (requirements.length == 1) {
      return 'Must be at least $minLength characters long.';
    }
    final last = requirements.removeLast();
    return 'Must contain ${requirements.join(', ')} and $last.';
  }
}
