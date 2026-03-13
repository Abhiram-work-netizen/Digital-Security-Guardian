import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import 'scale_tap.dart';

class AnimatedNavItem {
  final IconData icon;
  final String label;

  AnimatedNavItem({required this.icon, required this.label});
}

class AnimatedNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final List<AnimatedNavItem> items;

  const AnimatedNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppTheme.background, // Solid deep dark blue, not floating
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.05),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(items.length, (index) {
          final isActive = currentIndex == index;
          final item = items[index];

          return Expanded(
            child: ScaleTap(
              onTap: () => onTap(index),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        item.icon,
                        color: isActive ? AppTheme.primary : AppTheme.textMuted,
                        size: 26,
                      ),
                    ),
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        color: isActive ? AppTheme.primary : AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Neon glowing underscore for active state
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: isActive ? 1.0 : 0.0,
                      child: Container(
                        width: 20,
                        height: 3,
                        decoration: BoxDecoration(
                          color: AppTheme.primary,
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primary.withValues(alpha: 0.5),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
