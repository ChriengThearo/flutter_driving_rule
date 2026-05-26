import 'package:flutter/material.dart';

import '../data/driving_question_repository.dart';
import '../domain/driving_question.dart';
import '../domain/module_config.dart';

class ModuleScreen extends StatefulWidget {
  const ModuleScreen({required this.module, this.repository, super.key});

  final ModuleConfig module;
  final DrivingQuestionRepository? repository;

  @override
  State<ModuleScreen> createState() => _ModuleScreenState();
}

class _ModuleScreenState extends State<ModuleScreen> {
  late final DrivingQuestionRepository _repository;
  late final Future<List<DrivingQuestion>> _questionsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DrivingQuestionRepository();
    _questionsFuture = _repository.loadQuestions(widget.module);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.module.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              key: const Key('moduleSearchField'),
              decoration: const InputDecoration(
                labelText: 'Search question keyword',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value.trim()),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<DrivingQuestion>>(
                future: _questionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Failed to load module: ${snapshot.error}'),
                    );
                  }

                  final questions = snapshot.data ?? <DrivingQuestion>[];
                  final filtered = _filterQuestions(questions);

                  if (filtered.isEmpty) {
                    return const Center(child: Text('No matching questions.'));
                  }

                  return ListView.separated(
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final question = filtered[index];
                      return _QuestionItem(
                        question: question,
                        module: widget.module,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<DrivingQuestion> _filterQuestions(List<DrivingQuestion> questions) {
    if (_query.isEmpty) {
      return questions;
    }
    final query = _query.toLowerCase();
    return questions.where((question) {
      if (widget.module.isImageQuestion) {
        return question.options.any(
          (option) => option.toLowerCase().contains(query),
        );
      }
      return question.question.toLowerCase().contains(query);
    }).toList();
  }
}

class _QuestionItem extends StatelessWidget {
  const _QuestionItem({required this.question, required this.module});

  final DrivingQuestion question;
  final ModuleConfig module;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        key: Key('questionTile_${question.id}'),
        title: _buildTitle(),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          if (module.isImageQuestion) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                '${module.imageBasePath}${question.question}',
                height: 160,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Text('Image not found'),
              ),
            ),
            const SizedBox(height: 12),
          ] else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                question.question,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
          ],
          ...List.generate(question.options.length, (index) {
            final isCorrect = index == question.correctIndex;
            return Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isCorrect ? Colors.green.shade50 : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.grey.shade300,
                ),
              ),
              child: Text(question.options[index]),
            );
          }),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Correct answer: ${question.correctAnswer}',
              key: Key('answerDetail_${question.id}'),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    if (module.isImageQuestion) {
      return Text('Question ${question.id}');
    }
    return Text(question.question);
  }
}
