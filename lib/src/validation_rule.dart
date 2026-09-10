/// Signature of the callback used by a single [ValidationRule].
///
/// The callback receives the raw value being validated and returns `null` when
/// the value is valid, or a non-null error message when it is not.
typedef ValidationChecker = String? Function(String? value);

/// A single, immutable validation rule.
///
/// Rules are the small building blocks that [FieldValidator] chains together.
/// Most users will never construct a [ValidationRule] directly; they are
/// created internally by the built-in methods and by
/// [FieldValidator.custom]. They are public so that advanced users can build
/// their own reusable rule factories.
///
/// ```dart
/// final startsWithA = ValidationRule(
///   check: (value) => (value ?? '').startsWith('a') ? null : 'Must start with "a".',
///   skipOnEmpty: false,
/// );
/// ```
class ValidationRule {
  /// Creates a rule from a [check] callback.
  ///
  /// * [check] returns `null` when the value is valid, otherwise the error
  ///   message to surface.
  /// * When [skipOnEmpty] is `true` (the default) the rule is skipped entirely
  ///   for `null`, empty, or whitespace-only values. This is what allows an
  ///   optional field to pass `email`/`minLength` checks without also being
  ///   `required`.
  /// * [description] is an optional, human-readable label used for debugging.
  const ValidationRule({
    required ValidationChecker check,
    this.skipOnEmpty = true,
    this.description,
  }) : _check = check;

  final ValidationChecker _check;

  /// Whether this rule is skipped for empty values.
  ///
  /// See the constructor documentation for details.
  final bool skipOnEmpty;

  /// An optional, human-readable description of the rule.
  ///
  /// It is only used for debugging and never surfaces to end users.
  final String? description;

  /// Runs this rule against [value] and returns `null` or an error message.
  ///
  /// Returns `null` early when [skipOnEmpty] is `true` and [value] is empty.
  String? run(String? value) {
    if (skipOnEmpty && isEmpty(value)) {
      return null;
    }
    return _check(value);
  }

  /// Returns `true` when [value] is `null`, empty, or whitespace-only.
  ///
  /// This is the definition of "empty" used consistently across the package,
  /// so `'   '` is treated exactly like `''`.
  static bool isEmpty(String? value) => value == null || value.trim().isEmpty;

  @override
  String toString() =>
      'ValidationRule(${description ?? 'unnamed'}, skipOnEmpty: $skipOnEmpty)';
}
