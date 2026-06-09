import 'package:driving_rule/features/exam/data/exam_repository.dart';
import 'package:driving_rule/features/exam/domain/exam_question.dart';
import 'package:driving_rule/features/exam/presentation/exam_screen.dart';
import 'package:driving_rule/features/learning/domain/driving_question.dart';
import 'package:driving_rule/features/learning/domain/module_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wrong priority answer fails exam immediately', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ExamScreen(
          repository: _FakeExamRepository([
            ExamQuestion(
              module: ModuleConfig.priority,
              question: DrivingQuestion(
                id: 'priority-1',
                question: '1.png',
                options: const ['Wrong', 'Correct', 'Also wrong'],
                correctIndex: 1,
              ),
            ),
            ExamQuestion(
              module: ModuleConfig.general,
              question: DrivingQuestion(
                id: 'general-1',
                question: 'General question',
                options: const ['Correct', 'Wrong', 'Also wrong'],
                correctIndex: 0,
              ),
            ),
          ]),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('examAnswer_0')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('examNextButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('examResultTitle')), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.text('Score: 0/2'), findsOneWidget);
    expect(
      find.text('A wrong Priority answer causes an automatic fail.'),
      findsOneWidget,
    );
  });
}

class _FakeExamRepository extends ExamRepository {
  _FakeExamRepository(this._questions);

  final List<ExamQuestion> _questions;

  @override
  Future<List<ExamQuestion>> buildExamQuestions() async => _questions;
}
