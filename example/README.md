# validate_kit_example

A runnable Flutter app demonstrating the
[validate_kit](https://pub.dev/packages/validate_kit) package.

## What it shows

- A full registration form built with `TextFormField` and fluent
  `FieldValidator` chains: required checks, email, URL, integer, numeric range,
  strong password, matching password confirmation, pattern, membership, and
  length bounds.
- A live playground that validates a single value as you type and displays the
  returned error alongside the complete `validateAll()` error list.
- Toggling aggregation to see how `validate()` combines every failing message.

## Running

```sh
flutter pub get
flutter run
```

The app is configured for both iOS and Android.
