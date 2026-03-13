// Safety Tip Model — micro-learning content
class SafetyTip {
  final String id;
  final String title;
  final String description;
  final TipCategory category;
  final String iconName;

  const SafetyTip({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
  });
}

enum TipCategory {
  phishing,
  passwords,
  privacy,
  socialEngineering,
  safeLinks,
  general,
}

extension TipCategoryExtension on TipCategory {
  String get label {
    switch (this) {
      case TipCategory.phishing:
        return 'Phishing';
      case TipCategory.passwords:
        return 'Passwords';
      case TipCategory.privacy:
        return 'Privacy';
      case TipCategory.socialEngineering:
        return 'Social Engineering';
      case TipCategory.safeLinks:
        return 'Safe Links';
      case TipCategory.general:
        return 'General Safety';
    }
  }
}
