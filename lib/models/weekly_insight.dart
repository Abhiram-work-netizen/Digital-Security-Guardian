// Weekly Insight Model — aggregated weekly behavioral summary
class WeeklyInsight {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalAlerts;
  final int phishingCount;
  final int scamCount;
  final int riskyLinksCount;
  final int fakeRewardCount;
  final int urgencyCount;
  final String suggestion;
  final List<int> dailyAlertCounts; // 7 entries, Mon–Sun

  WeeklyInsight({
    required this.weekStart,
    required this.weekEnd,
    required this.totalAlerts,
    required this.phishingCount,
    required this.scamCount,
    required this.riskyLinksCount,
    required this.fakeRewardCount,
    required this.urgencyCount,
    required this.suggestion,
    required this.dailyAlertCounts,
  });

  Map<String, dynamic> toMap() => {
        'weekStart': weekStart.toIso8601String(),
        'weekEnd': weekEnd.toIso8601String(),
        'totalAlerts': totalAlerts,
        'phishingCount': phishingCount,
        'scamCount': scamCount,
        'riskyLinksCount': riskyLinksCount,
        'fakeRewardCount': fakeRewardCount,
        'urgencyCount': urgencyCount,
        'suggestion': suggestion,
        'dailyAlertCounts': dailyAlertCounts,
      };

  factory WeeklyInsight.fromMap(Map<String, dynamic> map) => WeeklyInsight(
        weekStart: DateTime.parse(map['weekStart'] as String),
        weekEnd: DateTime.parse(map['weekEnd'] as String),
        totalAlerts: map['totalAlerts'] as int,
        phishingCount: map['phishingCount'] as int,
        scamCount: map['scamCount'] as int,
        riskyLinksCount: map['riskyLinksCount'] as int,
        fakeRewardCount: map['fakeRewardCount'] as int,
        urgencyCount: map['urgencyCount'] as int,
        suggestion: map['suggestion'] as String,
        dailyAlertCounts: List<int>.from(map['dailyAlertCounts'] as List),
      );
}
