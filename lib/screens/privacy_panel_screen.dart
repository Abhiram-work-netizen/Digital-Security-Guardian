import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/gradient_background.dart';
import '../utils/app_theme.dart';

/// Privacy Transparency Panel — explains permissions, data handling, and privacy.
class PrivacyPanelScreen extends StatelessWidget {
  const PrivacyPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _fadeSlideItem(Row(children: [
                  IconButton(icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textPrimary, size: 20), onPressed: () => Navigator.pop(context)),
                  const SizedBox(width: 4),
                  Text('Privacy Panel', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                ]), 0),
                const SizedBox(height: 4),
                _fadeSlideItem(const Padding(
                  padding: EdgeInsets.only(left: 44),
                  child: Text('Full transparency about your data', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
                ), 0),
                const SizedBox(height: 24),

                // Privacy Promise
                _fadeSlideItem(Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppTheme.primary.withValues(alpha: 0.1), AppTheme.secondary.withValues(alpha: 0.1)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(children: [
                    const Icon(Icons.lock_outline, color: AppTheme.primary, size: 40),
                    const SizedBox(height: 12),
                    Text('Our Privacy Promise', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                    const SizedBox(height: 8),
                    const Text(
                      'Everything happens on your device. We never see, store, or upload your notifications, messages, or personal data.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                    ),
                  ]),
                ), 1),
                const SizedBox(height: 24),

                // Permissions section
                _fadeSlideItem(_sectionHeader('Permissions We Use'), 2),
                const SizedBox(height: 12),
                _fadeSlideItem(_permissionItem(Icons.notifications_active_outlined, 'Notification Access',
                  'Reads notification text to detect scam patterns. Content is analyzed in memory and immediately discarded.',
                  AppTheme.primary), 2),
                _fadeSlideItem(_permissionItem(Icons.public_outlined, 'Internet',
                  'Used only when you manually check a link. No personal data is ever sent.',
                  AppTheme.accent), 2),
                const SizedBox(height: 24),

                // How data is processed
                _fadeSlideItem(_sectionHeader('How Your Data is Processed'), 3),
                const SizedBox(height: 12),
                _fadeSlideItem(_processStep('1', 'Notification arrives on your device', 'We read the title and body text only.'), 3),
                _fadeSlideItem(_processStep('2', 'Pattern analysis runs locally', 'Text is compared against known scam patterns using on-device algorithms.'), 3),
                _fadeSlideItem(_processStep('3', 'Result is generated', 'If a risk is detected, a warning is created.'), 3),
                _fadeSlideItem(_processStep('4', 'Original text is discarded', 'The notification content is never stored. Only the risk category and timestamp are kept.'), 3),
                const SizedBox(height: 24),

                // What we never do
                _fadeSlideItem(_sectionHeader('What We Never Do'), 4),
                const SizedBox(height: 12),
                _fadeSlideItem(Column(children: [
                  _neverItem('Store notification content'),
                  _neverItem('Upload data to any server'),
                  _neverItem('Share data with third parties'),
                  _neverItem('Track your location'),
                  _neverItem('Read your messages or emails'),
                  _neverItem('Collect personal information'),
                  _neverItem('Display advertisements'),
                ]), 4),
                const SizedBox(height: 24),

                // Data stored locally
                _fadeSlideItem(_sectionHeader('Data Stored Locally'), 5),
                const SizedBox(height: 12),
                _fadeSlideItem(_storedItem(Icons.warning_amber, 'Risk Alerts', 'Risk type, severity score, and timestamp only. No original content.'), 5),
                _fadeSlideItem(_storedItem(Icons.score, 'Literacy Score', 'Your computed digital literacy scores across categories.'), 5),
                _fadeSlideItem(_storedItem(Icons.settings, 'App Preferences', 'Onboarding completion status and settings.'), 5),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
    );
  }

  Widget _fadeSlideItem(Widget child, int delayIndex) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (delayIndex * 150)),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _sectionHeader(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary));
  }

  Widget _permissionItem(IconData icon, String title, String desc, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.4), 
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 24)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 6),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _processStep(String num, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.4), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 32, height: 32, alignment: Alignment.center,
          decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(8)),
          child: Text(num, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ])),
      ]),
    );
  }

  Widget _neverItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        const Icon(Icons.cancel_outlined, color: AppTheme.riskHigh, size: 20),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
      ]),
    );
  }

  Widget _storedItem(IconData icon, String title, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.4), 
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: AppTheme.primary, size: 22),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
        ])),
      ]),
    );
  }
}
