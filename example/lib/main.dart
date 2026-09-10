import 'package:flutter/material.dart';

import 'screens/form_demo_screen.dart';

/// Entry point for the validate_kit example application.
void main() {
  runApp(const ValidateKitExampleApp());
}

/// Root widget of the example application.
class ValidateKitExampleApp extends StatelessWidget {
  /// Creates the example application.
  const ValidateKitExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ValidateKit Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF4F46E5),
      ),
      home: const FormDemoScreen(),
    );
  }
}
