import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../data/local_storage_service.dart';
import '../providers/learning_provider.dart';
import '../utils/app_theme.dart';
import 'lesson_viewer_screen.dart';

/// Learning Tips Screen — categorized safety tips for micro-learning.
class TipsScreen extends StatefulWidget {
  const TipsScreen({super.key});

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  Widget _fadeSlideItem(Widget child, int delayIndex) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (delayIndex * 150)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fadeSlideItem(_buildHeader(), 0),
              const SizedBox(height: 32),
              _fadeSlideItem(_buildProgressWidget(), 1),
              const SizedBox(height: 24),
              _fadeSlideItem(_buildDivider('Security Curriculum'), 2),
              const SizedBox(height: 16),
              _fadeSlideItem(_buildCategoryGrid(), 3),
              const SizedBox(height: 100), // Padding for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Consumer<LocalStorageService>(
      builder: (context, defaultStorage, _) {
       final name = defaultStorage.userName.isEmpty ? 'Alex' : defaultStorage.userName.split(' ').first;
       return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Hub',
                  style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Good Morning, $name.',
                  style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: AppTheme.primary, size: 16),
                  const SizedBox(width: 6),
                  Text(
                     context.watch<LearningProvider>().totalCompletedLessons.toString(),
                     style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                  ),
                  const Text(' Tips', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildProgressWidget() {
    return Consumer<LearningProvider>(
      builder: (context, provider, _) {
        final progress = provider.overallProgress;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C), // Deep card background
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.accent.withValues(alpha: 0.2)),
            gradient: const LinearGradient(
              colors: [Color(0xFF161B22), Color(0xFF1A2235)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accent.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.energy_savings_leaf, color: AppTheme.accent, size: 28),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.accent),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Digital Safety Tree',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                progress == 0 ? 'Plant the seed of knowledge by starting your first lesson today.' 
                : (progress < 0.5 ? 'Your tree is growing strong. Keep learning to build deep roots.' 
                : 'Excellent! Your digital defense is towering over threats.'),
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
              ),
              const SizedBox(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildDivider(String text) {
    return Row(
      children: [
        const Icon(Icons.menu_book, color: AppTheme.textMuted, size: 18),
        const SizedBox(width: 12),
        Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildCategoryGrid() {
    return Consumer<LearningProvider>(
      builder: (context, provider, _) {
       return GridView.builder(
         shrinkWrap: true,
         physics: const NeverScrollableScrollPhysics(),
         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
           crossAxisCount: 2,
           crossAxisSpacing: 16,
           mainAxisSpacing: 16,
           childAspectRatio: 0.85,
         ),
         itemCount: LearningProvider.categories.length,
         itemBuilder: (context, index) {
           final category = LearningProvider.categories[index];
           final isCompleted = provider.isCategoryCompleted(category.id);
           
           return GestureDetector(
             onTap: () {
               if (category.lessons.isNotEmpty) {
                 Navigator.push(
                   context,
                   MaterialPageRoute(
                     builder: (context) => LessonViewerScreen(
                       category: category,
                       lesson: category.lessons.first,
                     ),
                   ),
                 );
               } else {
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('More lessons coming soon!')));
               }
             },
             child: Container(
               padding: const EdgeInsets.all(16),
               decoration: BoxDecoration(
                 color: AppTheme.cardColor.withValues(alpha: 0.6),
                 borderRadius: BorderRadius.circular(20),
                 border: Border.all(
                   color: isCompleted ? category.baseColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05)
                 ),
                 boxShadow: [
                   if (isCompleted)
                     BoxShadow(
                       color: category.baseColor.withValues(alpha: 0.1),
                       blurRadius: 15,
                       offset: const Offset(0, 5)
                     )
                 ]
               ),
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: [
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Container(
                         padding: const EdgeInsets.all(10),
                         decoration: BoxDecoration(
                           color: category.baseColor.withValues(alpha: 0.15),
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Icon(category.icon, color: category.baseColor, size: 24),
                       ),
                       if (isCompleted)
                         Icon(Icons.check_circle, color: category.baseColor, size: 20)
                       else if (category.lessons.isEmpty)
                         const Icon(Icons.lock_outline, color: AppTheme.textMuted, size: 18),
                     ],
                   ),
                   Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(
                         category.title,
                         style: GoogleFonts.inter(
                           fontSize: 14,
                           fontWeight: FontWeight.w700,
                           color: AppTheme.textPrimary,
                           height: 1.2
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                       const SizedBox(height: 6),
                       Text(
                         category.subtitle,
                         style: const TextStyle(
                           fontSize: 11,
                           color: AppTheme.textMuted,
                           height: 1.3
                         ),
                         maxLines: 2,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ],
                   )
                 ],
               ),
             ),
           );
         },
       );
      }
    );
  }
}
