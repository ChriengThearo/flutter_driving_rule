import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../learning/domain/module_config.dart';
import '../data/exam_repository.dart';
import '../domain/exam_question.dart';

class ExamScreen extends StatefulWidget {
  const ExamScreen({this.repository, super.key});

  static const routeName = '/exam';

  final ExamRepository? repository;

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  static const _examDuration = Duration(minutes: 45);
  static const _passingScore = 38;

  late final ExamRepository _repository;
  late final Future<List<ExamQuestion>> _examFuture;
  Timer? _timer;
  Duration _remaining = _examDuration;
  List<int?> _answers = const [];
  int _currentIndex = 0;
  _ExamResult? _result;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ExamRepository();
    _examFuture = _repository.buildExamQuestions()
      ..then((questions) {
        if (!mounted || _result != null) {
          return;
        }
        setState(() => _answers = List<int?>.filled(questions.length, null));
        _startTimer();
      }, onError: (_) {});
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = _result;
    if (result != null) {
      return _ResultView(
        result: result,
        onRetake: _restartExam,
        onHome: () => Navigator.pop(context),
      );
    }

    return FutureBuilder<List<ExamQuestion>>(
      future: _examFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exam')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exam')),
            body: Center(child: Text('Failed to load exam: ${snapshot.error}')),
          );
        }

        final questions = snapshot.data ?? <ExamQuestion>[];
        if (questions.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Exam')),
            body: const Center(child: Text('No exam questions available.')),
          );
        }

        return _QuestionView(
          question: questions[_currentIndex],
          questionNumber: _currentIndex + 1,
          totalQuestions: questions.length,
          selectedAnswer: _answers[_currentIndex],
          remaining: _remaining,
          canGoBack: _currentIndex > 0,
          isLastQuestion: _currentIndex == questions.length - 1,
          onAnswerSelected: (answer) {
            setState(() => _answers[_currentIndex] = answer);
          },
          onBack: () {
            if (_currentIndex == 0) {
              return;
            }
            setState(() => _currentIndex--);
          },
          onNext: () => _confirmAnswer(questions),
        );
      },
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _result != null) {
        return;
      }

      if (_remaining <= const Duration(seconds: 1)) {
        _finishExam(timedOut: true);
        return;
      }

      setState(() => _remaining -= const Duration(seconds: 1));
    });
  }

  void _confirmAnswer(List<ExamQuestion> questions) {
    final currentQuestion = questions[_currentIndex];
    final selectedAnswer = _answers[_currentIndex];
    if (selectedAnswer == null) {
      return;
    }

    if (currentQuestion.isPriority &&
        selectedAnswer != currentQuestion.question.correctIndex) {
      _finishExam(priorityFailed: true);
      return;
    }

    if (_currentIndex == questions.length - 1) {
      _finishExam();
      return;
    }

    setState(() => _currentIndex++);
  }

  void _finishExam({bool timedOut = false, bool priorityFailed = false}) {
    _timer?.cancel();
    _examFuture.then((questions) {
      if (!mounted || _result != null) {
        return;
      }

      final score = _calculateScore(questions);
      setState(() {
        _result = _ExamResult(
          score: score,
          total: questions.length,
          timedOut: timedOut,
          priorityFailed: priorityFailed,
          passed: !priorityFailed && score >= _passingScore,
        );
      });
    });
  }

  int _calculateScore(List<ExamQuestion> questions) {
    var score = 0;
    for (var index = 0; index < questions.length; index++) {
      if (_answers[index] == questions[index].question.correctIndex) {
        score++;
      }
    }
    return score;
  }

  void _restartExam() {
    Navigator.pushReplacementNamed(context, ExamScreen.routeName);
  }
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({
    required this.question,
    required this.questionNumber,
    required this.totalQuestions,
    required this.selectedAnswer,
    required this.remaining,
    required this.canGoBack,
    required this.isLastQuestion,
    required this.onAnswerSelected,
    required this.onBack,
    required this.onNext,
  });

  final ExamQuestion question;
  final int questionNumber;
  final int totalQuestions;
  final int? selectedAnswer;
  final Duration remaining;
  final bool canGoBack;
  final bool isLastQuestion;
  final ValueChanged<int> onAnswerSelected;
  final VoidCallback onBack;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _formatDuration(remaining),
                key: const Key('examTimerText'),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _InfoChip(
                    label: 'Question $questionNumber/$totalQuestions',
                    icon: Icons.quiz_outlined,
                  ),
                  const SizedBox(width: 8),
                  _InfoChip(
                    label: _moduleLabel(question.module),
                    icon: question.isPriority
                        ? Icons.priority_high
                        : Icons.directions_car_outlined,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  children: [
                    if (question.isImageQuestion) ...[
                      Center(
                        child: Image.asset(
                          '${question.module.imageBasePath}'
                          '${question.question.question}',
                          height: 220,
                          fit: BoxFit.contain,
                          errorBuilder: (_, _, _) =>
                              const Text('Image not found'),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else ...[
                      Text(
                        question.question.question,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    RadioGroup<int>(
                      groupValue: selectedAnswer,
                      onChanged: (value) {
                        if (value != null) {
                          onAnswerSelected(value);
                        }
                      },
                      child: Column(
                        children: List.generate(
                          question.question.options.length,
                          (index) {
                            return Card(
                              child: RadioListTile<int>(
                                key: Key('examAnswer_$index'),
                                value: index,
                                selected: selectedAnswer == index,
                                title: Text(question.question.options[index]),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('examBackButton'),
                      onPressed: canGoBack ? onBack : null,
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      key: const Key('examNextButton'),
                      onPressed: selectedAnswer == null ? null : onNext,
                      icon: Icon(
                        isLastQuestion
                            ? Icons.flag_outlined
                            : Icons.navigate_next,
                      ),
                      label: Text(isLastQuestion ? 'Finish exam' : 'Next'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _moduleLabel(ModuleConfig module) {
    if (module.routeName == ModuleConfig.technique.routeName) {
      return 'Technical';
    }
    return module.title;
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  const _ResultView({
    required this.result,
    required this.onRetake,
    required this.onHome,
  });

  final _ExamResult result;
  final VoidCallback onRetake;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) {
    final title = result.passed ? 'Passed' : 'Failed';
    final color = result.passed ? Colors.green : AppColors.danger;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                result.passed
                    ? Icons.check_circle_outline
                    : Icons.cancel_outlined,
                size: 80,
                color: color,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                key: const Key('examResultTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: ${result.score}/${result.total}',
                key: const Key('examResultScore'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                result.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: onRetake,
                icon: const Icon(Icons.refresh),
                label: const Text('Retake exam'),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onHome,
                icon: const Icon(Icons.home_outlined),
                label: const Text('Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExamResult {
  const _ExamResult({
    required this.score,
    required this.total,
    required this.timedOut,
    required this.priorityFailed,
    required this.passed,
  });

  final int score;
  final int total;
  final bool timedOut;
  final bool priorityFailed;
  final bool passed;

  String get message {
    if (priorityFailed) {
      return 'A wrong Priority answer causes an automatic fail.';
    }
    if (timedOut) {
      return 'Time is up. Passing requires at least 38 correct answers.';
    }
    return 'Passing requires at least 38 correct answers.';
  }
}
