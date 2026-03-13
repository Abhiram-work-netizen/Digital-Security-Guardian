import 'dart:ui';
import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

/// Reusable gradient background wrapper with slow ambient animation
class GradientBackground extends StatefulWidget {
  final Widget child;
  final bool useAppBar;

  const GradientBackground({
    super.key,
    required this.child,
    this.useAppBar = false,
  });

  @override
  State<GradientBackground> createState() => _GradientBackgroundState();
}

class _GradientBackgroundState extends State<GradientBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Base Dark Background
          Container(color: AppTheme.background),
          
          // Animated Ambient Blobs
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Stack(
                children: [
                  // Top Left Blob (Teal)
                  Positioned(
                    top: -100 + (50 * _controller.value),
                    left: -100 - (30 * _controller.value),
                    child: Container(
                      width: 400,
                      height: 400,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primary.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                  // Bottom Right Blob (Indigo)
                  Positioned(
                    bottom: -150 - (50 * _controller.value),
                    right: -50 + (40 * _controller.value),
                    child: Container(
                      width: 500,
                      height: 500,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.secondary.withValues(alpha: 0.12),
                      ),
                    ),
                  ),
                  // Center Accent Blob (Cyan)
                  Positioned(
                    top: MediaQuery.of(context).size.height * 0.4 + (100 * _controller.value),
                    left: MediaQuery.of(context).size.width * 0.2 - (80 * _controller.value),
                    child: Container(
                      width: 300,
                      height: 300,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accent.withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          
          // Heavy Gaussian Blur Over the Blobs
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          
          // The actual screen content
          widget.child,
        ],
      ),
    );
  }
}
