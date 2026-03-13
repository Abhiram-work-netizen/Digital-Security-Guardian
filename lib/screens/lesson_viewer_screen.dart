import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/learning_models.dart';
import '../providers/learning_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/score_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/tests_provider.dart';
import '../utils/app_theme.dart';
import '../widgets/interactive_labs.dart';

class LessonViewerScreen extends StatefulWidget {
  final LearningCategory category;
  final LearningLesson lesson;

  const LessonViewerScreen({
    super.key,
    required this.category,
    required this.lesson,
  });

  @override
  State<LessonViewerScreen> createState() => _LessonViewerScreenState();
}

class _LessonViewerScreenState extends State<LessonViewerScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < widget.lesson.steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    } else {
      _finishLesson();
    }
  }

  void _finishLesson() async {
    final learningProvider = context.read<LearningProvider>();
    final gp = context.read<GamificationProvider>();
    final scoreProvider = context.read<ScoreProvider>();
    final alertProvider = context.read<AlertProvider>();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final nav = Navigator.of(context);
    
    // Only reward if not previously completed
    if (!learningProvider.isLessonCompleted(widget.lesson.id)) {
      await learningProvider.completeLesson(widget.lesson.id);
      
      gp.addXp(widget.lesson.xpReward);
      gp.updateAchievementProgress('security_scholar', 1);
      
      scoreProvider.recalculate(alertProvider.alerts, gp, context.read<TestsProvider>());
    }

    nav.pop();
    scaffoldMessenger.showSnackBar(
         SnackBar(
           content: Text('+${widget.lesson.xpReward} XP: Lesson Completed!'),
           backgroundColor: widget.category.baseColor,
         )
       );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161B22), // Deep dark
      resizeToAvoidBottomInset: false, // Prevents overflow when keyboard opens
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            const SizedBox(height: 16),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: widget.lesson.steps.length,
                itemBuilder: (context, index) {
                  return _buildStepCard(widget.lesson.steps[index]);
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white54),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Row(
              children: List.generate(
                widget.lesson.steps.length,
                (index) => Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index <= _currentIndex 
                          ? widget.category.baseColor 
                          : Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance for back button
        ],
      ),
    );
  }

  Widget _buildStepCard(LessonStep step) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: widget.category.baseColor.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: widget.category.baseColor.withValues(alpha: 0.05),
              blurRadius: 30,
              offset: const Offset(0, 10),
            )
          ]
        ),
        child: Column(
          children: [
            // Decorative Header
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: widget.category.baseColor.withValues(alpha: 0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Center(
                child: Icon(
                  _getStepIcon(step.type),
                  size: 48,
                  color: widget.category.baseColor,
                ),
              ),
            ),
            
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      step.title,
                      style: GoogleFonts.inter(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.2
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (step.type == StepType.scenario)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.background,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Text(
                          step.content,
                          style: GoogleFonts.robotoMono(fontSize: 14, color: AppTheme.textSecondary),
                        ),
                      )
                    else 
                      Text(
                        step.content,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    
                    if (step.type == StepType.interactiveLab) ...[
                      const SizedBox(height: 32),
                      Expanded(child: _buildLab(step.labType)),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStepIcon(StepType type) {
    switch(type) {
      case StepType.scenario: return Icons.remove_red_eye;
      case StepType.interactiveLab: return Icons.science;
      case StepType.text: return widget.category.icon;
    }
  }

  Widget _buildLab(String? labType) {
    if (labType == 'password_checker') {
      return const PasswordStrengthLab();
    } else if (labType == 'scam_swiper') {
      return const ScamSwiperLab();
    }
    return const Center(child: Text('Lab configuration missing', style: TextStyle(color: Colors.white54)));
  }

  Widget _buildBottomControls() {
    final isLast = _currentIndex == widget.lesson.steps.length - 1;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: GestureDetector(
        onTap: _nextPage,
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: isLast ? widget.category.baseColor : AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isLast ? Colors.transparent : Colors.white24),
            boxShadow: [
              if (isLast)
                BoxShadow(
                  color: widget.category.baseColor.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                )
            ]
          ),
          child: Center(
            child: Text(
              isLast ? 'Complete Lesson' : 'Continue',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
