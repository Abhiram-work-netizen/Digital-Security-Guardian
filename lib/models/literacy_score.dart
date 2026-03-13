// Literacy Score Model — tracks digital literacy across new 100-point categories
class LiteracyScore {
  final double safeBrowsing;        // 40% weight
  final double threatResponse;      // 20% weight
  final double testPerformance;     // 20% weight
  final double learningCompletion;  // 10% weight
  final double passwordStrength;    // 10% weight
  final DateTime lastUpdated;

  LiteracyScore({
    required this.safeBrowsing,
    required this.threatResponse,
    required this.testPerformance,
    required this.learningCompletion,
    required this.passwordStrength,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  double get overallScore =>
      (safeBrowsing * 0.4) +
      (threatResponse * 0.2) +
      (testPerformance * 0.2) +
      (learningCompletion * 0.1) +
      (passwordStrength * 0.1);

  String get grade {
    final s = overallScore;
    if (s >= 80) return 'SAFE';
    if (s >= 60) return 'MODERATE';
    return 'AT RISK';
  }

  Map<String, dynamic> toMap() => {
        'safeBrowsing': safeBrowsing,
        'threatResponse': threatResponse,
        'testPerformance': testPerformance,
        'learningCompletion': learningCompletion,
        'passwordStrength': passwordStrength,
        'lastUpdated': lastUpdated.toIso8601String(),
      };

  factory LiteracyScore.fromMap(Map<String, dynamic> map) => LiteracyScore(
        safeBrowsing: (map['safeBrowsing'] as num?)?.toDouble() ?? 60,
        threatResponse: (map['threatResponse'] as num?)?.toDouble() ?? 60,
        testPerformance: (map['testPerformance'] as num?)?.toDouble() ?? 60,
        learningCompletion: (map['learningCompletion'] as num?)?.toDouble() ?? 60,
        passwordStrength: (map['passwordStrength'] as num?)?.toDouble() ?? 60,
        lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated'] as String) : DateTime.now(),
      );

  factory LiteracyScore.initial() => LiteracyScore(
        safeBrowsing: 65, // Start users at ~60-70 to encourage improvement
        threatResponse: 65,
        testPerformance: 65,
        learningCompletion: 65,
        passwordStrength: 65,
      );
}
