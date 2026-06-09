import '../../learning/domain/driving_question.dart';
import '../../learning/domain/module_config.dart';

class ExamQuestion {
  const ExamQuestion({required this.question, required this.module});

  final DrivingQuestion question;
  final ModuleConfig module;

  String get id => '${module.routeName}:${question.id}';
  bool get isPriority => module.routeName == ModuleConfig.priority.routeName;
  bool get isImageQuestion => module.isImageQuestion;
}
