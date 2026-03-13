import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/insight_provider.dart';
import '../models/weekly_insight.dart';
import '../utils/app_theme.dart';

/// Insights Screen (standalone route) — mirrors the _InsightsTab with full chart & breakdowns.
class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Behavior Insights', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 20)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: Consumer<InsightProvider>(builder: (context, ip, _) {
          final i = ip.weeklyInsight;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your digital safety trends this week',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6),
                ),
                const SizedBox(height: 24),
                if (i != null) ...[
                  _weeklyChart(i),
                  const SizedBox(height: 20),
                  _breakdown('Phishing', i.phishingCount, Icons.phishing, AppTheme.riskHigh),
                  _breakdown('Scam Messages', i.scamCount, Icons.warning_amber, AppTheme.riskMedium),
                  _breakdown('Fake Rewards', i.fakeRewardCount, Icons.card_giftcard, const Color(0xFFFFD740)),
                  _breakdown('Urgency Tactics', i.urgencyCount, Icons.access_time_filled, AppTheme.accent),
                  _breakdown('Risky Links', i.riskyLinksCount, Icons.link_off, AppTheme.secondary),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(children: [
                          Icon(Icons.psychology, color: AppTheme.primary, size: 22),
                          SizedBox(width: 10),
                          Text('Behavioral Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                        ]),
                        const SizedBox(height: 12),
                        Text(i.suggestion, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Summary row
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _summaryItem('Total\nAlerts', i.totalAlerts.toString(), AppTheme.primary),
                        Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                        _summaryItem('Threats\nBlocked', '${i.phishingCount + i.scamCount}', AppTheme.riskHigh),
                        Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.1)),
                        _summaryItem('Risky\nLinks', i.riskyLinksCount.toString(), AppTheme.accent),
                      ],
                    ),
                  ),
                ] else
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.insights_outlined, size: 64, color: AppTheme.textMuted.withValues(alpha: 0.5)),
                          const SizedBox(height: 16),
                          Text('No insights yet', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: AppTheme.textMuted)),
                          const SizedBox(height: 8),
                          const Text(
                            'As you use your device, your behavior\npatterns will appear here.',
                            style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _weeklyChart(WeeklyInsight insight) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final max = insight.dailyAlertCounts.reduce((a, b) => a > b ? a : b);
    final maxY = (max + 2).toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Alert Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (idx) {
                final cnt = insight.dailyAlertCounts[idx];
                final h = maxY > 0 ? (cnt / maxY) * 140 : 0.0;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(cnt.toString(), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Container(
                          height: h.clamp(4.0, 140.0),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [AppTheme.primary, AppTheme.accent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(6)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(days[idx], style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _breakdown(String label, int count, IconData icon, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: c, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
        Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c)),
      ]),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3), textAlign: TextAlign.center),
      ],
    );
  }
}
