import 'package:flutter/material.dart';
import 'package:validate_kit/validate_kit.dart';

/// A live playground that validates a single value as you type.
///
/// Pick a preset rule set, type a value, and watch the raw validator output and
/// the full list of errors update in real time. Toggle aggregation on to see how
/// `validate()` combines every failing message.
class PlaygroundScreen extends StatefulWidget {
  /// Creates the playground screen.
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> {
  final _controller = TextEditingController();
  _Preset _preset = _Preset.email;
  bool _aggregate = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  FieldValidator get _validator {
    switch (_preset) {
      case _Preset.email:
        return FieldValidator()
            .required('Email is required')
            .email('Enter a valid email address');
      case _Preset.password:
        return FieldValidator()
            .required('Password is required')
            .strongPassword();
      case _Preset.url:
        return FieldValidator().url('Enter a valid URL');
      case _Preset.age:
        return FieldValidator()
            .required('Age is required')
            .integer('Whole numbers only')
            .numericRange(18, 120, message: 'Must be between 18 and 120');
      case _Preset.username:
        return FieldValidator()
            .required('Username is required')
            .minLength(3, 'At least 3 characters')
            .maxLength(15, 'At most 15 characters')
            .alphanumeric('Letters and numbers only');
    }
  }

  @override
  Widget build(BuildContext context) {
    final value = _controller.text;
    final errors = _validator.validateAll(value);
    final returned = _aggregate
        ? (errors.isEmpty ? null : errors.join(' • '))
        : (errors.isEmpty ? null : errors.first);
    final isValid = errors.isEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Live playground')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<_Preset>(
            initialValue: _preset,
            decoration: const InputDecoration(
              labelText: 'Rule preset',
              prefixIcon: Icon(Icons.rule),
            ),
            items: _Preset.values
                .map(
                  (_Preset preset) => DropdownMenuItem<_Preset>(
                    value: preset,
                    child: Text(preset.label),
                  ),
                )
                .toList(),
            onChanged: (_Preset? preset) {
              if (preset != null) {
                setState(() => _preset = preset);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              labelText: 'Value',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.text_fields),
            ),
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Aggregate all errors'),
            subtitle: const Text(
              'Return every message instead of only the first',
            ),
            value: _aggregate,
            onChanged: (bool value) => setState(() => _aggregate = value),
          ),
          const SizedBox(height: 8),
          _ResultCard(isValid: isValid, returned: returned, errors: errors),
        ],
      ),
    );
  }
}

enum _Preset {
  email('Email'),
  password('Strong password'),
  url('URL'),
  age('Age (18-120)'),
  username('Username');

  const _Preset(this.label);

  final String label;
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({
    required this.isValid,
    required this.returned,
    required this.errors,
  });

  final bool isValid;
  final String? returned;
  final List<String> errors;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isValid ? Icons.check_circle : Icons.cancel,
                  color: isValid ? Colors.green : colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  isValid ? 'Valid' : 'Invalid',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isValid ? Colors.green : colorScheme.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'validate() returns:',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            SelectableText(
              returned ?? 'null',
              style: TextStyle(
                fontFamily: 'monospace',
                color: returned == null ? Colors.green : colorScheme.error,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'validateAll() errors (${errors.length}):',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 4),
            if (errors.isEmpty)
              const Text('No errors')
            else
              ...errors.map(
                (String error) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
