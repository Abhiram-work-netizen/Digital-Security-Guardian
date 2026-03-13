import 'package:flutter/material.dart';
import '../models/learning_models.dart';
import '../data/local_storage_service.dart';

class LearningProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<String> _completedLessonIds = [];

  LearningProvider(this._storage);

  List<String> get completedLessonIds => _completedLessonIds;

  Future<void> loadState() async {
    _completedLessonIds = _storage.getCompletedLessons();
    notifyListeners();
  }

  Future<void> completeLesson(String lessonId) async {
    if (!_completedLessonIds.contains(lessonId)) {
      _completedLessonIds.add(lessonId);
      await _storage.saveCompletedLessons(_completedLessonIds);
      notifyListeners();
    }
  }

  bool isLessonCompleted(String lessonId) {
    return _completedLessonIds.contains(lessonId);
  }

  bool isCategoryCompleted(String categoryId) {
    final category = categories.firstWhere((c) => c.id == categoryId);
    return category.lessons.every((lesson) => _completedLessonIds.contains(lesson.id));
  }

  int get totalCompletedLessons => _completedLessonIds.length;
  
  int get totalAvailableLessons {
    return categories.fold(0, (sum, cat) => sum + cat.lessons.length);
  }

  double get overallProgress {
    if (totalAvailableLessons == 0) return 0.0;
    return totalCompletedLessons / totalAvailableLessons;
  }

  // ─── Static Curriculum Data ────────────────────────────

  static const List<LearningCategory> categories = [
    LearningCategory(
      id: 'cat_passwords',
      title: 'Strong Passwords',
      subtitle: 'The basics of locking your digital doors',
      icon: Icons.password,
      baseColor: Color(0xFF4CAF50), // Green
      lessons: [
        LearningLesson(
          id: 'les_pwd_1',
          title: 'How to Create Strong Passwords',
          description: 'Learn why "123456" is dangerous and how to create a fortress.',
          xpReward: 10,
          steps: [
            LessonStep(
              title: 'The Flimsy Lock',
              content: 'Think of your password like the lock on your front door. If your lock is cheap (like the password "123456"), anyone can kick the door open.',
              type: StepType.text,
            ),
            LessonStep(
              title: 'The Hacker\'s Game',
              content: 'Hackers use computer programs that guess millions of words incredibly fast. If you use a normal dictionary word or your pet\'s name, they will guess it in seconds.',
              type: StepType.text,
            ),
            LessonStep(
              title: 'Real World Example',
              content: 'Weak password: fluffy2023 (Cracked in 2 seconds)\n\nStrong password: R!ver\$Moon_92 (Takes 400 years to crack)',
              type: StepType.scenario,
            ),
            LessonStep(
              title: 'Try It Yourself',
              content: 'Let\'s test how strong a password is. Don\'t use your real password!',
              type: StepType.interactiveLab,
              labType: 'password_checker',
            ),
            LessonStep(
              title: 'Quick Tip',
              content: 'Use a Passphrase! Combine three random words (like CoffeeWindowTiger) and add a symbol.',
              type: StepType.text,
            ),
          ],
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_phishing',
      title: 'Phishing &\nAwareness',
      subtitle: 'Spotting the bait before you bite',
      icon: Icons.phishing,
      baseColor: Color(0xFFFF5252), // Red
      lessons: [
        LearningLesson(
          id: 'les_phish_1',
          title: 'Spotting a Fake Text (Smishing)',
          description: 'Fraudsters pretending to be Amazon or the Post Office.',
          xpReward: 15,
          steps: [
            LessonStep(
              title: 'The Trap',
              content: 'Fraudsters often pretend to be companies you trust, like the Post Office. Their goal is to make you panic and click the link without thinking.',
              type: StepType.text,
            ),
            LessonStep(
              title: 'Anatomy of a Fake',
              content: 'Fake Text: "POSTAL SERVICE: We could not deliver your package... Click here: http://usps-update-track.info/pay"\n\nWhy it\'s fake: The Post Office will never text you a link asking for money. Look at the weird domain name.',
              type: StepType.scenario,
            ),
            LessonStep(
              title: 'Test Your Reflexes',
              content: 'Swipe left if you think the message is a scam. Swipe right if it\'s safe.',
              type: StepType.interactiveLab,
              labType: 'scam_swiper',
            ),
          ],
        ),
      ],
    ),
    LearningCategory(
      id: 'cat_browsing',
      title: 'Safe Browsing &\nSuspicious Links',
      subtitle: 'Navigating the web without stepping on landmines',
      icon: Icons.public,
      baseColor: Color(0xFF2196F3), // Blue
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_data',
      title: 'Protecting\nPersonal Data',
      subtitle: 'Keeping your private info private',
      icon: Icons.fingerprint,
      baseColor: Color(0xFF9C27B0), // Purple
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_social',
      title: 'Social Media\nPrivacy',
      subtitle: 'Sharing safely with friends, not strangers',
      icon: Icons.people_outline,
      baseColor: Color(0xFFFF9800), // Orange
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_shopping',
      title: 'Online Shopping &\nBanking Safety',
      subtitle: 'Protecting your wallet from digital pickpockets',
      icon: Icons.shopping_cart_outlined,
      baseColor: Color(0xFF00BCD4), // Cyan
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_device',
      title: 'Device Security\n(Phone & PC)',
      subtitle: 'Securing the device you hold in your hand',
      icon: Icons.smartphone,
      baseColor: Color(0xFF607D8B), // Blue Grey
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_fakenews',
      title: 'Recognizing Fake News\n& Misinformation',
      subtitle: 'Fact-checking in the digital age',
      icon: Icons.article_outlined,
      baseColor: Color(0xFF795548), // Brown
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_children',
      title: 'Protecting\nChildren Online',
      subtitle: 'A guide for parents and guardians',
      icon: Icons.child_care,
      baseColor: Color(0xFFE91E63), // Pink
      lessons: [],
    ),
    LearningCategory(
      id: 'cat_elderly',
      title: 'Cyber Safety for\nElderly Users',
      subtitle: 'Simple steps to protect older family members',
      icon: Icons.elderly,
      baseColor: Color(0xFF009688), // Teal
      lessons: [],
    ),
  ];
}
