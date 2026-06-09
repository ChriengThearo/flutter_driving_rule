import 'package:driving_rule/features/learning/data/driving_question_repository.dart';
import 'package:driving_rule/features/learning/domain/driving_question.dart';
import 'package:driving_rule/features/learning/domain/module_config.dart';
import 'package:driving_rule/features/learning/presentation/module_screen.dart';
import 'package:driving_rule/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Home shows module cards and exam card', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const DrivingRuleApp());
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moduleCard_Exam')), findsOneWidget);
    expect(find.byKey(const Key('moduleCard_General')), findsOneWidget);
    expect(find.byKey(const Key('moduleCard_Emergency')), findsOneWidget);
    expect(find.byKey(const Key('moduleCard_Technique')), findsOneWidget);
    expect(find.byKey(const Key('moduleCard_Sign')), findsOneWidget);

    await tester.drag(find.byType(ListView), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('moduleCard_Priority')), findsOneWidget);
  });

  testWidgets(
    'Text module search filters by question and shows answer detail',
    (WidgetTester tester) async {
      final fakeRepo = _FakeDrivingQuestionRepository({
        ModuleConfig.general.routeName: [
          DrivingQuestion(
            id: '1',
            question: 'Stop at intersection',
            options: const ['A', 'B', 'C'],
            correctIndex: 1,
          ),
          DrivingQuestion(
            id: '2',
            question: 'Maximum speed on road',
            options: const ['30', '60', '90'],
            correctIndex: 2,
          ),
        ],
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ModuleScreen(
            module: ModuleConfig.general,
            repository: fakeRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop at intersection'), findsOneWidget);
      expect(find.text('Maximum speed on road'), findsOneWidget);

      await tester.enterText(
        find.byKey(const Key('moduleSearchField')),
        'intersection',
      );
      await tester.pumpAndSettle();

      expect(find.text('Stop at intersection'), findsOneWidget);
      expect(find.text('Maximum speed on road'), findsNothing);

      await tester.tap(find.byKey(const Key('questionTile_1')));
      await tester.pumpAndSettle();

      expect(find.text('Correct answer: B'), findsOneWidget);
    },
  );

  testWidgets('Sign module search filters by option text', (
    WidgetTester tester,
  ) async {
    final fakeRepo = _FakeDrivingQuestionRepository({
      ModuleConfig.sign.routeName: [
        DrivingQuestion(
          id: '1',
          question: 'no-bike.png',
          options: const [
            'No bikes allowed',
            'Bike lane only',
            'Stop all vehicles',
          ],
          correctIndex: 0,
        ),
        DrivingQuestion(
          id: '2',
          question: 'animal-cross.png',
          options: const ['Animal crossing', 'Bus lane', 'Parking area'],
          correctIndex: 0,
        ),
      ],
    });

    await tester.pumpWidget(
      MaterialApp(
        home: ModuleScreen(module: ModuleConfig.sign, repository: fakeRepo),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Question 2'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('moduleSearchField')),
      'bike lane',
    );
    await tester.pumpAndSettle();

    expect(find.text('Question 1'), findsOneWidget);
    expect(find.text('Question 2'), findsNothing);

    await tester.tap(find.byKey(const Key('questionTile_1')));
    await tester.pumpAndSettle();

    expect(find.text('Correct answer: No bikes allowed'), findsOneWidget);
  });
}

class _FakeDrivingQuestionRepository extends DrivingQuestionRepository {
  _FakeDrivingQuestionRepository(this._questionsByRoute);

  final Map<String, List<DrivingQuestion>> _questionsByRoute;

  @override
  Future<List<DrivingQuestion>> loadQuestions(ModuleConfig module) async {
    return _questionsByRoute[module.routeName] ?? <DrivingQuestion>[];
  }
}
