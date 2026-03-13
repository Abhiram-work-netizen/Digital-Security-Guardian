import 'package:flutter/material.dart';

enum TestDifficulty { beginner, intermediate, advanced }
enum QuestionType { text, visual, trueFalse }

class QuizQuestion {
  final String id;
  final String scenario;
  final String? visualExampleAsset; // For fake vs real UI images
  final String? textExample; // For raw SMS/Email text
  final QuestionType type;
  final List<String> options;
  final int correctAnswerIndex;
  final String explanation;
  final String relatedLessonId; // Deep link to learning hub

  const QuizQuestion({
    required this.id,
    required this.scenario,
    this.visualExampleAsset,
    this.textExample,
    required this.type,
    required this.options,
    required this.correctAnswerIndex,
    required this.explanation,
    required this.relatedLessonId,
  });
}

class SecurityTest {
  final String id;
  final String title;
  final String description;
  final TestDifficulty difficulty;
  final IconData icon;
  final List<QuizQuestion> questions;

  const SecurityTest({
    required this.id,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.icon,
    required this.questions,
  });
}

class TestResult {
  final String testId;
  final double scorePercentage; // 0.0 to 1.0
  final DateTime dateCompleted;
  
  TestResult({
    required this.testId,
    required this.scorePercentage,
    required this.dateCompleted,
  });

  Map<String, dynamic> toJson() => {
    'testId': testId,
    'scorePercentage': scorePercentage,
    'dateCompleted': dateCompleted.toIso8601String(),
  };

  factory TestResult.fromJson(Map<String, dynamic> json) => TestResult(
    testId: json['testId'],
    scorePercentage: json['scorePercentage'],
    dateCompleted: DateTime.parse(json['dateCompleted']),
  );
}
