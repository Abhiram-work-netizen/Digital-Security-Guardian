/// Link Safety Checker
/// Inspects URLs for suspicious patterns: typosquatting, obfuscation, risky TLDs, and more.
class LinkChecker {
  // Well-known brands commonly targeted by typosquatting
  static const Map<String, List<String>> _brandVariants = {
    'amazon': ['amaz0n', 'amazom', 'amazn', 'amaazon', 'amazon1', 'amazonn'],
    'google': ['g00gle', 'googl', 'gooogle', 'googie', 'gogle'],
    'facebook': ['faceb00k', 'facebok', 'facbook', 'faceebook', 'faceboook'],
    'apple': ['app1e', 'appie', 'aple', 'applle'],
    'microsoft': ['micr0soft', 'mircosoft', 'microsft', 'microsooft'],
    'paypal': ['paypa1', 'paypall', 'paypai', 'paypl'],
    'netflix': ['netf1ix', 'netfilx', 'nettflix', 'netflixx'],
    'instagram': ['1nstagram', 'instagran', 'insatgram', 'instagarm'],
    'whatsapp': ['whatsap', 'watsapp', 'whatsappp', 'whatssapp'],
    'twitter': ['twiter', 'tw1tter', 'twiiter', 'twítter'],
    'linkedin': ['linkedn', 'l1nkedin', 'linkdin', 'linkedinn'],
    'bank': ['bannk', 'baank', 'b4nk'],
  };

  // Suspicious TLDs
  static const List<String> _suspiciousTlds = [
    '.xyz', '.top', '.club', '.work', '.buzz', '.gq', '.ml',
    '.cf', '.tk', '.ga', '.pw', '.cc', '.icu', '.cam',
    '.click', '.link', '.info', '.bid', '.win', '.loan',
  ];

  /// Full link safety check
  LinkCheckResult checkLink(String url) {
    String normalizedUrl = url.trim();
    if (!normalizedUrl.startsWith('http://') && !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }

    Uri? uri;
    try {
      uri = Uri.parse(normalizedUrl);
    } catch (_) {
      return LinkCheckResult(
        url: url,
        isSafe: false,
        riskLevel: RiskLevel.high,
        warnings: ['URL could not be parsed — likely malformed or obfuscated.'],
        explanation: 'This URL appears to be malformed, which is a common obfuscation technique.',
      );
    }

    final warnings = <String>[];
    final host = uri.host.toLowerCase();

    // 1. IP-based URL check
    if (RegExp(r'^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$').hasMatch(host)) {
      warnings.add('URL uses an IP address instead of a domain name.');
    }

    // 2. Typosquatting check
    for (final entry in _brandVariants.entries) {
      for (final variant in entry.value) {
        if (host.contains(variant)) {
          warnings.add(
            'Possible typosquatting: "$variant" looks like "${entry.key}" but is misspelled.',
          );
        }
      }
    }

    // 3. Suspicious TLD check
    for (final tld in _suspiciousTlds) {
      if (host.endsWith(tld)) {
        warnings.add('Uses suspicious top-level domain "$tld".');
      }
    }

    // 4. Excessive subdomains
    final parts = host.split('.');
    if (parts.length > 4) {
      warnings.add('Excessive subdomains detected — a common phishing technique.');
    }

    // 5. URL shortener
    if (_isUrlShortener(host)) {
      warnings.add('URL shortener detected — the actual destination is hidden.');
    }

    // 6. Suspicious path keywords
    final path = uri.path.toLowerCase();
    final suspiciousPathKeywords = [
      'login', 'signin', 'verify', 'confirm', 'account', 'secure',
      'update', 'banking', 'password', 'credential',
    ];
    for (final keyword in suspiciousPathKeywords) {
      if (path.contains(keyword)) {
        warnings.add('URL path contains suspicious keyword "$keyword".');
        break;
      }
    }

    // 7. Unusual port
    if (uri.port != 80 && uri.port != 443 && uri.hasPort) {
      warnings.add('Uses non-standard port ${uri.port}.');
    }

    // 8. @ symbol in URL (credential phishing)
    if (normalizedUrl.contains('@')) {
      warnings.add('Contains "@" character — may be attempting URL credential injection.');
    }

    // Determine overall risk
    final riskLevel = warnings.isEmpty
        ? RiskLevel.safe
        : warnings.length <= 1
            ? RiskLevel.low
            : warnings.length <= 3
                ? RiskLevel.medium
                : RiskLevel.high;

    return LinkCheckResult(
      url: url,
      isSafe: warnings.isEmpty,
      riskLevel: riskLevel,
      warnings: warnings,
      explanation: warnings.isEmpty
          ? 'No obvious risks detected. Always verify you trust the source.'
          : 'This URL has ${warnings.length} risk indicator${warnings.length > 1 ? 's' : ''}. '
              'Exercise caution before clicking.',
    );
  }

  bool _isUrlShortener(String host) {
    const shorteners = [
      'bit.ly', 'tinyurl.com', 't.co', 'goo.gl', 'ow.ly',
      'is.gd', 'buff.ly', 'rebrand.ly', 'cutt.ly', 'short.io',
    ];
    return shorteners.any((s) => host.contains(s));
  }
}

class LinkCheckResult {
  final String url;
  final bool isSafe;
  final RiskLevel riskLevel;
  final List<String> warnings;
  final String explanation;

  const LinkCheckResult({
    required this.url,
    required this.isSafe,
    required this.riskLevel,
    required this.warnings,
    required this.explanation,
  });
}

enum RiskLevel { safe, low, medium, high }

extension RiskLevelExtension on RiskLevel {
  String get label {
    switch (this) {
      case RiskLevel.safe:
        return 'Safe';
      case RiskLevel.low:
        return 'Low Risk';
      case RiskLevel.medium:
        return 'Medium Risk';
      case RiskLevel.high:
        return 'High Risk';
    }
  }
}
