import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/risk_alert.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Card widget for displaying a single risk alert.
class RiskAlertCard extends StatelessWidget {
  final RiskAlert alert;
  final VoidCallback? onDismiss;
  final VoidCallback? onTap;

  const RiskAlertCard({
    super.key,
    required this.alert,
    this.onDismiss,
    this.onTap,
  });

  Color get _riskColor {
    if (alert.riskScore >= 0.8) return AppTheme.riskHigh;
    if (alert.riskScore >= 0.6) return AppTheme.riskMedium;
    return AppTheme.riskLow;
  }

  IconData get _riskIcon {
    switch (alert.riskType) {
      case RiskType.phishing:
        return Icons.phishing;
      case RiskType.scam:
        return Icons.warning_amber_rounded;
      case RiskType.fakeReward:
        return Icons.card_giftcard;
      case RiskType.urgency:
        return Icons.access_time_filled;
      case RiskType.suspiciousLink:
        return Icons.link_off;
      case RiskType.typosquatting:
        return Icons.spellcheck;
      case RiskType.finance:
        return Icons.account_balance;
      case RiskType.social:
        return Icons.people;
      case RiskType.promotion:
        return Icons.local_offer;
      case RiskType.update:
        return Icons.system_update;
      case RiskType.info:
        return Icons.info_outline;
      case RiskType.unknown:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
             // Deep, soft drop shadow for depth
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              // Semi-transparent surface
              color: AppTheme.cardColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              // Subtle inner glow border matching glassmorphism
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: _riskColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_riskIcon, color: _riskColor, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _riskColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  alert.riskType.label,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: _riskColor,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                timeAgo(alert.timestamp),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!alert.dismissed && onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.check_circle_outline,
                            color: AppTheme.textMuted),
                        onPressed: onDismiss,
                        tooltip: 'Dismiss',
                      ),
                    if (alert.dismissed)
                      const Icon(Icons.check_circle,
                          color: AppTheme.safe, size: 22),
                  ],
                ),
                const SizedBox(height: 12),
                // Body
                Text(
                  alert.body,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Explanation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          color: AppTheme.accent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          alert.explanation,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  ),
),
    );
  }
}
