import '../models/risk_alert.dart';

/// Smart Notification Risk Analyzer
/// Analyzes notification text patterns locally to detect scams, phishing, and risky content.
/// No notification content is ever stored — analysis is stateless.
class NotificationAnalyzer {
  // Phishing patterns
  static final List<RegExp> _phishingPatterns = [
    RegExp(r'verify\s+(your\s+)?(account|identity|email|payment)', caseSensitive: false),
    RegExp(r'confirm\s+(your\s+)?(account|identity|details|information)', caseSensitive: false),
    RegExp(r'suspended?\s+(your\s+)?account', caseSensitive: false),
    RegExp(r'unauthorized\s+(access|login|activity)', caseSensitive: false),
    RegExp(r'update\s+(your\s+)?(payment|billing|card)\s+(info|information|details)', caseSensitive: false),
    RegExp(r'click\s+here\s+to\s+(verify|confirm|secure)', caseSensitive: false),
    RegExp(r'unusual\s+(sign.in|activity|login)', caseSensitive: false),
  ];

  // Urgency-based scam patterns
  static final List<RegExp> _urgencyPatterns = [
    RegExp(r'act\s+now', caseSensitive: false),
    RegExp(r'immediate(ly)?\s+(action|response)', caseSensitive: false),
    RegExp(r'urgent\s*(:|!|\s)', caseSensitive: false),
    RegExp(r'expires?\s+(in\s+)?\d+\s*(hour|minute|hr|min)', caseSensitive: false),
    RegExp(r'last\s+chance', caseSensitive: false),
    RegExp(r'limited\s+time\s+(offer|only|deal)', caseSensitive: false),
    RegExp(r'don.t\s+miss\s+(out|this)', caseSensitive: false),
    RegExp(r'within\s+\d+\s*(hour|minute|hr|min)', caseSensitive: false),
    RegExp(r'account\s+will\s+be\s+(closed|locked|deleted|suspended)', caseSensitive: false),
  ];

  // Fake reward / prize patterns
  static final List<RegExp> _fakeRewardPatterns = [
    RegExp(r'(you|u).?(ve|have)?\s*(won|been\s+selected)', caseSensitive: false),
    RegExp(r'claim\s+(your\s+)?(prize|reward|gift|bonus)', caseSensitive: false),
    RegExp(r'congratulations?\s*!?\s*(you|winner)', caseSensitive: false),
    RegExp(r'free\s+(gift|iphone|samsung|laptop|prize|money)', caseSensitive: false),
    RegExp(r'lucky\s+(winner|draw|customer)', caseSensitive: false),
    RegExp(r'selected\s+(as\s+)?(a\s+)?winner', caseSensitive: false),
    RegExp(r'\$\s*\d{3,}.*free', caseSensitive: false),
    RegExp(r'cash\s+prize', caseSensitive: false),
  ];

  // Suspicious link patterns
  static final RegExp _urlPattern = RegExp(
    r'https?://[^\s]+|www\.[^\s]+|bit\.ly/[^\s]+|tinyurl\.com/[^\s]+|t\.co/[^\s]+',
    caseSensitive: false,
  );

  // Safe categorization patterns
  static final List<RegExp> _financePatterns = [
    RegExp(r'rs\.?\s*\d+', caseSensitive: false),
    RegExp(r'inr\s*\d+', caseSensitive: false),
    RegExp(r'credited|debited|deducted', caseSensitive: false),
    RegExp(r'payment\s+(received|sent|successful)', caseSensitive: false),
    RegExp(r'bank|upi|gpay|paytm', caseSensitive: false),
    RegExp(r'otp\s+(for|to)?', caseSensitive: false),
  ];

  static final List<RegExp> _socialPatterns = [
    RegExp(r'message(d|s)?\s+(you|from)', caseSensitive: false),
    RegExp(r'replied\s+to', caseSensitive: false),
    RegExp(r'reacted\s+to', caseSensitive: false),
    RegExp(r'mentioned\s+you', caseSensitive: false),
    RegExp(r'missed\s+call', caseSensitive: false),
    RegExp(r'whatsapp|instagram|facebook|snapchat|telegram', caseSensitive: false),
  ];

  static final List<RegExp> _promotionPatterns = [
    RegExp(r'\b(sale|discount|off|offer)\b', caseSensitive: false),
    RegExp(r'\d+%\s+off', caseSensitive: false),
    RegExp(r'flat\s+rs', caseSensitive: false),
    RegExp(r'buy\s+\d+\s+get', caseSensitive: false),
    RegExp(r'cashback', caseSensitive: false),
  ];

  static final List<RegExp> _updatePatterns = [
    RegExp(r'update\s+(available|installed|completed)', caseSensitive: false),
    RegExp(r'download\s+(finished|completed)', caseSensitive: false),
    RegExp(r'successfully\s+(updated|installed)', caseSensitive: false),
    RegExp(r'system\s+update', caseSensitive: false),
  ];

  /// Analyze notification text and return a RiskAlert if risky, or null if safe.
  RiskAlert? analyzeNotification(String title, String body) {
    final fullText = '$title $body';

    // Check phishing patterns
    for (final pattern in _phishingPatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'suspicious request';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.phishing,
          riskScore: 0.85,
          source: AlertSource.notification,
          explanation:
              'Categorized as a Phishing attempt because it uses the phrase "$match". '
              'Attackers often rely on this language to trick you into revealing personal '
              'information by impersonating legitimate services or banks.',
        );
      }
    }

    // Check fake reward patterns
    for (final pattern in _fakeRewardPatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'prize offer';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.fakeReward,
          riskScore: 0.80,
          source: AlertSource.notification,
          explanation:
              'Categorized as a Fake Reward because it contains "$match". '
              'Scammers use the promise of unexpected prizes or cash to lure you '
              'into clicking malicious links. Legitimate companies rarely announce prizes this way.',
        );
      }
    }

    // Check urgency patterns
    for (final pattern in _urgencyPatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'urgent request';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.urgency,
          riskScore: 0.70,
          source: AlertSource.notification,
          explanation:
              'Categorized as an Urgency Scam because it uses the phrase "$match". '
              'This creates artificial panic to pressure you into quick action '
              'so you won\'t have time to think critically about the request.',
        );
      }
    }

    // Check for suspicious links
    if (_urlPattern.hasMatch(fullText)) {
      final match = _urlPattern.firstMatch(fullText);
      if (match != null) {
        final url = match.group(0)!;
        if (_isSuspiciousUrl(url)) {
          return _createAlert(
            title: title,
            body: body,
            riskType: RiskType.suspiciousLink,
            riskScore: 0.75,
            source: AlertSource.notification,
            explanation:
                'Categorized as a Suspicious Link because we detected an unsafe URL pattern: "$url". '
                'Shortened links or direct IP addresses are highly suspicious in unsolicited notifications.',
          );
        }
      }
    }

    // Safe Categorization
    for (final pattern in _financePatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'banking terms';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.finance,
          riskScore: 0.0,
          source: AlertSource.notification,
          explanation: 'Categorized as a Financial Update because we detected the term "$match". '
                       'This is standard behavior for banking, wallet, or payment applications sending transaction alerts.',
        );
      }
    }

    for (final pattern in _socialPatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'communication terms';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.social,
          riskScore: 0.0,
          source: AlertSource.notification,
          explanation: 'Categorized as a Social Notification because we identified the term "$match". '
                       'This typically indicates a message from a friend, group chat, or social media interaction.',
        );
      }
    }

    for (final pattern in _promotionPatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'discount terms';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.promotion,
          riskScore: 0.0,
          source: AlertSource.notification,
          explanation: 'Categorized as a Promotion because the text includes "$match". '
                       'Apps frequently send these low-priority alerts to notify you of sales or new features.',
        );
      }
    }

    for (final pattern in _updatePatterns) {
      if (pattern.hasMatch(fullText)) {
        final match = pattern.firstMatch(fullText)?.group(0) ?? 'system terms';
        return _createAlert(
          title: title,
          body: body,
          riskType: RiskType.update,
          riskScore: 0.0,
          source: AlertSource.notification,
          explanation: 'Categorized as a System Update because it contains "$match". '
                       'This signifies that an application or the operating system is performing background tasks or updates.',
        );
      }
    }

    // Default Fallback
    return _createAlert(
      title: title,
      body: body,
      riskType: RiskType.info,
      riskScore: 0.0,
      source: AlertSource.notification,
      explanation: 'Categorized as General Information. We analyzed the notification from "$title" and '
                   'did not detect any high-risk keywords or known threat vectors. It appears to be a standard app notification.',
    );
  }

  bool _isSuspiciousUrl(String url) {
    final lowerUrl = url.toLowerCase();
    // URL shorteners are suspicious in notifications
    if (lowerUrl.contains('bit.ly') ||
        lowerUrl.contains('tinyurl') ||
        lowerUrl.contains('t.co') ||
        lowerUrl.contains('goo.gl') ||
        lowerUrl.contains('ow.ly')) {
      return true;
    }
    // IP-based URLs
    if (RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}').hasMatch(lowerUrl)) {
      return true;
    }
    return false;
  }

  RiskAlert _createAlert({
    required String title,
    required String body,
    required RiskType riskType,
    required double riskScore,
    required AlertSource source,
    required String explanation,
  }) {
    return RiskAlert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      riskType: riskType,
      riskScore: riskScore,
      timestamp: DateTime.now(),
      source: source,
      explanation: explanation,
    );
  }
}
