import 'package:flutter/material.dart';
import 'package:validate_kit/validate_kit.dart';

import 'playground_screen.dart';

/// A real-world registration form built with `TextFormField` and validate_kit.
///
/// Every field uses a [FieldValidator] chain, demonstrating required checks,
/// format rules, length bounds, numeric ranges, strong passwords, matching
/// fields, pattern matching, and membership rules.
class FormDemoScreen extends StatefulWidget {
  /// Creates the form demo screen.
  const FormDemoScreen({super.key});

  @override
  State<FormDemoScreen> createState() => _FormDemoScreenState();
}

class _FormDemoScreenState extends State<FormDemoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _ageController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _bioController = TextEditingController();

  static const _countries = <String>[
    'United States',
    'United Kingdom',
    'Bangladesh',
    'Germany',
    'Japan',
  ];
  String? _country;

  // ---------------------------------------------------------------------------
  // Validators. Each chain is declared once and reused across rebuilds.
  // ---------------------------------------------------------------------------

  late final FieldValidator _nameValidator = FieldValidator()
      .required('Please enter your full name')
      .minLength(2, 'Name is too short')
      .maxLength(60, 'Name is too long')
      .pattern(RegExp(r'^[a-zA-Z ]+$'), 'Letters and spaces only');

  late final FieldValidator _emailValidator = FieldValidator()
      .required('Email is required')
      .email('Enter a valid email address');

  late final FieldValidator _websiteValidator = FieldValidator().url(
    'Enter a valid URL (for example https://example.com)',
  );

  late final FieldValidator _ageValidator = FieldValidator()
      .required('Age is required')
      .integer('Age must be a whole number')
      .numericRange(18, 120, message: 'You must be between 18 and 120');

  late final FieldValidator _passwordValidator = FieldValidator()
      .required('Password is required')
      .strongPassword(
        minLength: 8,
        message: 'Use 8+ chars with upper, lower, number, and symbol',
      );

  late final FieldValidator _confirmPasswordValidator = FieldValidator()
      .required('Please confirm your password')
      .matches(() => _passwordController.text, 'Passwords do not match');

  late final FieldValidator _bioValidator = FieldValidator().maxLength(
    140,
    'Bio must be 140 characters or fewer',
  );

  late final FieldValidator _countryValidator = FieldValidator()
      .required('Please select a country')
      .oneOf(_countries, message: 'Choose a listed country');

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _ageController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration form is valid.')),
      );
    }
  }

  void _reset() {
    _formKey.currentState!.reset();
    for (final controller in <TextEditingController>[
      _nameController,
      _emailController,
      _websiteController,
      _ageController,
      _passwordController,
      _confirmPasswordController,
      _bioController,
    ]) {
      controller.clear();
    }
    setState(() => _country = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('validate_kit'),
        actions: [
          IconButton(
            tooltip: 'Open live playground',
            icon: const Icon(Icons.science_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PlaygroundScreen()),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          children: [
            const _SectionHeader('Account details'),
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: _nameValidator.asFunction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.alternate_email),
              ),
              validator: _emailValidator.asFunction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _websiteController,
              keyboardType: TextInputType.url,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Website (optional)',
                prefixIcon: Icon(Icons.link),
              ),
              validator: _websiteValidator.asFunction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Age',
                prefixIcon: Icon(Icons.cake_outlined),
              ),
              validator: _ageValidator.asFunction,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _country,
              decoration: const InputDecoration(
                labelText: 'Country',
                prefixIcon: Icon(Icons.public),
              ),
              items: _countries
                  .map(
                    (String country) => DropdownMenuItem<String>(
                      value: country,
                      child: Text(country),
                    ),
                  )
                  .toList(),
              onChanged: (String? value) => _country = value,
              validator: _countryValidator.asFunction,
            ),
            const _SectionHeader('Security'),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: _passwordValidator.asFunction,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
              validator: _confirmPasswordValidator.asFunction,
            ),
            const _SectionHeader('About you'),
            TextFormField(
              controller: _bioController,
              maxLines: 3,
              maxLength: 140,
              decoration: const InputDecoration(
                labelText: 'Short bio (optional)',
                alignLabelWithHint: true,
              ),
              validator: _bioValidator.asFunction,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.check),
              label: const Text('Create account'),
            ),
            const SizedBox(height: 8),
            TextButton(onPressed: _reset, child: const Text('Reset')),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
