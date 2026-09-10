/// Reusable, well-tested regular expressions used by the built-in validators.
///
/// Keeping every pattern in one place makes the rules easy to audit and keeps
/// the individual validator methods small and readable. All patterns are
/// compiled once at first use and are safe to share across isolates.
abstract final class RegexPatterns {
  /// Matches a pragmatic, RFC-5322-inspired email address.
  ///
  /// This intentionally accepts the vast majority of real-world addresses
  /// while rejecting obvious mistakes such as missing `@` or top-level domain
  /// segments. It is not a full RFC parser by design, because those are
  /// famously imprecise and rarely useful in a form.
  static final RegExp email = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@"
    r'[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?'
    r'(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)+$',
  );

  /// Matches an `http`/`https` URL, with the scheme being optional.
  ///
  /// A path, query string, fragment, port, and subdomains are all accepted.
  static final RegExp url = RegExp(
    r'^(https?:\/\/)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}'
    r'(:\d{1,5})?(\/[^\s]*)?$',
  );

  /// Matches an optionally signed decimal or integer number.
  ///
  /// Examples that match: `42`, `-3.14`, `+0.5`, `.5`, `7.`.
  static final RegExp numeric = RegExp(r'^[+-]?(\d+(\.\d*)?|\.\d+)$');

  /// Matches an optionally signed whole number (no decimal point).
  static final RegExp integer = RegExp(r'^[+-]?\d+$');

  /// Matches strings that contain at least one uppercase letter.
  static final RegExp hasUppercase = RegExp(r'[A-Z]');

  /// Matches strings that contain at least one lowercase letter.
  static final RegExp hasLowercase = RegExp(r'[a-z]');

  /// Matches strings that contain at least one digit.
  static final RegExp hasDigit = RegExp(r'\d');

  /// Matches strings that contain at least one non-alphanumeric, non-space
  /// character (for example `!`, `@`, `#`, `$`).
  static final RegExp hasSpecialCharacter = RegExp(r'[^A-Za-z0-9\s]');

  /// Matches a string made up exclusively of letters.
  static final RegExp alphabetic = RegExp(r'^[a-zA-Z]+$');

  /// Matches a string made up exclusively of letters and digits.
  static final RegExp alphanumeric = RegExp(r'^[a-zA-Z0-9]+$');
}
