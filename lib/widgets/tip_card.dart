import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/safety_tip.dart';
import '../utils/app_theme.dart';

/// Expandable card widget for a single safety tip.
class TipCard extends StatefulWidget {
  final SafetyTip tip;

  const TipCard({super.key, required this.tip});

  @override
  State<TipCard> createState() => _TipCardState();
}

class _TipCardState extends State<TipCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;

  IconData _getIcon() {
    switch (widget.tip.iconName) {
      case 'phishing':
        return Icons.phishing;
      case 'person_search':
        return Icons.person_search;
      case 'lock':
        return Icons.lock_outline;
      case 'touch_app':
        return Icons.touch_app;
      case 'key':
        return Icons.key;
      case 'security':
        return Icons.security;
      case 'app_settings_alt':
        return Icons.app_settings_alt;
      case 'wifi_tethering_error':
        return Icons.wifi_tethering_error;
      case 'psychology':
        return Icons.psychology;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'spellcheck':
        return Icons.spellcheck;
      case 'system_update':
        return Icons.system_update;
      case 'link_off':
        return Icons.link_off;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'password':
        return Icons.password;
      case 'fact_check':
        return Icons.fact_check;
      case 'backup':
        return Icons.backup;
      case 'mood':
        return Icons.mood;
      case 'rate_review':
        return Icons.rate_review;
      case 'screen_lock_portrait':
        return Icons.screen_lock_portrait;
      default:
        return Icons.shield;
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
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isExpanded
                    ? AppTheme.primary.withValues(alpha: 0.4)
                    : Colors.white.withValues(alpha: 0.08),
                width: 1.5,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getIcon(),
                        color: AppTheme.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tip.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.tip.category.label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 300),
                      turns: _isExpanded ? 0.5 : 0,
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: const SizedBox.shrink(),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      widget.tip.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
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
