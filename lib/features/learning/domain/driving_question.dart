class DrivingQuestion {
  DrivingQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;

  String get correctAnswer => options[correctIndex];

  factory DrivingQuestion.fromJson(Map<String, dynamic> json) {
    final options = <String>[
      json['0']?.toString() ?? '',
      json['1']?.toString() ?? '',
      json['2']?.toString() ?? '',
    ];
    final parsedIndex = int.tryParse(json['answer']?.toString() ?? '0') ?? 0;
    final safeIndex = parsedIndex.clamp(0, options.length - 1).toInt();

    return DrivingQuestion(
      id: json['id']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: options,
      correctIndex: safeIndex,
    );
  }
}
