## 1.0.1

- Initial public release.
- Fluent `FieldValidator` (aliased as `MultiValidator`) with chainable,
  short-circuiting validation rules.
- Built-in rules: `required`, `email`, `minLength`, `maxLength`,
  `lengthBetween`, `numeric`, `numericRange`, `integer`, `url`,
  `strongPassword`, `matches`, `matchesValue`, `pattern`, `contains`,
  `equals`, `oneOf`, and `custom`.
- Optional error aggregation via `aggregate()` and per-call retrieval with
  `validateAll()` / `validateResult()`.
- Localization-ready, globally overridable defaults through
  `ValidationMessages`.
- Convenience `String` extensions such as `isValidEmail`, `isBlank`, and
  `isStrongPassword`.
- Fully documented public API, comprehensive unit tests, and a runnable
  Flutter example app.
- Shortened the pubspec description to comply with pub.dev limits.
