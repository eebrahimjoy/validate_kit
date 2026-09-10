# validate_kit

[![pub package](https://img.shields.io/pub/v/validate_kit.svg)](https://pub.dev/packages/validate_kit)
[![license](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Dart](https://img.shields.io/badge/Dart-%5E3.12-0175C2.svg)](https://dart.dev)

A zero-dependency, fluent form validation toolkit for Dart and Flutter.

Every Flutter developer writes the same validation code over and over: emails,
passwords, matching fields, numeric ranges, custom regex. `validate_kit` turns
that repetitive, nested `if` soup into clean, readable chains that return the
first error — or every error when you want them all.

```dart
final error = FieldValidator()
    .required('Field cannot be blank')
    .email('Enter a valid email address')
    .custom((val) =>
        val!.contains('admin') ? 'Admin emails not allowed' : null)
    .validate(controller.text);
```

## Demo

The example app in action:

![validate_kit demo](https://raw.githubusercontent.com/eebrahimjoy/validate_kit/main/assets/gif/example1.gif)

The `example/` directory contains a full registration form and a live
validation playground.

## Highlights

- **Fluent chaining.** Compose rules in the order they should be evaluated.
- **Zero dependencies.** Pure Dart. Works in Flutter, Dart CLI, and on the
  server. No transitive packages to audit.
- **Short-circuits by default.** The chain stops at the first failure, with an
  opt-in `aggregate()` mode to collect every error instead.
- **Sensible optional fields.** Every format rule skips empty values; only
  `required` forces a value, so optional fields just work.
- **Localization-ready.** Override any default message per call or globally via
  `ValidationMessages`.
- **Drop-in for `TextFormField`.** A `FieldValidator` is callable and exposes an
  `asFunction` tear-off, so it plugs straight into `validator:`.
- **Rich results.** `validateAll()` and `validateResult()` give you every error
  and a typed result object.
- **Handy extensions.** `'a@b.com'.isValidEmail`, `input.isBlank`, and more.
- **Fully documented and tested.** Public API docs on every member and a broad
  unit-test suite covering null safety, boundaries, and edge cases.

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  validate_kit: ^1.0.0
```

Then run:

```sh
flutter pub get   # or: dart pub get
```

## Quick start

```dart
import 'package:validate_kit/validate_kit.dart';

final emailValidator = FieldValidator()
    .required('Email is required')
    .email('Enter a valid email address');

// In a form:
TextFormField(
  controller: emailController,
  validator: emailValidator.asFunction,
);

// Anywhere else:
final error = emailValidator.validate(emailController.text);
if (error != null) {
  // Show `error` to the user.
}
```

A `FieldValidator` is callable, so you can also write
`validator: FieldValidator().required().email().asFunction`.

## Built-in rules

| Rule | Description |
| ---- | ----------- |
| `required([message])` | Value must not be null, empty, or whitespace. |
| `email([message])` | Value must be a valid email address. |
| `url([message])` | Value must be a valid URL (scheme optional). |
| `numeric([message])` | Value must be an integer or decimal number. |
| `numericRange(min, max, {message})` | Number must fall within an inclusive range; either bound may be `null`. |
| `integer([message])` | Value must be a whole number. |
| `minLength(min, [message])` | Trimmed value must have at least `min` characters. |
| `maxLength(max, [message])` | Trimmed value must have at most `max` characters. |
| `lengthBetween(min, max, [message])` | Trimmed length must be within `[min, max]`. |
| `exactLength(length, [message])` | Trimmed value must be exactly `length` characters. |
| `strongPassword({...})` | Password must satisfy configurable character requirements. |
| `matches(() => other, [message])` | Value must equal a lazily-evaluated other value. |
| `matchesValue(other, [message])` | Value must equal a fixed value. |
| `pattern(RegExp, [message])` | Value must match a regular expression. |
| `contains(substring, [message])` | Value must contain a substring. |
| `equals(expected, {caseSensitive, message})` | Value must equal an expected string. |
| `oneOf(values, {caseSensitive, message})` | Value must be one of a set of options. |
| `alphabetic([message])` | Value must contain only letters. |
| `alphanumeric([message])` | Value must contain only letters and digits. |
| `custom((value) => ..., {skipOnEmpty})` | Run any function returning `null` or an error message. |

> Rules that validate a format or length **skip empty values**, so they are safe
> to chain on optional fields. Add `required()` when the field is mandatory.

## Common recipes

### Confirm password

```dart
final confirmValidator = FieldValidator()
    .required('Please confirm your password')
    .matches(() => passwordController.text, 'Passwords do not match');
```

The `matches` callback is evaluated at validation time, so it always reads the
current password.

### Strong password

```dart
final passwordValidator = FieldValidator().strongPassword(
  minLength: 10,
  requireSpecialCharacter: false,
);
```

By default it requires at least 8 characters plus an uppercase letter, a
lowercase letter, a number, and a special character. Each requirement can be
toggled.

### Age / numeric range

```dart
final ageValidator = FieldValidator()
    .required('Age is required')
    .integer('Whole numbers only')
    .numericRange(18, 120, message: 'You must be between 18 and 120');
```

### Custom rule

```dart
final noAdminValidator = FieldValidator().custom(
  (value) =>
      value!.contains('admin') ? 'Admin emails are not allowed' : null,
);
```

## Collecting every error

By default `validate()` returns only the first failing message. Enable
aggregation to return them all joined by a separator:

```dart
final validator = FieldValidator(
  aggregate: true,
  separator: '\n',
)
    .required('Field cannot be blank')
    .email('Enter a valid email address');

// Or configure it fluently:
final same = FieldValidator()
    .required('Field cannot be blank')
    .email('Enter a valid email address')
    .aggregate(separator: ' • ');
```

For structured access, `validateAll()` always returns the full list and
`validateResult()` returns a `ValidationResult`:

```dart
final result = validator.validateResult(input);
if (result.isInvalid) {
  for (final message in result.errors) {
    debugPrint(message);
  }
}
```

## Localization

Every default message lives on `ValidationMessages`. Override the ones you need
once at start-up, then continue to pass per-call overrides where it makes sense:

```dart
void main() {
  ValidationMessages.required = 'Este campo es obligatorio.';
  ValidationMessages.email = 'Introduce un correo válido.';
  ValidationMessages.mismatch = 'Los valores no coinciden.';
  runApp(const MyApp());
}
```

## String extensions

For quick checks outside a form, import the library and use the extensions:

```dart
'a@b.com'.isValidEmail;      // true
'https://a.com'.isValidUrl;  // true
'3.14'.isNumeric;            // true
'42'.isInteger;              // true
'Abcd123!'.isStrongPassword; // true
'   '.isBlank;               // true (null-aware)
'ab1'.isAlphanumeric;        // true

// Normalize optional input:
final value = input.trimmedOrNull; // null when blank
```

You can also delegate to a validator with `validateWith`:

```dart
final error = input.validateWith(
  FieldValidator().required().email(),
);
```

## Single-rule helpers

When one rule is all you need, `Validators` returns a plain
`String? Function(String?)`:

```dart
TextFormField(validator: Validators.email());
TextFormField(validator: Validators.minLength(3, 'Too short'));
```

## Example

The `example/` directory contains a runnable app with a full registration form
(every built-in rule in context) and a live playground that validates as you
type:

```sh
cd example
flutter run
```

## API overview

- `FieldValidator` (alias `MultiValidator`) — the fluent builder.
- `ValidationRule` — a single immutable rule; extend the package with `addRule`.
- `ValidationResult` — `isValid`, `errors`, `firstError`.
- `ValidationMessages` — overridable default messages.
- `Validators` — single-rule factory helpers.
- String extensions on `String` and `String?`.

## Author and Contact

Developed and maintained by **Ebrahim Joy**.

- Email: [eebrahimjoy@gmail.com](mailto:eebrahimjoy@gmail.com)
- Website: [eebrahimjoy.com](https://eebrahimjoy.com)
- GitHub: [@eebrahimjoy](https://github.com/eebrahimjoy)

## Contributing

Please report bugs and request features through the
[issue tracker](https://github.com/eebrahimjoy/validate_kit/issues).
Pull requests are welcome.

## License

Released under the [MIT License](LICENSE).
