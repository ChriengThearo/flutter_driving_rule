import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/learning/domain/module_config.dart';
import 'features/learning/presentation/home_screen.dart';
import 'features/learning/presentation/module_screen.dart';

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
      home: const HomeScreen(),
      routes: {
        for (final module in ModuleConfig.all)
          module.routeName: (context) => ModuleScreen(module: module),
      },
    );
  }
}
