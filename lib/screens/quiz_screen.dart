import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/test_models.dart';
import '../providers/gamification_provider.dart';
import '../providers/score_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/tests_provider.dart';
import '../utils/app_theme.dart';

class QuizScreen extends StatefulWidget {
  final SecurityTest test;

  const QuizScreen({super.key, required this.test});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentIndex = 0;
  bool _answered = false;
  int? _selectedOption;
  int _score = 0;

  void _submitAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedOption = index;
      _answered = true;
      if (index == widget.test.questions[_currentIndex].correctAnswerIndex) {
        _score++;
      }
    });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.test.questions.length - 1) {
      setState(() {
        _currentIndex++;
        _answered = false;
        _selectedOption = null;
      });
    } else {
      _finishQuiz();
    }
  }

  void _finishQuiz() async {
    final questionsCount = widget.test.questions.length;
    final scorePercentage = _score / questionsCount;
    
    // Save state
    final testsProvider = context.read<TestsProvider>();
    final gp = context.read<GamificationProvider>();
    final sp = context.read<ScoreProvider>();
    final ap = context.read<AlertProvider>();
    final navigator = Navigator.of(context);
    
    await testsProvider.completeTest(widget.test.id, scorePercentage);

    final totalXp = _score * GamificationProvider.xpTestPassed;
    
    if (totalXp > 0) {
      for(int i = 0; i < _score; i++) {
        gp.addXp(GamificationProvider.xpTestPassed);
      }
      
      if (_score == questionsCount) {
         gp.addXp(GamificationProvider.xpTestPerfect); // Bonus
         gp.updateAchievementProgress('quiz_master', 1);
         if (widget.test.id.contains('phishing')) {
           gp.updateAchievementProgress('phishing_hunter', 1);
         }
      }
      
      sp.recalculate(ap.alerts, gp, testsProvider);
    }
    
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3))),
        title: Text(
          _score == questionsCount ? 'Perfect Score! 🌟' : 'Test Complete',
          style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('You answered $_score out of $questionsCount correctly.', style: const TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            if (totalXp > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                child: Text('+$totalXp XP', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w800, fontSize: 18)),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              navigator.pop();
            },
            child: const Text('Return to Tests'),
          )
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.test.questions.isEmpty) {
       return Scaffold(
         backgroundColor: AppTheme.background,
         appBar: AppBar(title: Text(widget.test.title)),
         body: const Center(child: Text('No questions available for this test yet.', style: TextStyle(color: Colors.white))),
       );
    }
    
    final question = widget.test.questions[_currentIndex];
    final options = question.options;
    final correctIndex = question.correctAnswerIndex;
    
    Color color;
    switch (widget.test.difficulty) {
      case TestDifficulty.beginner: color = const Color(0xFF4CAF50); break;
      case TestDifficulty.intermediate: color = const Color(0xFFFF9800); break;
      case TestDifficulty.advanced: color = const Color(0xFFE91E63); break;
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Question ${_currentIndex + 1} of ${widget.test.questions.length}'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Text(
                  question.scenario,
                  style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w600, color: AppTheme.textPrimary, height: 1.5),
                ),
              ),
              if (question.textExample != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Text(
                    question.textExample!,
                    style: GoogleFonts.robotoMono(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ...List.generate(options.length, (index) {
                bool isSelected = _selectedOption == index;
                bool isCorrect = index == correctIndex;
                
                Color getBorderColor() {
                  if (!_answered) return Colors.white.withValues(alpha: 0.1);
                  if (isCorrect) return AppTheme.safe;
                  if (isSelected && !isCorrect) return AppTheme.riskHigh;
                  return Colors.white.withValues(alpha: 0.1);
                }

                Color getBgColor() {
                  if (!_answered) return AppTheme.cardColor.withValues(alpha: 0.5);
                  if (isCorrect) return AppTheme.safe.withValues(alpha: 0.1);
                  if (isSelected && !isCorrect) return AppTheme.riskHigh.withValues(alpha: 0.1);
                  return AppTheme.cardColor.withValues(alpha: 0.5);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _submitAnswer(index),
                    borderRadius: BorderRadius.circular(16),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: getBgColor(),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: getBorderColor(), width: 2),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              options[index],
                              style: TextStyle(
                                fontSize: 15,
                                color: _answered && isCorrect ? AppTheme.safe : AppTheme.textPrimary,
                                fontWeight: _answered && isCorrect ? FontWeight.w700 : FontWeight.w500,
                              ),
                            ),
                          ),
                          if (_answered && isCorrect)
                            const Icon(Icons.check_circle, color: AppTheme.safe)
                          else if (_answered && isSelected && !isCorrect)
                            const Icon(Icons.cancel, color: AppTheme.riskHigh)
                        ],
                      ),
                    ),
                  ),
                );
              }),
              const SizedBox(height: 32),
              if (_answered) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.accent.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: AppTheme.accent, size: 20),
                          SizedBox(width: 8),
                          Text('Explanation', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.accent)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        question.explanation,
                        style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.4),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    _currentIndex < widget.test.questions.length - 1 ? 'Next Question' : 'Finish Test',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      ),
    );
  }
}
