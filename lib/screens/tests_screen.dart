import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/test_models.dart';
import '../providers/tests_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/scale_tap.dart';
import 'quiz_screen.dart';

class TestsScreen extends StatefulWidget {
  const TestsScreen({super.key});

  @override
  State<TestsScreen> createState() => _TestsScreenState();
}

class _TestsScreenState extends State<TestsScreen> {
  
  Widget _fadeSlideItem(Widget child, int delayIndex) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (delayIndex * 150)),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  void _startTest(BuildContext context, SecurityTest test, bool isLocked) {
    if (isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete previous levels to unlock this test!')),
      );
      return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(test: test),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Security Tests', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Consumer<TestsProvider>(
          builder: (context, testsProvider, _) {
            final tests = TestsProvider.tests;
            
            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: tests.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _fadeSlideItem(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Test your instincts',
                          style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Complete gamified challenges to boost your Digital Safety Score and earn XP.',
                          style: TextStyle(fontSize: 15, color: AppTheme.textSecondary, height: 1.5),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                    0,
                  );
                }
                
                final test = tests[index - 1];
                
                // Determine locking logic
                bool isLocked = false;
                if (test.difficulty == TestDifficulty.intermediate) {
                  isLocked = !testsProvider.isIntermediateUnlocked;
                } else if (test.difficulty == TestDifficulty.advanced) {
                  isLocked = !testsProvider.isAdvancedUnlocked;
                }
                
                final isPassed = testsProvider.isTestPassed(test.id);
                final bestScore = testsProvider.bestScoreForTest(test.id);
                
                // Color mapping
                Color baseColor;
                switch (test.difficulty) {
                  case TestDifficulty.beginner: baseColor = const Color(0xFF4CAF50); break;
                  case TestDifficulty.intermediate: baseColor = const Color(0xFFFF9800); break;
                  case TestDifficulty.advanced: baseColor = const Color(0xFFE91E63); break;
                }

                return _fadeSlideItem(
                  ScaleTap(
                    onTap: () => _startTest(context, test, isLocked),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.cardColor.withValues(alpha: isLocked ? 0.3 : 0.5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isLocked ? Colors.white12 : baseColor.withValues(alpha: 0.3)),
                        boxShadow: isLocked ? null : [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.1),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isLocked ? Colors.white12 : baseColor.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isLocked ? Icons.lock : test.icon, 
                              color: isLocked ? AppTheme.textMuted : baseColor, 
                              size: 28
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        test.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 16, 
                                          fontWeight: FontWeight.w700, 
                                          color: isLocked ? AppTheme.textMuted : AppTheme.textPrimary
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isPassed)
                                      const Icon(Icons.check_circle, color: AppTheme.safe, size: 16),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  test.description,
                                  style: TextStyle(
                                    fontSize: 13, 
                                    color: isLocked ? AppTheme.textMuted.withValues(alpha: 0.5) : AppTheme.textMuted
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Wrap(
                                        spacing: 12,
                                        runSpacing: 4,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: isLocked ? Colors.white12 : baseColor.withValues(alpha: 0.2),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              test.difficulty.name.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 10, 
                                                fontWeight: FontWeight.w700, 
                                                color: isLocked ? AppTheme.textMuted : baseColor
                                              ),
                                            ),
                                          ),
                                          if (!isLocked)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star, color: AppTheme.accent, size: 14),
                                                const SizedBox(width: 4),
                                                Text(
                                                  '+${test.questions.length * 20} XP',
                                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.accent),
                                                )
                                              ],
                                            ),
                                        ]
                                      )
                                    ),
                                    if (bestScore > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '${(bestScore * 100).round()}%',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isPassed ? AppTheme.safe : AppTheme.riskHigh
                                        ),
                                      )
                                    ]
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  index,
                );
              },
            );
          }
        ),
      ),
    );
  }
}
