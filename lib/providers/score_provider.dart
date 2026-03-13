import 'package:flutter/material.dart';
import '../models/literacy_score.dart';
import '../models/risk_alert.dart';
import '../services/scoring_engine.dart';
import '../data/local_storage_service.dart';
import '../providers/gamification_provider.dart';
import '../providers/tests_provider.dart';

/// Score Provider — wraps scoring engine and exposes current literacy score.
class ScoreProvider extends ChangeNotifier {
  final ScoringEngine _engine = ScoringEngine();
  final LocalStorageService _storage;
  LiteracyScore _score = LiteracyScore.initial();

  ScoreProvider(this._storage);

  LiteracyScore get score => _score;

  Future<void> loadScore() async {
    _score = await _storage.getScore();
    notifyListeners();
  }

  Future<void> recalculate(List<RiskAlert> alerts, GamificationProvider gamification, TestsProvider tests) async {
    _score = _engine.calculateScore(alerts, gamification, tests);
    await _storage.saveScore(_score);
    notifyListeners();
  }
}
