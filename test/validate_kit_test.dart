import 'package:test/test.dart';
import 'package:validate_kit/validate_kit.dart';

void main() {
  group('FieldValidator.required', () {
    test('rejects null, empty, and whitespace-only values', () {
      final validator = FieldValidator().required('required');

      expect(validator.validate(null), 'required');
      expect(validator.validate(''), 'required');
      expect(validator.validate('   '), 'required');
      expect(validator.validate('\t\n'), 'required');
    });

    test('accepts a non-empty value', () {
      final validator = FieldValidator().required();
      expect(validator.validate('hello'), isNull);
      expect(validator.isValid('hello'), isTrue);
      expect(validator.isInvalid(''), isTrue);
    });

    test('uses the global default message when none is provided', () {
      expect(
        FieldValidator().required().validate(''),
        ValidationMessages.required,
      );
    });
  });

  group('FieldValidator.email', () {
    final validator = FieldValidator().email('bad email');

    test('accepts common valid addresses', () {
      for (final value in <String>[
        'user@example.com',
        'first.last@sub.example.co.uk',
        'name+tag@example.io',
        "o'brien@example.com",
        'user123@example-domain.com',
      ]) {
        expect(validator.validate(value), isNull, reason: value);
      }
    });

    test('rejects malformed addresses', () {
      for (final value in <String>[
        'plainaddress',
        '@example.com',
        'user@',
        'user@example',
        'user@@example.com',
        'user example@test.com',
        'user@exam ple.com',
      ]) {
        expect(validator.validate(value), 'bad email', reason: value);
      }
    });

    test('is skipped for empty values unless required is chained', () {
      expect(validator.validate(''), isNull);
      final requiredEmail = FieldValidator().required('req').email('bad');
      expect(requiredEmail.validate(''), 'req');
      expect(requiredEmail.validate('not-an-email'), 'bad');
      expect(requiredEmail.validate('a@b.com'), isNull);
    });
  });

  group('FieldValidator.url', () {
    final validator = FieldValidator().url('bad url');

    test('accepts valid URLs with and without a scheme', () {
      for (final value in <String>[
        'https://example.com',
        'http://example.com/path?query=1#frag',
        'example.com',
        'sub.example.co.uk:8080/path',
      ]) {
        expect(validator.validate(value), isNull, reason: value);
      }
    });

    test('rejects invalid URLs', () {
      for (final value in <String>[
        'not a url',
        'http://',
        '://example.com',
        'foo',
      ]) {
        expect(validator.validate(value), 'bad url', reason: value);
      }
    });
  });

  group('numeric rules', () {
    test('numeric accepts integers, decimals, and signs', () {
      final validator = FieldValidator().numeric('not a number');
      for (final value in <String>['0', '42', '-7', '+3.14', '.5', '7.']) {
        expect(validator.validate(value), isNull, reason: value);
      }
    });

    test('numeric rejects non-numeric input', () {
      final validator = FieldValidator().numeric('not a number');
      for (final value in <String>['abc', '1,000', '1e3', '1.2.3', '--1']) {
        expect(validator.validate(value), 'not a number', reason: value);
      }
    });

    test('integer accepts only whole numbers', () {
      final validator = FieldValidator().integer('not int');
      expect(validator.validate('42'), isNull);
      expect(validator.validate('-3'), isNull);
      expect(validator.validate('+10'), isNull);
      expect(validator.validate('3.14'), 'not int');
      expect(validator.validate('abc'), 'not int');
    });

    test('numericRange enforces inclusive bounds', () {
      final validator = FieldValidator().numericRange(1, 10, message: 'range');
      expect(validator.validate('1'), isNull);
      expect(validator.validate('10'), isNull);
      expect(validator.validate('0'), 'range');
      expect(validator.validate('11'), 'range');
      expect(validator.validate('abc'), 'range');
    });

    test('numericRange supports open-ended bounds', () {
      expect(
        FieldValidator().numericRange(5, null, message: 'min').validate('4'),
        'min',
      );
      expect(
        FieldValidator().numericRange(5, null, message: 'min').validate('5'),
        isNull,
      );
      expect(
        FieldValidator().numericRange(null, 5, message: 'max').validate('6'),
        'max',
      );
      expect(
        FieldValidator().numericRange(null, 5, message: 'max').validate('5'),
        isNull,
      );
    });

    test('numericRange builds descriptive default messages', () {
      expect(FieldValidator().numericRange(1, 10).validate('0'), contains('1'));
      expect(
        FieldValidator().numericRange(1, null).validate('0'),
        contains('greater than or equal'),
      );
      expect(
        FieldValidator().numericRange(null, 10).validate('99'),
        contains('less than or equal'),
      );
    });
  });

  group('length rules', () {
    test('minLength and maxLength respect trimmed boundaries', () {
      final min = FieldValidator().minLength(3, 'short');
      expect(min.validate('ab'), 'short');
      expect(min.validate('abc'), isNull);
      expect(min.validate(' abc '), isNull);

      final max = FieldValidator().maxLength(3, 'long');
      expect(max.validate('abcd'), 'long');
      expect(max.validate('abc'), isNull);
    });

    test('lengthBetween enforces both bounds', () {
      final validator = FieldValidator().lengthBetween(2, 4, 'len');
      expect(validator.validate('a'), 'len');
      expect(validator.validate('ab'), isNull);
      expect(validator.validate('abcd'), isNull);
      expect(validator.validate('abcde'), 'len');
    });

    test('exactLength requires an exact size', () {
      final validator = FieldValidator().exactLength(4, 'exact');
      expect(validator.validate('abc'), 'exact');
      expect(validator.validate('abcd'), isNull);
      expect(validator.validate('abcde'), 'exact');
    });
  });

  group('FieldValidator.strongPassword', () {
    final validator = FieldValidator().strongPassword(message: 'weak');

    test('accepts a password meeting every requirement', () {
      expect(validator.validate('Abcd123!'), isNull);
      expect(validator.validate('Str0ng#Pass'), isNull);
    });

    test('rejects passwords missing any requirement', () {
      expect(validator.validate('Abc1!'), 'weak'); // too short
      expect(validator.validate('abcd123!'), 'weak'); // no uppercase
      expect(validator.validate('ABCD123!'), 'weak'); // no lowercase
      expect(validator.validate('Abcdefg!'), 'weak'); // no number
      expect(validator.validate('Abcdefg1'), 'weak'); // no special char
    });

    test('honours relaxed requirements', () {
      final relaxed = FieldValidator().strongPassword(
        minLength: 6,
        requireSpecialCharacter: false,
        requireUppercase: false,
        message: 'weak',
      );
      expect(relaxed.validate('abcdef1'), isNull);
      expect(relaxed.validate('abcde'), 'weak');
    });

    test('is skipped for empty values', () {
      expect(validator.validate(''), isNull);
      expect(validator.validate(null), isNull);
    });

    test('default message lists enabled requirements', () {
      final message = ValidationMessages.strongPassword();
      expect(message, contains('8'));
      expect(message, contains('uppercase'));
      expect(message, contains('lowercase'));
      expect(message, contains('number'));
      expect(message, contains('special'));
    });
  });

  group('matching rules', () {
    test('matches compares lazily against the other value', () {
      var password = 'secret';
      final validator = FieldValidator().matches(() => password, 'mismatch');

      expect(validator.validate('secret'), isNull);
      expect(validator.validate('nope'), 'mismatch');

      // Changing the source value is picked up on the next run.
      password = 'changed';
      expect(validator.validate('changed'), isNull);
      expect(validator.validate('secret'), 'mismatch');
    });

    test('matchesValue compares against a fixed value', () {
      final validator = FieldValidator().matchesValue('abc', 'mismatch');
      expect(validator.validate('abc'), isNull);
      expect(validator.validate('abd'), 'mismatch');
    });

    test('matching is skipped for empty values', () {
      expect(FieldValidator().matchesValue('abc').validate(''), isNull);
    });

    test('uses the default mismatch message', () {
      expect(
        FieldValidator().matchesValue('a').validate('b'),
        ValidationMessages.mismatch,
      );
    });
  });

  group('membership rules', () {
    test('contains checks for a substring', () {
      final validator = FieldValidator().contains('@', 'needs @');
      expect(validator.validate('a@b'), isNull);
      expect(validator.validate('ab'), 'needs @');
    });

    test('equals supports case sensitivity', () {
      final sensitive = FieldValidator().equals('Yes', message: 'no');
      expect(sensitive.validate('Yes'), isNull);
      expect(sensitive.validate('yes'), 'no');

      final insensitive = FieldValidator().equals(
        'Yes',
        caseSensitive: false,
        message: 'no',
      );
      expect(insensitive.validate('yes'), isNull);
      expect(insensitive.validate('YES'), isNull);
      expect(insensitive.validate('no'), 'no');
    });

    test('oneOf checks membership', () {
      final validator = FieldValidator().oneOf(<String>[
        'a',
        'b',
      ], message: 'bad');
      expect(validator.validate('a'), isNull);
      expect(validator.validate('c'), 'bad');

      final insensitive = FieldValidator().oneOf(
        <String>['A', 'B'],
        caseSensitive: false,
        message: 'bad',
      );
      expect(insensitive.validate('a'), isNull);
      expect(insensitive.validate('C'), 'bad');
    });

    test('pattern applies a regular expression', () {
      final validator = FieldValidator().pattern(RegExp(r'^\d{5}$'), 'zip');
      expect(validator.validate('12345'), isNull);
      expect(validator.validate('1234'), 'zip');
    });
  });

  group('custom rules', () {
    test('returns the custom error message when the check fails', () {
      final validator = FieldValidator().custom(
        (value) =>
            (value ?? '').contains('admin') ? 'Admin emails not allowed' : null,
      );
      expect(validator.validate('admin@test.com'), 'Admin emails not allowed');
      expect(validator.validate('user@test.com'), isNull);
    });

    test('is skipped for empty values by default', () {
      var calls = 0;
      final validator = FieldValidator().custom((value) {
        calls++;
        return null;
      });
      expect(validator.validate(''), isNull);
      expect(calls, 0);
    });

    test('runs for empty values when skipOnEmpty is false', () {
      var calls = 0;
      final validator = FieldValidator().custom((value) {
        calls++;
        return null;
      }, skipOnEmpty: false);
      validator.validate('');
      expect(calls, 1);
    });
  });

  group('chaining and short-circuiting', () {
    test('stops at the first error by default', () {
      final validator = FieldValidator()
          .required('required')
          .email('email')
          .minLength(10, 'length');

      expect(validator.validate(''), 'required');
      expect(validator.validate('not-an-email'), 'email');
      expect(validator.validate('a@b.com'), 'length');
      expect(validator.validate('longenough@b.com'), isNull);
    });

    test('rule order is preserved', () {
      final validator = FieldValidator().required().minLength(5).maxLength(10);
      expect(validator.ruleCount, 3);
      expect(validator.rules.first.description, 'required');
      expect(validator.rules.last.description, 'maxLength(10)');
    });
  });

  group('aggregation and results', () {
    test('aggregate joins all errors with the default separator', () {
      final validator = FieldValidator(
        aggregate: true,
      ).required('required').minLength(5, 'length').contains('@', 'at');

      expect(validator.validate('ab'), 'length\nat');
      expect(validator.validate(''), 'required');
    });

    test('aggregate supports a custom separator', () {
      final validator = FieldValidator()
          .minLength(5, 'length')
          .contains('@', 'at')
          .aggregate(separator: ' | ');
      expect(validator.validate('ab'), 'length | at');
    });

    test('validateAll always returns every error', () {
      final validator = FieldValidator()
          .required('required')
          .minLength(5, 'length');
      expect(validator.validateAll('ab'), <String>['length']);
      expect(validator.validateAll(''), <String>['required']);
      expect(validator.validateAll('abcdef'), isEmpty);
    });

    test('validateResult exposes a rich result object', () {
      final validator = FieldValidator().required('required').email('email');

      final invalid = validator.validateResult('nope');
      expect(invalid.isValid, isFalse);
      expect(invalid.isInvalid, isTrue);
      expect(invalid.errorCount, 1);
      expect(invalid.firstError, 'email');
      expect(invalid.error, 'email');

      final valid = validator.validateResult('a@b.com');
      expect(valid.isValid, isTrue);
      expect(valid.errors, isEmpty);
      expect(valid.firstError, isNull);
      expect(valid, const ValidationResult.valid());
    });

    test('ValidationResult does not allow external mutation', () {
      final result = ValidationResult(<String>['a']);
      expect(() => result.errors.add('b'), throwsUnsupportedError);
    });
  });

  group('callable and factory helpers', () {
    test('FieldValidator can be called like a function', () {
      final validator = FieldValidator().required('required');
      expect(validator(''), 'required');
      expect(validator('ok'), isNull);
    });

    test('asFunction exposes a typed tear-off', () {
      final String? Function(String?) fn = FieldValidator()
          .email('email')
          .asFunction;
      expect(fn('a@b.com'), isNull);
      expect(fn('nope'), 'email');
    });

    test('Validators factory methods produce usable callbacks', () {
      expect(Validators.required()(''), ValidationMessages.required);
      expect(Validators.email()('a@b.com'), isNull);
      expect(Validators.email()('nope'), ValidationMessages.email);
      expect(Validators.minLength(2)('a'), isNotNull);
      expect(Validators.maxLength(2)('abc'), isNotNull);
      expect(Validators.numeric()('12'), isNull);
      expect(Validators.integer()('1.2'), isNotNull);
      expect(Validators.url()('https://a.com'), isNull);
      expect(Validators.strongPassword()('Abcd123!'), isNull);
      expect(Validators.custom((value) => 'always')('x'), 'always');
    });
  });

  group('lifecycle helpers', () {
    test('clear removes every rule', () {
      final validator = FieldValidator().required().email();
      expect(validator.isNotEmpty, isTrue);
      expect(validator.clear().ruleCount, 0);
      expect(validator.isEmpty, isTrue);
      expect(validator.validate(''), isNull);
    });

    test('clone copies rules and settings independently', () {
      final original = FieldValidator().required('required');
      final copy = original.clone().aggregate();

      expect(copy.ruleCount, original.ruleCount);
      expect(original.isAggregating, isFalse);
      expect(copy.isAggregating, isTrue);

      copy.email('email');
      expect(original.ruleCount, 1);
      expect(copy.ruleCount, 2);
    });

    test('addRule appends a rule', () {
      final validator = FieldValidator().addRule(
        ValidationRule(
          description: 'startsWithA',
          skipOnEmpty: false,
          check: (value) =>
              (value ?? '').startsWith('a') ? null : 'Must start with a',
        ),
      );
      expect(validator.validate('abc'), isNull);
      expect(validator.validate('xyz'), 'Must start with a');
    });
  });

  group('string extensions', () {
    test('blank detection', () {
      expect(''.isBlank, isTrue);
      expect('   '.isBlank, isTrue);
      expect((null as String?).isBlank, isTrue);
      expect('x'.isNotBlank, isTrue);
      expect('x'.isBlank, isFalse);
    });

    test('format detection', () {
      expect('a@b.com'.isValidEmail, isTrue);
      expect('nope'.isValidEmail, isFalse);
      expect('https://a.com'.isValidUrl, isTrue);
      expect('nope'.isValidUrl, isFalse);
      expect('3.14'.isNumeric, isTrue);
      expect('abc'.isNumeric, isFalse);
      expect('42'.isInteger, isTrue);
      expect('4.2'.isInteger, isFalse);
      expect('Abcd123!'.isStrongPassword, isTrue);
      expect('weak'.isStrongPassword, isFalse);
      expect('abc'.isAlphabetic, isTrue);
      expect('ab1'.isAlphabetic, isFalse);
      expect('ab1'.isAlphanumeric, isTrue);
      expect('ab-1'.isAlphanumeric, isFalse);
    });

    test('validateWith delegates to a validator', () {
      final validator = FieldValidator().required('required').email('email');
      expect('nope'.validateWith(validator), 'email');
      expect('a@b.com'.validateWith(validator), isNull);
    });

    test('trimmedOrNull normalizes optional input', () {
      expect('  hello  '.trimmedOrNull, 'hello');
      expect('   '.trimmedOrNull, isNull);
      expect(''.isBlankString, isTrue);
    });
  });

  group('global message overrides', () {
    late String originalRequired;
    late String originalEmail;

    setUp(() {
      originalRequired = ValidationMessages.required;
      originalEmail = ValidationMessages.email;
    });

    tearDown(() {
      ValidationMessages.required = originalRequired;
      ValidationMessages.email = originalEmail;
    });

    test('localized defaults are used when no override is supplied', () {
      ValidationMessages.required = 'Obligatorio';
      ValidationMessages.email = 'Correo inválido';

      expect(FieldValidator().required().validate(''), 'Obligatorio');
      expect(FieldValidator().email().validate('nope'), 'Correo inválido');
    });

    test('per-call messages take precedence over global defaults', () {
      ValidationMessages.required = 'Obligatorio';
      expect(FieldValidator().required('Custom').validate(''), 'Custom');
    });
  });

  group('null safety and edge cases', () {
    test('every format rule tolerates null without throwing', () {
      final validator = FieldValidator()
          .email()
          .url()
          .numeric()
          .integer()
          .minLength(3)
          .maxLength(5)
          .lengthBetween(1, 3)
          .exactLength(2)
          .strongPassword()
          .pattern(RegExp(r'^\d+$'))
          .contains('x')
          .equals('x')
          .oneOf(<String>['x']);

      expect(validator.validate(null), isNull);
      expect(validator.validate(''), isNull);
    });

    test('custom validator receives the raw value including whitespace', () {
      String? received;
      FieldValidator()
          .custom((value) {
            received = value;
            return null;
          })
          .validate('  raw  ');
      expect(received, '  raw  ');
    });

    test('an empty validator treats every value as valid', () {
      expect(FieldValidator().validate(null), isNull);
      expect(FieldValidator().validate('anything'), isNull);
      expect(FieldValidator().isValid('anything'), isTrue);
    });
  });
}
