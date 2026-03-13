import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/score_provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/risk_alert.dart';
import '../providers/alert_provider.dart';
import '../providers/tests_provider.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Standalone Alerts Screen — accessible from quick actions.
class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {

  Widget _fadeSlideItem(Widget child, int delayIndex) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 600 + (delayIndex * 150)),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 40 * (1 - value)),
          child: Opacity(opacity: value, child: child),
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Consumer<AlertProvider>(
                builder: (context, ap, _) {
                  if (ap.alerts.isEmpty) {
                    return const Center(child: Text('No alerts found.', style: TextStyle(color: AppTheme.textMuted)));
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: ap.alerts.length,
                    itemBuilder: (context, index) {
                      return _fadeSlideItem(_buildAlertCard(ap.alerts[index]), index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Text(
                'Notifications',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
            ],
          ),
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: AppTheme.textSecondary, size: 28),
              Positioned(
                right: 2, top: 2,
                child: Container(
                  width: 10, height: 10,
                  decoration: const BoxDecoration(color: AppTheme.riskHigh, shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildAlertCard(RiskAlert alert) {
    final isHighRisk = alert.riskScore >= 70;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Deep card background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _getIconForSource(alert.source.name),
              color: isHighRisk ? AppTheme.riskHigh : AppTheme.primary,
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
                    Text(
                      _formatSource(alert.source.name),
                      style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                    Text(
                      timeAgo(alert.timestamp),
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.body,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isHighRisk ? Icons.error_outline : Icons.warning_amber,
                      color: isHighRisk ? AppTheme.riskHigh : AppTheme.accent,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isHighRisk ? 'High Risk Threat' : 'Suspicious Activity',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isHighRisk ? AppTheme.riskHigh : AppTheme.accent,
                      ),
                    ),
                    const Spacer(),
                    if (!alert.dismissed)
                      TextButton(
                        onPressed: () {
                          // Award XP and handle alert
                          final gp = context.read<GamificationProvider>();
                          gp.addXp(GamificationProvider.xpThreatReported);
                          gp.updateAchievementProgress('safe_browser', 1);
                          
                          context.read<AlertProvider>().dismissAlert(alert.id);
                          
                          // Recalculate score
                          context.read<ScoreProvider>().recalculate(
                            context.read<AlertProvider>().alerts, gp, context.read<TestsProvider>(),
                          );
                          
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('+25 XP for reporting threat!')));
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.safe,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text('Dismiss', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      )
                    else
                      const Icon(Icons.check_circle, color: AppTheme.safe, size: 16),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSource(String source) {
    final s = source.toLowerCase();
    if (s.contains('whatsapp')) return Icons.chat;
    if (s.contains('bank')) return Icons.account_balance;
    if (s.contains('mail') || s.contains('gmail')) return Icons.mail;
    if (s.contains('sms') || s.contains('message')) return Icons.sms;
    return Icons.notifications;
  }
  
  String _formatSource(String source) {
    if (source.isEmpty) return 'System Alert';
    return source[0].toUpperCase() + source.substring(1);
  }
}

