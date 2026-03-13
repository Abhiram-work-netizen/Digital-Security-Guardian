import '../models/risk_alert.dart';
import '../models/weekly_insight.dart';

/// Insight Generator — aggregates the last 7 days of alerts into weekly insights.
class InsightGenerator {
  WeeklyInsight generateWeeklyInsight(List<RiskAlert> allAlerts) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1)); // Monday
    final weekEnd = weekStart.add(const Duration(days: 6)); // Sunday

    // Filter alerts from this week
    final weekAlerts = allAlerts.where((a) {
      return a.timestamp.isAfter(weekStart.subtract(const Duration(days: 1))) &&
          a.timestamp.isBefore(weekEnd.add(const Duration(days: 1)));
    }).toList();

    // Count by type
    int phishing = 0, scam = 0, riskyLinks = 0, fakeReward = 0, urgency = 0;
    for (final alert in weekAlerts) {
      switch (alert.riskType) {
        case RiskType.phishing:
          phishing++;
          break;
        case RiskType.scam:
          scam++;
          break;
        case RiskType.fakeReward:
          fakeReward++;
          break;
        case RiskType.urgency:
          urgency++;
          break;
        case RiskType.suspiciousLink:
        case RiskType.typosquatting:
          riskyLinks++;
          break;
        case RiskType.finance:
        case RiskType.social:
        case RiskType.promotion:
        case RiskType.update:
        case RiskType.info:
        case RiskType.unknown:
          break;
      }
    }

    // Compute daily counts
    final dailyCounts = List<int>.filled(7, 0);
    for (final alert in weekAlerts) {
      final day = alert.timestamp.weekday - 1; // 0=Mon, 6=Sun
      if (day >= 0 && day < 7) {
        dailyCounts[day]++;
      }
    }

    // Generate contextual suggestion
    final suggestion = _generateSuggestion(
      total: weekAlerts.length,
      phishing: phishing,
      scam: scam,
      fakeReward: fakeReward,
      urgency: urgency,
      riskyLinks: riskyLinks,
    );

    return WeeklyInsight(
      weekStart: weekStart,
      weekEnd: weekEnd,
      totalAlerts: weekAlerts.length,
      phishingCount: phishing,
      scamCount: scam,
      riskyLinksCount: riskyLinks,
      fakeRewardCount: fakeReward,
      urgencyCount: urgency,
      suggestion: suggestion,
      dailyAlertCounts: dailyCounts,
    );
  }

  String _generateSuggestion({
    required int total,
    required int phishing,
    required int scam,
    required int fakeReward,
    required int urgency,
    required int riskyLinks,
  }) {
    if (total == 0) {
      return 'Great week! No suspicious activity detected. Stay vigilant and keep practicing safe digital habits.';
    }

    final parts = <String>[];

    if (phishing > 0) {
      parts.add(
        'You received $phishing phishing-style notification${phishing > 1 ? 's' : ''}. '
        'Never enter personal info from unsolicited messages.',
      );
    }

    if (scam + fakeReward > 0) {
      parts.add(
        'You encountered ${scam + fakeReward} scam/fake reward message${(scam + fakeReward) > 1 ? 's' : ''}. '
        'Remember, real prizes don\'t require you to click a link.',
      );
    }

    if (urgency > 0) {
      parts.add(
        '$urgency message${urgency > 1 ? 's' : ''} used urgency tactics. '
        'Slow down — legitimate services don\'t threaten immediate action.',
      );
    }

    if (riskyLinks > 0) {
      parts.add(
        '$riskyLinks suspicious link${riskyLinks > 1 ? 's' : ''} detected. '
        'Always verify URLs before clicking.',
      );
    }

    return parts.join(' ');
  }
}
