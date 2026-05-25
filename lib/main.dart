import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const DrivingRuleApp());
}

class DrivingRuleApp extends StatelessWidget {
  const DrivingRuleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Driving Rule',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Rule')),
      body: const Center(
        child: Text(
          'Welcome to Driving Rule',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
