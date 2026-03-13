// Risk Alert Model — represents a single detected risky notification or link
class RiskAlert {
  final String id;
  final String title;
  final String body;
  final RiskType riskType;
  final double riskScore; // 0.0 – 1.0
  final DateTime timestamp;
  final AlertSource source;
  final String explanation;
  bool dismissed;

  RiskAlert({
    required this.id,
    required this.title,
    required this.body,
    required this.riskType,
    required this.riskScore,
    required this.timestamp,
    required this.source,
    required this.explanation,
    this.dismissed = false,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'body': body,
        'riskType': riskType.index,
        'riskScore': riskScore,
        'timestamp': timestamp.toIso8601String(),
        'source': source.index,
        'explanation': explanation,
        'dismissed': dismissed,
      };

  factory RiskAlert.fromMap(Map<String, dynamic> map) => RiskAlert(
        id: map['id'] as String,
        title: map['title'] as String,
        body: map['body'] as String,
        riskType: RiskType.values[map['riskType'] as int],
        riskScore: (map['riskScore'] as num).toDouble(),
        timestamp: DateTime.parse(map['timestamp'] as String),
        source: AlertSource.values[map['source'] as int],
        explanation: map['explanation'] as String,
        dismissed: map['dismissed'] as bool? ?? false,
      );
}

enum RiskType {
  phishing,
  scam,
  fakeReward,
  urgency,
  suspiciousLink,
  typosquatting,
  finance,
  social,
  promotion,
  update,
  info,
  unknown,
}

enum AlertSource {
  notification,
  clipboard,
  manualCheck,
}

extension RiskTypeExtension on RiskType {
  String get label {
    switch (this) {
      case RiskType.phishing:
        return 'Phishing';
      case RiskType.scam:
        return 'Scam';
      case RiskType.fakeReward:
        return 'Fake Reward';
      case RiskType.urgency:
        return 'Urgency Scam';
      case RiskType.suspiciousLink:
        return 'Suspicious Link';
      case RiskType.typosquatting:
        return 'Typosquatting';
      case RiskType.finance:
        return 'Financial Info';
      case RiskType.social:
        return 'Social Message';
      case RiskType.promotion:
        return 'Promotion';
      case RiskType.update:
        return 'System Update';
      case RiskType.info:
        return 'Information';
      case RiskType.unknown:
        return 'Unknown Risk';
    }
  }

  String get icon {
    switch (this) {
      case RiskType.phishing:
        return '🎣';
      case RiskType.scam:
        return '⚠️';
      case RiskType.fakeReward:
        return '🎁';
      case RiskType.urgency:
        return '⏰';
      case RiskType.suspiciousLink:
        return '🔗';
      case RiskType.typosquatting:
        return '🔤';
      case RiskType.finance:
        return '💰';
      case RiskType.social:
        return '💬';
      case RiskType.promotion:
        return '🛍️';
      case RiskType.update:
        return '🔄';
      case RiskType.info:
        return 'ℹ️';
      case RiskType.unknown:
        return '❓';
    }
  }
}

