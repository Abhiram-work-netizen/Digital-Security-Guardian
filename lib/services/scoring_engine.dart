import '../models/literacy_score.dart';
import '../models/risk_alert.dart';
import '../providers/gamification_provider.dart';
import '../providers/tests_provider.dart';

/// Scoring Engine — calculates Digital Safety Score from behavioral data.
/// System based on a 100-point 5-category algorithm.
class ScoringEngine {
  /// Compute literacy score from alert history, gamification, and test statistics
  LiteracyScore calculateScore(List<RiskAlert> alerts, GamificationProvider gamification, TestsProvider tests) {
    if (alerts.isEmpty && tests.completedTests.isEmpty) {
      return LiteracyScore.initial();
    }

    double safeBrowsing = 65.0; // Base 65
    double threatResponse = 65.0; // Base 65

    int totalActionableAlerts = 0;
    int dismissedAlerts = 0;
    int highRiskAlerts = 0;

    for (final alert in alerts) {
      if (alert.riskScore > 0) {
        totalActionableAlerts++;
        if (alert.dismissed) {
          dismissedAlerts++;
        } else {
          // Unhandled alerts impact safe browsing
          if (alert.riskScore >= 70) {
            highRiskAlerts++;
          }
        }
      }
    }

    // Threat Response (0-100): Percentage of actionable alerts dismissed/handled
    if (totalActionableAlerts > 0) {
      threatResponse = (dismissedAlerts / totalActionableAlerts) * 100.0;
    }

    // Safe Browsing (0-100): Degrades with unhandled high-risk alerts
    safeBrowsing = 100.0 - (highRiskAlerts * 15.0);
    safeBrowsing = _clampScore(safeBrowsing);

    double learningCompletion = 65.0;
    try {
      final scholar = gamification.achievements.firstWhere((a) => a.id == 'security_scholar');
      learningCompletion = 65.0 + ((scholar.currentProgress / scholar.requiredProgress).clamp(0.0, 1.0) * 35.0);
    } catch (e) {
      // Fallback
    }

    // Test Performance (0-100): based on real accuracy
    double testPerformance = 65.0;
    if (tests.completedTests.isNotEmpty) {
       testPerformance = tests.overallAccuracy * 100.0;
    }

    return LiteracyScore(
      safeBrowsing: safeBrowsing,
      threatResponse: threatResponse,
      testPerformance: _clampScore(testPerformance),
      learningCompletion: _clampScore(learningCompletion),
      passwordStrength: 65.0, // Default until password check is implemented
    );
  }

  double _clampScore(double score) => score.clamp(0.0, 100.0);
}
