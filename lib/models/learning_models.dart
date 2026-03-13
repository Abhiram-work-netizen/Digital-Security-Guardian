import 'package:flutter/material.dart';

enum StepType { text, scenario, interactiveLab }

class LessonStep {
  final String title;
  final String content;
  final StepType type;
  final String? labType; // e.g., 'password_checker', 'scam_swiper'

  const LessonStep({
    required this.title,
    required this.content,
    this.type = StepType.text,
    this.labType,
  });
}

class LearningLesson {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  final List<LessonStep> steps;

  const LearningLesson({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.steps,
  });
}

class LearningCategory {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color baseColor;
  final List<LearningLesson> lessons;

  const LearningCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.baseColor,
    required this.lessons,
  });

  int get totalLessons => lessons.length;
}
