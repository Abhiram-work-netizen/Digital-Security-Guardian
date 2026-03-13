import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/test_models.dart';
import '../data/local_storage_service.dart';

class TestsProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<TestResult> _completedTests = [];

  TestsProvider(this._storage);

  List<TestResult> get completedTests => _completedTests;

  Future<void> loadState() async {
    final jsonList = _storage.getCompletedTestsJson();
    print('Loading \${jsonList.length} test results from storage'); // Debug print
    _completedTests = jsonList.map((jsonStr) => TestResult.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>)).toList();
    notifyListeners();
  }

  Future<void> completeTest(String testId, double scorePercentage) async {
    final result = TestResult(
      testId: testId,
      scorePercentage: scorePercentage,
      dateCompleted: DateTime.now(),
    );
    
    // We allow retaking tests. Eiter update existing or keep a log. We'll simply keep a log of all results.
    // However, for calculating averages, maybe we just keep the best score per test ID.
    // For now, let's keep all attempts and calculate averages on the fly.
    _completedTests.add(result);
    
    final jsonList = _completedTests.map((r) => jsonEncode(r.toJson())).toList();
    await _storage.saveCompletedTestsJson(jsonList);
    notifyListeners();
  }

  double bestScoreForTest(String testId) {
    var best = 0.0;
    for (var result in _completedTests) {
      if (result.testId == testId && result.scorePercentage > best) {
        best = result.scorePercentage;
      }
    }
    return best;
  }

  bool isTestPassed(String testId) {
    return bestScoreForTest(testId) >= 0.8; // Passing == 80%
  }

  double get overallAccuracy {
    if (_completedTests.isEmpty) return 0.0;
    double sum = 0;
    for (var r in _completedTests) { sum += r.scorePercentage; }
    return sum / _completedTests.length;
  }

  bool get isIntermediateUnlocked {
    // Beginner must have at least one test passed
    return tests.where((t) => t.difficulty == TestDifficulty.beginner).any((t) => isTestPassed(t.id));
  }

  bool get isAdvancedUnlocked {
    // Intermediate must have at least one test passed
    return tests.where((t) => t.difficulty == TestDifficulty.intermediate).any((t) => isTestPassed(t.id));
  }


  // ─── Static Quiz Data ────────────────────────────────────────

  static const List<SecurityTest> tests = [
    // 1. Beginner Phishing
    SecurityTest(
      id: 'test_phishing_beginner',
      title: 'Phishing 101',
      description: 'Learn to spot the most obvious scams.',
      difficulty: TestDifficulty.beginner,
      icon: Icons.phishing,
      questions: [
        QuizQuestion(
          id: 'q_ph_b1',
          scenario: 'You receive an email from "PayPaI Support" saying your account will be suspended in 24 hours. They provide a link to verify your identity.',
          textExample: 'Subject: URGENT: Account Suspension Notice\n\nDear Customer,\n\nWe noticed unusual activity on your PayPaI account. Please click here immediately to restore access or your funds will be frozen.',
          type: QuestionType.text,
          options: ['Safe', 'Suspicious', 'Phishing'],
          correctAnswerIndex: 2,
          explanation: 'This is a classic Phishing attack. Notice the fake name ("PayPaI" with a capital i instead of an L), the generic greeting ("Dear Customer"), and the extreme urgency ("suspended in 24 hours").',
          relatedLessonId: 'cat_phishing',
        ),
        QuizQuestion(
          id: 'q_ph_b2',
          scenario: 'A text message from an unknown number says: "USPS: We tried to deliver your package today but need a \$2.99 fee. Link: http://usps-update-track.info/pay"',
          textExample: 'USPS: We tried to deliver your package today but need a \$2.99 fee. Link: http://usps-update-track.info/pay',
          type: QuestionType.text,
          options: ['Safe', 'Phishing'],
          correctAnswerIndex: 1,
          explanation: 'This is Smishing (SMS phishing). USPS does not send texts asking for money, and the link domain is completely fake.',
          relatedLessonId: 'cat_phishing',
        )
      ],
    ),
    // 2. Beginner Passwords
    SecurityTest(
      id: 'test_passwords_beginner',
      title: 'Password Basics',
      description: 'Can you identify the weak links?',
      difficulty: TestDifficulty.beginner,
      icon: Icons.password,
      questions: [
        QuizQuestion(
          id: 'q_pw_b1',
          scenario: 'Which of the following is the strongest password strategy?',
          type: QuestionType.text,
          options: [
            'Using your dog\'s name and birth year (e.g., Buster2015)',
            'Using the same complex password for every site',
            'Using a unique 14-character passphrase for every login',
            'Writing passwords down on a sticky note under your keyboard'
          ],
          correctAnswerIndex: 2,
          explanation: 'A unique passphrase is the safest option. Reusing passwords means if one site gets hacked, all your accounts are compromised.',
          relatedLessonId: 'cat_passwords',
        ),
      ]
    ),
    // 3. Intermediate Web Safety
    SecurityTest(
      id: 'test_web_int',
      title: 'Link Inspector',
      description: 'Examine domains closely to catch typosquatting.',
      difficulty: TestDifficulty.intermediate,
      icon: Icons.public,
      questions: [
        QuizQuestion(
          id: 'q_wb_i1',
          scenario: 'You want to check your bank balance. Which URL is safe to click?',
          type: QuestionType.text,
          options: [
            'http://www.chase.com-login-verify.update.net',
            'https://www.chase.com',
            'https://login.chase-banking-support.com',
            'http://chase.com'
          ],
          correctAnswerIndex: 1,
          explanation: 'The only correct one is https://www.chase.com. The others use deceptive subdomains, missing HTTPS, or dashed domains that don\'t belong to the bank.',
          relatedLessonId: 'cat_browsing',
        )
      ]
    ),
    // 4. Advanced Social Engineering
    SecurityTest(
      id: 'test_social_adv',
      title: 'Spear Phishing',
      description: 'Highly targeted attacks simulating workplace fraud.',
      difficulty: TestDifficulty.advanced,
      icon: Icons.people_outline,
      questions: [
        QuizQuestion(
          id: 'q_se_a1',
          scenario: 'Your CEO emails you directly: "I\'m in a meeting right now and need you to buy 10 Apple gift cards for a client presentation. Send the codes to me here ASAP."',
          textExample: 'From: John Smith <ceo@company-execs.com>\n\nI\'m in a meeting right now and need you to buy 10 Apple gift cards for a client presentation. Send the codes to me here ASAP.',
          type: QuestionType.text,
          options: ['Safe - Do It', 'Suspicious - Verify', 'Phishing - Ignore'],
          correctAnswerIndex: 1,
          explanation: 'This is BEC (Business Email Compromise). While it seems plausible, the CEO sender address is likely spoofed or from a lookalike domain (`company-execs.com`). You should always Verify via another channel (phone call, slack).',
          relatedLessonId: 'cat_social',
        )
      ]
    ),
  ];
}
