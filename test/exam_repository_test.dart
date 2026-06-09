import 'dart:math';

import 'package:driving_rule/features/exam/data/exam_repository.dart';
import 'package:driving_rule/features/learning/data/driving_question_repository.dart';
import 'package:driving_rule/features/learning/domain/driving_question.dart';
import 'package:driving_rule/features/learning/domain/module_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('buildExamQuestions creates required category order', () async {
    final repository = ExamRepository(
      questionRepository: _FakeDrivingQuestionRepository(),
      random: Random(1),
    );

    final questions = await repository.buildExamQuestions();

    expect(questions, hasLength(45));
    expect(
      questions.take(15).map((question) => question.module.routeName).toSet(),
      {ModuleConfig.general.routeName},
    );
    expect(
      questions
          .skip(15)
          .take(10)
          .map((question) => question.module.routeName)
          .toSet(),
      {ModuleConfig.sign.routeName},
    );
    expect(
      questions
          .skip(25)
          .take(5)
          .map((question) => question.module.routeName)
          .toSet(),
      {ModuleConfig.priority.routeName},
    );
    expect(
      questions
          .skip(30)
          .take(5)
          .map((question) => question.module.routeName)
          .toSet(),
      {ModuleConfig.general.routeName},
    );
    expect(
      questions
          .skip(35)
          .take(5)
          .map((question) => question.module.routeName)
          .toSet(),
      {ModuleConfig.technique.routeName},
    );
    expect(
      questions
          .skip(40)
          .take(5)
          .map((question) => question.module.routeName)
          .toSet(),
      {ModuleConfig.emergency.routeName},
    );
  });

  test('buildExamQuestions does not duplicate general questions', () async {
    final repository = ExamRepository(
      questionRepository: _FakeDrivingQuestionRepository(),
      random: Random(2),
    );

    final questions = await repository.buildExamQuestions();
    final generalIds = questions
        .where(
          (question) =>
              question.module.routeName == ModuleConfig.general.routeName,
        )
        .map((question) => question.question.id)
        .toList();

    expect(generalIds, hasLength(20));
    expect(generalIds.toSet(), hasLength(20));
  });
}

class _FakeDrivingQuestionRepository extends DrivingQuestionRepository {
  @override
  Future<List<DrivingQuestion>> loadQuestions(ModuleConfig module) async {
    final count = switch (module.routeName) {
      final route when route == ModuleConfig.general.routeName => 30,
      final route when route == ModuleConfig.sign.routeName => 15,
      final route when route == ModuleConfig.priority.routeName => 10,
      final route when route == ModuleConfig.technique.routeName => 10,
      final route when route == ModuleConfig.emergency.routeName => 10,
      _ => 0,
    };

    return List.generate(
      count,
      (index) => DrivingQuestion(
        id: '${module.title}-$index',
        question: '${module.title} question $index',
        options: const ['A', 'B', 'C'],
        correctIndex: 0,
      ),
    );
  }
}
