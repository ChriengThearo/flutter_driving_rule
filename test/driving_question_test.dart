import 'package:driving_rule/features/learning/domain/driving_question.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DrivingQuestion parses JSON fields and resolves correct answer', () {
    final question = DrivingQuestion.fromJson({
      'id': '42',
      'question': 'What should you do?',
      '0': 'Speed up',
      '1': 'Slow down',
      '2': 'Ignore',
      'answer': '1',
    });

    expect(question.id, '42');
    expect(question.question, 'What should you do?');
    expect(question.options, ['Speed up', 'Slow down', 'Ignore']);
    expect(question.correctIndex, 1);
    expect(question.correctAnswer, 'Slow down');
  });

  test('DrivingQuestion clamps out-of-range answer index', () {
    final question = DrivingQuestion.fromJson({
      'id': '9',
      'question': 'Pick one',
      '0': 'A',
      '1': 'B',
      '2': 'C',
      'answer': '9',
    });

    expect(question.correctIndex, 2);
    expect(question.correctAnswer, 'C');
  });
}
