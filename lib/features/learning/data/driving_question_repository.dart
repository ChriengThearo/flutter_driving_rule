import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/driving_question.dart';
import '../domain/module_config.dart';

class DrivingQuestionRepository {
  DrivingQuestionRepository({AssetBundle? assetBundle})
    : _assetBundle = assetBundle ?? rootBundle;

  final AssetBundle _assetBundle;

  Future<List<DrivingQuestion>> loadQuestions(ModuleConfig module) async {
    final rawJson = await _assetBundle.loadString(module.jsonPath);
    final decoded = jsonDecode(rawJson) as List<dynamic>;
    return decoded
        .map((item) => DrivingQuestion.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
