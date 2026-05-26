import 'package:flutter/material.dart';

import '../domain/module_config.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF91FFE9),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Image.asset(
                    'images/home_page/hands.png',
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'WELCOME TO',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'DRIVING RULE',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: ModuleConfig.all.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final module = ModuleConfig.all[index];
                  return Card(
                    key: Key('moduleCard_${module.title}'),
                    child: ListTile(
                      title: Text(module.title),
                      subtitle: const Text(
                        'Search questions and view correct answers',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          Navigator.pushNamed(context, module.routeName),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
