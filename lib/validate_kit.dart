/// A zero-dependency, fluent form validation toolkit for Dart and Flutter.
///
/// `validate_kit` replaces repetitive, nested form validation code with clean,
/// chainable rules that read like a sentence:
///
/// ```dart
/// import 'package:validate_kit/validate_kit.dart';
///
/// final error = FieldValidator()
///     .required('Field cannot be blank')
///     .email('Enter a valid email address')
///     .custom((value) =>
///         value!.contains('admin') ? 'Admin emails not allowed' : null)
///     .validate(controller.text);
/// ```
///
/// Every built-in rule skips empty values unless it is [FieldValidator.required],
/// so optional fields behave intuitively. Error messages can be overridden per
/// call or globally through [ValidationMessages] for localization.
library;

export 'src/extensions/string_validation_extensions.dart';
export 'src/field_validator.dart';
export 'src/validation_messages.dart';
export 'src/validation_result.dart';
export 'src/validation_rule.dart';
export 'src/validators/common_validators.dart';
