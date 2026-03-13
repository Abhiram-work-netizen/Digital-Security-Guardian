import 'package:flutter/material.dart';
import '../models/risk_alert.dart';
import '../models/weekly_insight.dart';
import '../services/insight_generator.dart';

/// Insight Provider — generates and caches weekly behavioral insights.
class InsightProvider extends ChangeNotifier {
  final InsightGenerator _generator = InsightGenerator();
  WeeklyInsight? _weeklyInsight;

  WeeklyInsight? get weeklyInsight => _weeklyInsight;

  void generateInsight(List<RiskAlert> alerts) {
    _weeklyInsight = _generator.generateWeeklyInsight(alerts);
    notifyListeners();
  }
}
