import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/app_theme.dart';

/// Animated radial gauge widget for displaying the Digital Literacy Score.
class ScoreGauge extends StatelessWidget {
  final double score; // 0–100
  final double size;
  final String? label;

  const ScoreGauge({
    super.key,
    required this.score,
    this.size = 200,
    this.label,
  });

  Color get _scoreColor {
    if (score >= 80) return AppTheme.safe;
    if (score >= 60) return AppTheme.riskLow;
    if (score >= 40) return const Color(0xFFFFD740);
    if (score >= 20) return AppTheme.riskMedium;
    return AppTheme.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          PieChart(
            PieChartData(
              startDegreeOffset: 135,
              sectionsSpace: 0,
              centerSpaceRadius: size * 0.35,
              sections: [
                PieChartSectionData(
                  value: score,
                  color: _scoreColor,
                  radius: size * 0.12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: 100 - score,
                  color: AppTheme.surfaceLight,
                  radius: size * 0.08,
                  showTitle: false,
                ),
              ],
            ),
          ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                score.round().toString(),
                style: TextStyle(
                  fontSize: size * 0.22,
                  fontWeight: FontWeight.w700,
                  color: _scoreColor,
                  height: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label ?? 'Score',
                style: TextStyle(
                  fontSize: size * 0.07,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
