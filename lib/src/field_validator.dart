import 'utils/regex_patterns.dart';
import 'validation_messages.dart';
import 'validation_result.dart';
import 'validation_rule.dart';

/// A lightweight, fluent and immutable-friendly builder of validation rules.
///
/// [FieldValidator] lets you compose readable validation chains instead of
/// nesting `if` statements or writing a new function for every field:
///
/// ```dart
/// final emailValidator = FieldValidator()
///     .required('Email is required')
///     .email('Enter a valid email address');
///
/// final error = emailValidator.validate(controller.text);
/// ```
///
/// By default the chain **stops at the first failing rule** and returns its
/// message. Call [aggregate] to collect every error instead. All built-in
/// rules skip empty values unless the rule is [required], which makes optional
/// fields behave exactly as you would expect.
///
/// A [FieldValidator] implements [call], so an instance can be passed directly
/// to `TextFormField.validator` without a lambda:
///
/// ```dart
/// TextFormField(
///   validator: FieldValidator().required().email().call,
/// );
/// ```
///
/// The class is also exported under the alias `MultiValidator` for callers who
/// prefer the "multi rule" naming.
class FieldValidator {
  /// Creates an empty validator.
  ///
  /// * When [aggregate] is `true`, [validate] returns every error joined by
  ///   [separator] instead of only the first one.
  /// * [separator] is used to join errors when aggregation is enabled.
  FieldValidator({bool aggregate = false, String separator = '\n'})
    : _aggregate = aggregate,
      _separator = separator;

  final List<ValidationRule> _rules = <ValidationRule>[];
  bool _aggregate;
  String _separator;

  /// The rules registered on this validator, in evaluation order.
  ///
  /// The returned list is unmodifiable. Use [addRule] to append a rule.
  List<ValidationRule> get rules => List<ValidationRule>.unmodifiable(_rules);

  /// The number of rules currently registered.
  int get ruleCount => _rules.length;

  /// Whether this validator is empty (has no rules).
  bool get isEmpty => _rules.isEmpty;

  /// Whether this validator has at least one rule.
  bool get isNotEmpty => _rules.isNotEmpty;

  /// Whether [validate] joins every error instead of returning the first.
  bool get isAggregating => _aggregate;

  /// The separator used to join errors when aggregation is enabled.
  String get separator => _separator;

  /// A tear-off of [validate], typed for use as a form field validator.
  ///
  /// Useful for APIs that expect a `String? Function(String?)`:
  ///
  /// ```dart
  /// TextFormField(validator: FieldValidator().required().asFunction);
  /// ```
  String? Function(String?) get asFunction => validate;

  /// Enables or disables error aggregation.
  ///
  /// When [enabled] is `true`, [validate] returns every failing message joined
  /// by [separator]; when `false` it returns only the first failure.
  ///
  /// ```dart
  /// final validator = FieldValidator()
  ///     .required()
  ///     .email()
  ///     .aggregate(separator: ' • ');
  /// ```
  FieldValidator aggregate({bool enabled = true, String separator = '\n'}) {
    _aggregate = enabled;
    _separator = separator;
    return this;
  }

  /// Removes every rule, returning the same (now empty) validator.
  FieldValidator clear() {
    _rules.clear();
    return this;
  }

  /// Appends a custom [rule], returning this validator for chaining.
  ///
  /// This is the low-level extension point used by all built-in rules and by
  /// advanced callers who want to build reusable rule factories.
  FieldValidator addRule(ValidationRule rule) {
    _rules.add(rule);
    return this;
  }

  // ---------------------------------------------------------------------------
  // Presence
  // ---------------------------------------------------------------------------

  /// Requires a non-empty value.
  ///
  /// Whitespace-only values are treated as empty. Unlike most rules, this one
  /// does **not** skip empty values, so it always reports an error for them.
  ///
  /// ```dart
  /// FieldValidator().required('Please enter your name');
  /// ```
  FieldValidator required([String? message]) {
    final resolved = message ?? ValidationMessages.required;
    return addRule(
      ValidationRule(
        description: 'required',
        skipOnEmpty: false,
        check: (String? value) =>
            ValidationRule.isEmpty(value) ? resolved : null,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Format
  // ---------------------------------------------------------------------------

  /// Requires a valid email address.
  ///
  /// Skipped for empty values, so combine it with [required] to make the
  /// field mandatory.
  ///
  /// ```dart
  /// FieldValidator().email('Enter a valid email address');
  /// ```
  FieldValidator email([String? message]) {
    final resolved = message ?? ValidationMessages.email;
    return addRule(
      ValidationRule(
        description: 'email',
        check: (String? value) =>
            RegexPatterns.email.hasMatch((value ?? '').trim())
            ? null
            : resolved,
      ),
    );
  }

  /// Requires a valid `http`/`https` URL. The scheme is optional.
  ///
  /// Skipped for empty values.
  FieldValidator url([String? message]) {
    final resolved = message ?? ValidationMessages.url;
    return addRule(
      ValidationRule(
        description: 'url',
        check: (String? value) =>
            RegexPatterns.url.hasMatch((value ?? '').trim()) ? null : resolved,
      ),
    );
  }

  /// Requires a number (integer or decimal).
  ///
  /// Skipped for empty values. Use [numericRange] to also constrain the value.
  FieldValidator numeric([String? message]) {
    final resolved = message ?? ValidationMessages.numeric;
    return addRule(
      ValidationRule(
        description: 'numeric',
        check: (String? value) =>
            RegexPatterns.numeric.hasMatch((value ?? '').trim())
            ? null
            : resolved,
      ),
    );
  }

  /// Requires a whole number that falls within the inclusive range
  /// `[min, max]`.
  ///
  /// Either bound may be `null` to leave that side open-ended. Empty values are
  /// skipped.
  ///
  /// ```dart
  /// FieldValidator().numericRange(1, 100, message: 'Rate 1-100');
  /// ```
  FieldValidator numericRange(num? min, num? max, {String? message}) {
    final resolved = message ?? ValidationMessages.numericRange(min, max);
    return addRule(
      ValidationRule(
        description: 'numericRange($min, $max)',
        check: (String? value) {
          final parsed = num.tryParse((value ?? '').trim());
          if (parsed == null) {
            return resolved;
          }
          if (min != null && parsed < min) {
            return resolved;
          }
          if (max != null && parsed > max) {
            return resolved;
          }
          return null;
        },
      ),
    );
  }

  /// Requires a whole number (no decimal point).
  ///
  /// Skipped for empty values.
  FieldValidator integer([String? message]) {
    final resolved = message ?? ValidationMessages.integer;
    return addRule(
      ValidationRule(
        description: 'integer',
        check: (String? value) =>
            RegexPatterns.integer.hasMatch((value ?? '').trim())
            ? null
            : resolved,
      ),
    );
  }

  /// Requires only letters (`a-z`, `A-Z`).
  ///
  /// Skipped for empty values.
  FieldValidator alphabetic([String? message]) {
    final resolved = message ?? ValidationMessages.alphabetic;
    return addRule(
      ValidationRule(
        description: 'alphabetic',
        check: (String? value) =>
            RegexPatterns.alphabetic.hasMatch((value ?? '').trim())
            ? null
            : resolved,
      ),
    );
  }

  /// Requires only letters and digits (`a-z`, `A-Z`, `0-9`).
  ///
  /// Skipped for empty values.
  FieldValidator alphanumeric([String? message]) {
    final resolved = message ?? ValidationMessages.alphanumeric;
    return addRule(
      ValidationRule(
        description: 'alphanumeric',
        check: (String? value) =>
            RegexPatterns.alphanumeric.hasMatch((value ?? '').trim())
            ? null
            : resolved,
      ),
    );
  }

  /// Requires the value to match [pattern].
  ///
  /// Skipped for empty values.
  ///
  /// ```dart
  /// FieldValidator().pattern(RegExp(r'^\d{5}$'), 'Enter a 5-digit ZIP');
  /// ```
  FieldValidator pattern(RegExp pattern, [String? message]) {
    final resolved = message ?? ValidationMessages.pattern;
    return addRule(
      ValidationRule(
        description: 'pattern(${pattern.pattern})',
        check: (String? value) =>
            pattern.hasMatch((value ?? '').trim()) ? null : resolved,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Length
  // ---------------------------------------------------------------------------

  /// Requires at least [min] characters (after trimming).
  ///
  /// Skipped for empty values.
  FieldValidator minLength(int min, [String? message]) {
    final resolved = message ?? ValidationMessages.minLength(min);
    return addRule(
      ValidationRule(
        description: 'minLength($min)',
        check: (String? value) =>
            (value ?? '').trim().length >= min ? null : resolved,
      ),
    );
  }

  /// Requires at most [max] characters (after trimming).
  ///
  /// Skipped for empty values.
  FieldValidator maxLength(int max, [String? message]) {
    final resolved = message ?? ValidationMessages.maxLength(max);
    return addRule(
      ValidationRule(
        description: 'maxLength($max)',
        check: (String? value) =>
            (value ?? '').trim().length <= max ? null : resolved,
      ),
    );
  }

  /// Requires a trimmed length between [min] and [max] (inclusive).
  ///
  /// Skipped for empty values.
  FieldValidator lengthBetween(int min, int max, [String? message]) {
    final resolved = message ?? ValidationMessages.lengthBetween(min, max);
    return addRule(
      ValidationRule(
        description: 'lengthBetween($min, $max)',
        check: (String? value) {
          final length = (value ?? '').trim().length;
          return length >= min && length <= max ? null : resolved;
        },
      ),
    );
  }

  /// Requires exactly [length] characters (after trimming).
  ///
  /// Skipped for empty values.
  FieldValidator exactLength(int length, [String? message]) {
    final resolved = message ?? ValidationMessages.exactLength(length);
    return addRule(
      ValidationRule(
        description: 'exactLength($length)',
        check: (String? value) =>
            (value ?? '').trim().length == length ? null : resolved,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Passwords and matching
  // ---------------------------------------------------------------------------

  /// Requires a strong password.
  ///
  /// By default the value must contain at least [minLength] characters, an
  /// uppercase letter, a lowercase letter, a number, and a special character.
  /// Individual requirements can be disabled with the `require*` flags.
  ///
  /// Skipped for empty values.
  ///
  /// ```dart
  /// FieldValidator().strongPassword(
  ///   minLength: 10,
  ///   requireSpecialCharacter: false,
  /// );
  /// ```
  FieldValidator strongPassword({
    int minLength = 8,
    bool requireUppercase = true,
    bool requireLowercase = true,
    bool requireNumber = true,
    bool requireSpecialCharacter = true,
    String? message,
  }) {
    final resolved =
        message ??
        ValidationMessages.strongPassword(
          minLength: minLength,
          requireUppercase: requireUppercase,
          requireLowercase: requireLowercase,
          requireNumber: requireNumber,
          requireSpecialCharacter: requireSpecialCharacter,
        );
    return addRule(
      ValidationRule(
        description: 'strongPassword',
        check: (String? value) {
          final text = value ?? '';
          if (text.length < minLength) {
            return resolved;
          }
          if (requireUppercase && !RegexPatterns.hasUppercase.hasMatch(text)) {
            return resolved;
          }
          if (requireLowercase && !RegexPatterns.hasLowercase.hasMatch(text)) {
            return resolved;
          }
          if (requireNumber && !RegexPatterns.hasDigit.hasMatch(text)) {
            return resolved;
          }
          if (requireSpecialCharacter &&
              !RegexPatterns.hasSpecialCharacter.hasMatch(text)) {
            return resolved;
          }
          return null;
        },
      ),
    );
  }

  /// Requires this value to match the value produced by [other].
  ///
  /// The callback is evaluated lazily at validation time, so it can safely read
  /// the *current* contents of another controller or field:
  ///
  /// ```dart
  /// FieldValidator()
  ///     .required('Confirm your password')
  ///     .matches(() => passwordController.text, 'Passwords do not match');
  /// ```
  ///
  /// Skipped for empty values.
  FieldValidator matches(String? Function() other, [String? message]) {
    final resolved = message ?? ValidationMessages.mismatch;
    return addRule(
      ValidationRule(
        description: 'matches',
        check: (String? value) => value == other() ? null : resolved,
      ),
    );
  }

  /// Requires this value to equal [other].
  ///
  /// This is a convenience wrapper around [matches] for when the expected value
  /// is already in hand.
  ///
  /// Skipped for empty values.
  FieldValidator matchesValue(String? other, [String? message]) =>
      matches(() => other, message);

  // ---------------------------------------------------------------------------
  // Membership and custom logic
  // ---------------------------------------------------------------------------

  /// Requires the value to contain [substring].
  ///
  /// Skipped for empty values.
  FieldValidator contains(String substring, [String? message]) {
    final resolved = message ?? ValidationMessages.contains(substring);
    return addRule(
      ValidationRule(
        description: 'contains($substring)',
        check: (String? value) =>
            (value ?? '').contains(substring) ? null : resolved,
      ),
    );
  }

  /// Requires the value to equal [expected].
  ///
  /// Set [caseSensitive] to `false` for a case-insensitive comparison. Skipped
  /// for empty values.
  FieldValidator equals(
    String expected, {
    bool caseSensitive = true,
    String? message,
  }) {
    final resolved = message ?? ValidationMessages.equals(expected);
    return addRule(
      ValidationRule(
        description: 'equals($expected)',
        check: (String? value) {
          final text = value ?? '';
          final matches = caseSensitive
              ? text == expected
              : text.toLowerCase() == expected.toLowerCase();
          return matches ? null : resolved;
        },
      ),
    );
  }

  /// Requires the value to be one of [values].
  ///
  /// Set [caseSensitive] to `false` for case-insensitive membership. Skipped
  /// for empty values.
  FieldValidator oneOf(
    Iterable<String> values, {
    bool caseSensitive = true,
    String? message,
  }) {
    final options = values.toList(growable: false);
    final resolved = message ?? ValidationMessages.oneOf(options);
    return addRule(
      ValidationRule(
        description: 'oneOf(${options.join(', ')})',
        check: (String? value) {
          final text = value ?? '';
          final found = caseSensitive
              ? options.contains(text)
              : options.any(
                  (String option) => option.toLowerCase() == text.toLowerCase(),
                );
          return found ? null : resolved;
        },
      ),
    );
  }

  /// Adds an arbitrary custom [check] to the chain.
  ///
  /// The callback returns `null` when the value is valid, or the error message
  /// to display. By default custom checks are skipped for empty values; pass
  /// `skipOnEmpty: false` to always run them.
  ///
  /// ```dart
  /// FieldValidator().custom(
  ///   (value) => value!.contains('admin') ? 'Admin emails are not allowed' : null,
  /// );
  /// ```
  FieldValidator custom(
    ValidationChecker check, {
    bool skipOnEmpty = true,
    String? description,
  }) {
    return addRule(
      ValidationRule(
        check: check,
        skipOnEmpty: skipOnEmpty,
        description: description ?? 'custom',
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Evaluation
  // ---------------------------------------------------------------------------

  /// Runs every rule and returns all error messages, in evaluation order.
  ///
  /// Unlike [validate] this never short-circuits and ignores the aggregation
  /// setting, which makes it ideal for showing a checklist of everything that
  /// is wrong at once.
  List<String> validateAll(String? value) {
    final errors = <String>[];
    for (final rule in _rules) {
      final error = rule.run(value);
      if (error != null) {
        errors.add(error);
      }
    }
    return errors;
  }

  /// Runs every rule and returns a rich [ValidationResult].
  ValidationResult validateResult(String? value) =>
      ValidationResult(validateAll(value));

  /// Validates [value] and returns `null` when valid.
  ///
  /// By default only the **first** failing message is returned. When
  /// aggregation is enabled via [aggregate] (or the constructor), every error
  /// is returned joined by [separator].
  ///
  /// ```dart
  /// final error = FieldValidator()
  ///     .required('Field cannot be blank')
  ///     .email('Enter a valid email address')
  ///     .validate(controller.text);
  /// ```
  String? validate(String? value) {
    final errors = validateAll(value);
    if (errors.isEmpty) {
      return null;
    }
    return _aggregate ? errors.join(_separator) : errors.first;
  }

  /// Returns `true` when [value] passes every rule.
  bool isValid(String? value) => validateAll(value).isEmpty;

  /// Returns `true` when [value] fails at least one rule.
  bool isInvalid(String? value) => !isValid(value);

  /// Allows a [FieldValidator] to be used directly as a validator callback.
  ///
  /// This is an alias for [validate] and makes instances callable, so they can
  /// be passed to `TextFormField.validator` without a wrapper.
  String? call(String? value) => validate(value);

  /// Returns a deep copy of this validator with the same rules and settings.
  ///
  /// The rules themselves are immutable, so the copy is independent and safe to
  /// reconfigure without affecting the original.
  FieldValidator clone() {
    final copy = FieldValidator(aggregate: _aggregate, separator: _separator);
    copy._rules.addAll(_rules);
    return copy;
  }

  @override
  String toString() =>
      'FieldValidator(rules: ${_rules.length}, aggregate: $_aggregate)';
}

/// A descriptive alias for [FieldValidator].
///
/// The name highlights the most common use case: chaining **multiple** rules
/// into a single validator. Both names refer to the exact same type, so they
/// can be used interchangeably.
typedef MultiValidator = FieldValidator;
