import '../models/safety_tip.dart';

/// Static repository of digital safety tips for micro-learning.
class TipsRepository {
  static const List<SafetyTip> allTips = [
    SafetyTip(
      id: 'tip_01',
      title: 'Phishing Creates Urgency',
      description:
          'Phishing messages often create a false sense of urgency to force quick action. '
          'Always pause before clicking links in urgent-sounding messages.',
      category: TipCategory.phishing,
      iconName: 'phishing',
    ),
    SafetyTip(
      id: 'tip_02',
      title: 'Check the Sender',
      description:
          'Before responding to any message, verify the sender\'s email or phone number. '
          'Scammers often spoof legitimate contacts with slight variations.',
      category: TipCategory.phishing,
      iconName: 'person_search',
    ),
    SafetyTip(
      id: 'tip_03',
      title: 'Look for HTTPS',
      description:
          'Legitimate websites use HTTPS for secure connections. While HTTPS alone doesn\'t guarantee safety, '
          'its absence on login pages is a strong red flag.',
      category: TipCategory.safeLinks,
      iconName: 'lock',
    ),
    SafetyTip(
      id: 'tip_04',
      title: 'Hover Before You Click',
      description:
          'On desktop, hover over links to preview the actual URL before clicking. '
          'On mobile, long-press links to see where they really point.',
      category: TipCategory.safeLinks,
      iconName: 'touch_app',
    ),
    SafetyTip(
      id: 'tip_05',
      title: 'Use Unique Passwords',
      description:
          'Never reuse passwords across different accounts. If one service is breached, '
          'all accounts using the same password become vulnerable.',
      category: TipCategory.passwords,
      iconName: 'key',
    ),
    SafetyTip(
      id: 'tip_06',
      title: 'Enable Two-Factor Authentication',
      description:
          'Add an extra security layer to your important accounts. Even if your password is stolen, '
          '2FA prevents unauthorized access.',
      category: TipCategory.passwords,
      iconName: 'security',
    ),
    SafetyTip(
      id: 'tip_07',
      title: 'Review App Permissions',
      description:
          'Regularly check what permissions your apps have. Remove access to camera, microphone, '
          'and location for apps that don\'t need them.',
      category: TipCategory.privacy,
      iconName: 'app_settings_alt',
    ),
    SafetyTip(
      id: 'tip_08',
      title: 'Be Wary of Free Wi-Fi',
      description:
          'Public Wi-Fi networks can be monitored by attackers. Avoid accessing sensitive accounts '
          'on public networks, or use a VPN.',
      category: TipCategory.privacy,
      iconName: 'wifi_tethering_error',
    ),
    SafetyTip(
      id: 'tip_09',
      title: 'Social Engineering Tactics',
      description:
          'Attackers may impersonate friends, colleagues, or authority figures to manipulate you. '
          'Always verify unusual requests through a separate communication channel.',
      category: TipCategory.socialEngineering,
      iconName: 'psychology',
    ),
    SafetyTip(
      id: 'tip_10',
      title: 'Too Good To Be True',
      description:
          'If an offer seems too good to be true, it probably is. Free iPhones, lottery wins, '
          'and miracle cures are classic scam lures.',
      category: TipCategory.socialEngineering,
      iconName: 'card_giftcard',
    ),
    SafetyTip(
      id: 'tip_11',
      title: 'Check URL Spelling Carefully',
      description:
          'Scammers register domains that look like real ones (e.g., amaz0n.com). '
          'Always double-check the spelling of URLs before entering any information.',
      category: TipCategory.safeLinks,
      iconName: 'spellcheck',
    ),
    SafetyTip(
      id: 'tip_12',
      title: 'Keep Software Updated',
      description:
          'Software updates often fix security vulnerabilities. Enable auto-updates for your '
          'operating system and apps to stay protected.',
      category: TipCategory.general,
      iconName: 'system_update',
    ),
    SafetyTip(
      id: 'tip_13',
      title: 'Beware of URL Shorteners',
      description:
          'Shortened URLs (bit.ly, tinyurl) hide the actual destination. '
          'Use a URL expander service to preview where they lead.',
      category: TipCategory.safeLinks,
      iconName: 'link_off',
    ),
    SafetyTip(
      id: 'tip_14',
      title: 'Limit Personal Info Online',
      description:
          'The less personal information you share online, the harder it is for scammers to target you. '
          'Be cautious about what you post on social media.',
      category: TipCategory.privacy,
      iconName: 'visibility_off',
    ),
    SafetyTip(
      id: 'tip_15',
      title: 'Use a Password Manager',
      description:
          'Password managers generate and store strong, unique passwords for every account. '
          'This eliminates the need to remember complex passwords.',
      category: TipCategory.passwords,
      iconName: 'password',
    ),
    SafetyTip(
      id: 'tip_16',
      title: 'Verify Before Sharing',
      description:
          'Before sharing news or information online, verify it through trusted sources. '
          'Misinformation spreads quickly through social media.',
      category: TipCategory.general,
      iconName: 'fact_check',
    ),
    SafetyTip(
      id: 'tip_17',
      title: 'Backup Your Data',
      description:
          'Regularly back up important files. In case of ransomware or device failure, '
          'backups ensure you don\'t lose critical data.',
      category: TipCategory.general,
      iconName: 'backup',
    ),
    SafetyTip(
      id: 'tip_18',
      title: 'Recognize Emotional Manipulation',
      description:
          'Scammers use fear, excitement, and urgency to bypass your critical thinking. '
          'If a message triggers a strong emotion, take a moment before acting.',
      category: TipCategory.socialEngineering,
      iconName: 'mood',
    ),
    SafetyTip(
      id: 'tip_19',
      title: 'Check Reviews Before Installing',
      description:
          'Before installing apps, check reviews and ratings. Look for red flags like '
          'excessive permission requests or suspicious developer names.',
      category: TipCategory.general,
      iconName: 'rate_review',
    ),
    SafetyTip(
      id: 'tip_20',
      title: 'Secure Your Lock Screen',
      description:
          'Use a strong PIN, password, or biometric lock on your devices. '
          'An unlocked phone is an open invitation for data theft.',
      category: TipCategory.privacy,
      iconName: 'screen_lock_portrait',
    ),
  ];

  /// Get tips for a specific category
  static List<SafetyTip> getByCategory(TipCategory category) {
    return allTips.where((tip) => tip.category == category).toList();
  }

  /// Get a contextual tip based on risk type
  static SafetyTip? getContextualTip(String riskTypeLabel) {
    final lower = riskTypeLabel.toLowerCase();
    if (lower.contains('phishing')) {
      return allTips.firstWhere((t) => t.category == TipCategory.phishing);
    }
    if (lower.contains('link') || lower.contains('typosquat')) {
      return allTips.firstWhere((t) => t.category == TipCategory.safeLinks);
    }
    if (lower.contains('scam') || lower.contains('reward')) {
      return allTips.firstWhere((t) => t.category == TipCategory.socialEngineering);
    }
    return allTips.first;
  }
}
