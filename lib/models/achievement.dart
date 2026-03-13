/// Represents a gamification achievement badge.
class Achievement {
  final String id;
  final String name;
  final String description;
  final String iconEmoji;
  final int requiredProgress;
  int currentProgress;
  DateTime? unlockedAt;

  bool get isUnlocked => currentProgress >= requiredProgress;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconEmoji,
    required this.requiredProgress,
    this.currentProgress = 0,
    this.unlockedAt,
  });

  void addProgress(int amount) {
    if (isUnlocked) return;
    currentProgress += amount;
    if (currentProgress >= requiredProgress) {
      currentProgress = requiredProgress;
      unlockedAt = DateTime.now();
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'currentProgress': currentProgress,
        'unlockedAt': unlockedAt?.toIso8601String(),
      };

  factory Achievement.fromMap(Map<String, dynamic> map, Achievement base) {
    return Achievement(
      id: base.id,
      name: base.name,
      description: base.description,
      iconEmoji: base.iconEmoji,
      requiredProgress: base.requiredProgress,
      currentProgress: map['currentProgress'] as int? ?? 0,
      unlockedAt: map['unlockedAt'] != null ? DateTime.parse(map['unlockedAt'] as String) : null,
    );
  }
}
