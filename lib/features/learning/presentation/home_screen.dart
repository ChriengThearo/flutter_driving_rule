import 'package:flutter/material.dart';

import '../domain/module_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Driving Rule Modules')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: ModuleConfig.all.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final module = ModuleConfig.all[index];
          return Card(
            key: Key('moduleCard_${module.title}'),
            child: ListTile(
              title: Text(module.title),
              subtitle: const Text('Search questions and view correct answers'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, module.routeName),
            ),
          );
        },
      ),
    );
  }
}
