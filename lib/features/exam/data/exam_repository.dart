import 'dart:math';

import '../../learning/data/driving_question_repository.dart';
import '../../learning/domain/driving_question.dart';
import '../../learning/domain/module_config.dart';
import '../domain/exam_question.dart';

class ExamRepository {
  ExamRepository({
    DrivingQuestionRepository? questionRepository,
    Random? random,
  }) : _questionRepository = questionRepository ?? DrivingQuestionRepository(),
       _random = random ?? Random();

  final DrivingQuestionRepository _questionRepository;
  final Random _random;

  Future<List<ExamQuestion>> buildExamQuestions() async {
    final general = _pickQuestions(
      await _questionRepository.loadQuestions(ModuleConfig.general),
      20,
      ModuleConfig.general,
    );
    final sign = _pickQuestions(
      await _questionRepository.loadQuestions(ModuleConfig.sign),
      10,
      ModuleConfig.sign,
    );
    final priority = _pickQuestions(
      await _questionRepository.loadQuestions(ModuleConfig.priority),
      5,
      ModuleConfig.priority,
    );
    final technique = _pickQuestions(
      await _questionRepository.loadQuestions(ModuleConfig.technique),
      5,
      ModuleConfig.technique,
    );
    final emergency = _pickQuestions(
      await _questionRepository.loadQuestions(ModuleConfig.emergency),
      5,
      ModuleConfig.emergency,
    );

    return [
      ..._asExamQuestions(general.take(15), ModuleConfig.general),
      ..._asExamQuestions(sign, ModuleConfig.sign),
      ..._asExamQuestions(priority, ModuleConfig.priority),
      ..._asExamQuestions(general.skip(15).take(5), ModuleConfig.general),
      ..._asExamQuestions(technique, ModuleConfig.technique),
      ..._asExamQuestions(emergency, ModuleConfig.emergency),
    ];
  }

  List<DrivingQuestion> _pickQuestions(
    List<DrivingQuestion> questions,
    int count,
    ModuleConfig module,
  ) {
    if (questions.length < count) {
      throw StateError(
        'Not enough ${module.title} questions. Need $count, found '
        '${questions.length}.',
      );
    }

    return (List<DrivingQuestion>.of(
      questions,
    )..shuffle(_random)).take(count).toList();
  }

  Iterable<ExamQuestion> _asExamQuestions(
    Iterable<DrivingQuestion> questions,
    ModuleConfig module,
  ) {
    return questions.map(
      (question) => ExamQuestion(question: question, module: module),
    );
  }
}
