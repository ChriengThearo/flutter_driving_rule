import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/auth_page.dart';

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
      home: const AuthPage(),
    );
  }
}
