import 'package:flutter/material.dart';
import '../models/achievement.dart';
import '../data/local_storage_service.dart';

/// Manages XP and achievement badges across the application.
class GamificationProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  
  int _xp = 0;
  List<Achievement> _achievements = [];

  GamificationProvider(this._storage) {
    _init();
  }

  int get xp => _xp;
  List<Achievement> get achievements => _achievements;

  // XP Constants based on the architecture doc
  static const int xpLessonCompleted = 10;
  static const int xpPhishingDetected = 15;
  static const int xpTestPassed = 20;
  static const int xpTestPerfect = 20; // Bonus
  static const int xpThreatReported = 25;

  static final List<Achievement> _baseAchievements = [
    Achievement(id: 'phishing_hunter', name: 'Phishing Hunter', description: 'Intercepted 10 suspicious messages.', iconEmoji: '🕵️', requiredProgress: 10),
    Achievement(id: 'link_defender', name: 'Link Defender', description: 'Scanned 50 URLs.', iconEmoji: '🛡️', requiredProgress: 50),
    Achievement(id: 'security_scholar', name: 'Security Scholar', description: 'Completed 5 learning modules.', iconEmoji: '🎓', requiredProgress: 5),
    Achievement(id: 'safe_browser', name: 'Safe Browser', description: 'Maintained SAFE status consistently.', iconEmoji: '🌐', requiredProgress: 7),
    Achievement(id: 'quiz_master', name: 'Quiz Master', description: 'Passed 3 security tests.', iconEmoji: '🎯', requiredProgress: 3),
    Achievement(id: 'scam_detector', name: 'Scam Detector', description: 'Aced a phishing test.', iconEmoji: '🚨', requiredProgress: 1),
  ];

  void _init() {
    _xp = _storage.totalXp;
    final savedMap = _storage.getAchievements();
    
    _achievements = _baseAchievements.map((base) {
      if (savedMap.containsKey(base.id)) {
        return Achievement.fromMap(savedMap[base.id] as Map<String, dynamic>, base);
      }
      return Achievement.fromMap({}, base);
    }).toList();
    
    notifyListeners();
  }

  void addXp(int amount) {
    _xp += amount;
    _storage.setTotalXp(_xp);
    notifyListeners();
  }

  void updateAchievementProgress(String id, int amount) {
    try {
      var achievement = _achievements.firstWhere((a) => a.id == id);
      bool wasUnlocked = achievement.isUnlocked;
      
      achievement.addProgress(amount);
      _saveAchievements();
      
      if (!wasUnlocked && achievement.isUnlocked) {
        // Here we could trigger a global notification or event bus
        // for badge unlock UI.
      }
      
      notifyListeners();
    } catch (e) {
      // ID not found
    }
  }

  void _saveAchievements() {
    final map = {for (var a in _achievements) a.id: a.toMap()};
    _storage.saveAchievements(map);
  }
}
