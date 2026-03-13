import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../models/risk_alert.dart';
import '../models/weekly_insight.dart';
import '../providers/alert_provider.dart';
import '../providers/score_provider.dart';
import '../providers/insight_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/tests_provider.dart';
import '../widgets/animated_navigation_bar.dart';
import '../widgets/scale_tap.dart';
import '../data/local_storage_service.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';
import '../utils/constants.dart';

/// Home Dashboard — main entry point with bottom navigation.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: IndexedStack(
            index: _currentIndex,
            children: [
              _DashboardTab(),
              _AlertsTab(),
              _InsightsTab(),
              _ProfileTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AnimatedNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          AnimatedNavItem(icon: Icons.home_outlined, label: 'Home'),
          AnimatedNavItem(icon: Icons.notifications_active_outlined, label: 'Notifications'),
          AnimatedNavItem(icon: Icons.insights_outlined, label: 'Insights'),
          AnimatedNavItem(icon: Icons.person_outline, label: 'Profile'),
        ],
      ),
    );
  }
}

// ─── Dashboard Tab ───────────────────────────────────────
class _DashboardTab extends StatefulWidget {
  @override
  State<_DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<_DashboardTab> {
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _fadeSlideItem(_buildHeader(context), 0),
          const SizedBox(height: 24),
          _fadeSlideItem(_buildSecurityStatusCard(context), 1),
          const SizedBox(height: 24),
          _fadeSlideItem(_buildFeatureGrid(context), 2),
          const SizedBox(height: 32),
          _fadeSlideItem(
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Notifications',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
              ),
            ),
            3,
          ),
          const SizedBox(height: 12),
          _fadeSlideItem(_buildRecentAlertsList(context), 4),
          const SizedBox(height: 100), // Padding for bottom nav
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Consumer2<ScoreProvider, LocalStorageService>(
      builder: (context, sp, storage, _) {
        final score = sp.score.overallScore.round();
        final isSafe = score >= 80;
        final color = isSafe ? AppTheme.safe : (score >= 60 ? AppTheme.accent : AppTheme.riskHigh);
        final statusText = isSafe ? 'SAFE USER' : (score >= 60 ? 'MODERATE RISK' : 'AT RISK');

        final userName = storage.userName.isEmpty ? 'Guardian' : storage.userName;
        final avatarPath = storage.userAvatarPath;

        return Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppTheme.cardColor,
              backgroundImage: avatarPath.isNotEmpty ? FileImage(File(avatarPath)) : null,
              child: avatarPath.isEmpty ? const Icon(Icons.person, color: AppTheme.primary) : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, $userName',
                    style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Digital Safety Score: $score/100 ($statusText)',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSecurityStatusCard(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, ap, _) {
        final activeThreats = ap.activeAlerts.length;
        String threatText;
        Color threatColor;
        if (activeThreats == 0) {
          threatText = 'Threat Level: NONE';
          threatColor = AppTheme.safe;
        } else if (activeThreats <= 2) {
          threatText = 'Threat Level: LOW';
          threatColor = AppTheme.safe;
        } else if (activeThreats <= 5) {
          threatText = 'Threat Level: MODERATE';
          threatColor = AppTheme.accent;
        } else {
          threatText = 'Threat Level: HIGH';
          threatColor = AppTheme.riskHigh;
        }

        final storage = context.read<LocalStorageService>();
        final lastScan = storage.lastScanTime;
        String lastScanText;
        if (lastScan == null) {
          lastScanText = 'No scans yet';
        } else {
          final diff = DateTime.now().difference(lastScan);
          if (diff.inMinutes < 1) {
            lastScanText = 'Last Scan: just now';
          } else if (diff.inMinutes < 60) {
            lastScanText = 'Last Scan: ${diff.inMinutes} min ago';
          } else if (diff.inHours < 24) {
            lastScanText = 'Last Scan: ${diff.inHours}h ago';
          } else {
            lastScanText = 'Last Scan: ${diff.inDays}d ago';
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 5),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shield, color: AppTheme.primary, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    'Your Digital Security Guardian',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                threatText,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: threatColor),
              ),
              const SizedBox(height: 4),
              Text(
                lastScanText,
                style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final gp = context.read<GamificationProvider>();
                    final sp = context.read<ScoreProvider>();
                    await sp.recalculate(ap.alerts, gp, context.read<TestsProvider>());
                    await storage.setLastScanTime(DateTime.now());
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(
                          activeThreats == 0
                            ? 'Scan complete. No threats found!'
                            : 'Scan complete. $activeThreats active threat${activeThreats > 1 ? 's' : ''} detected.',
                        )),
                      );
                      // Force rebuild to update last scan time
                      (context as Element).markNeedsBuild();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text('Run Security Scan', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeatureGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.5,
      children: [
        _moduleCard(context, Icons.notifications_active_outlined, 'Notifications', AppTheme.riskHigh, '/alerts'),
        _moduleCard(context, Icons.link, 'Link Check', AppTheme.accent, '/link-checker'),
        _moduleCard(context, Icons.description_outlined, 'Document Verify', AppTheme.secondary, '/document-verify'),
        _moduleCard(context, Icons.menu_book, 'Security Tips', AppTheme.primary, '/tips'),
        _moduleCard(context, Icons.insights, 'Behavior Insights', const Color(0xFF4CAF50), '/insights'),
        _moduleCard(context, Icons.psychology, 'Security Tests', const Color(0xFF9C27B0), '/tests'),
      ],
    );
  }

  Widget _moduleCard(BuildContext context, IconData icon, String title, Color color, String route) {
    return ScaleTap(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsList(BuildContext context) {
    return Consumer<AlertProvider>(builder: (context, ap, _) {
      final recent = ap.activeAlerts.take(3).toList();
      if (recent.isEmpty) return const SizedBox.shrink();
      
      return Column(
        children: recent.map((alert) {
          final isHighRisk = alert.riskScore >= 70;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.cardColor.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.03)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Simulating App Icons (Swift Bank, WhatsApp)
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForSource(alert.source.name), 
                    color: isHighRisk ? AppTheme.riskHigh : AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatSource(alert.source.name),
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                          ),
                          Text(
                            timeAgo(alert.timestamp),
                            style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.body,
                        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  isHighRisk ? Icons.error_outline : (alert.riskScore == 0 ? Icons.info_outline : Icons.warning_amber),
                  color: isHighRisk ? AppTheme.riskHigh : (alert.riskScore == 0 ? AppTheme.safe : AppTheme.accent),
                  size: 20,
                )
              ],
            ),
          );
        }).toList(),
      );
    });
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


// ─── Alerts Tab ──────────────────────────────────────────
class _AlertsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AlertProvider>(builder: (context, ap, _) {
      return Padding(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Notifications', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                const SizedBox(height: 4),
                Text('${ap.activeCount} active alerts', style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              ]),
              if (ap.alerts.isNotEmpty)
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: AppTheme.cardColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        title: const Text('Clear All Notifications?', style: TextStyle(color: AppTheme.textPrimary)),
                        content: const Text('This will remove all notifications. This action cannot be undone.', style: TextStyle(color: AppTheme.textSecondary)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                          TextButton(
                            onPressed: () {
                              context.read<AlertProvider>().clearAll();
                              Navigator.pop(ctx);
                            },
                            style: TextButton.styleFrom(foregroundColor: AppTheme.riskHigh),
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete_sweep, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.textMuted),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Active notification listening status
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.safe.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.safe.withValues(alpha: 0.2)),
            ),
            child: const Row(children: [
              Icon(Icons.notifications_active, color: AppTheme.safe, size: 18),
              SizedBox(width: 10),
              Expanded(child: Text(
                'Listening for suspicious notifications in real-time',
                style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.3),
              )),
            ]),
          ),
          const SizedBox(height: 16),

          Expanded(child: ap.alerts.isEmpty
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: AppTheme.safe.withValues(alpha: 0.08), shape: BoxShape.circle),
                  child: const Icon(Icons.check_circle_outline, size: 56, color: AppTheme.safe),
                ),
                const SizedBox(height: 20),
                Text('All Clear!', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                const Text('No suspicious notifications detected.\nKeep using your device — we\'re watching.',
                  style: TextStyle(fontSize: 14, color: AppTheme.textMuted, height: 1.5), textAlign: TextAlign.center),
              ]))
            : ListView.builder(
                itemCount: ap.alerts.length,
                itemBuilder: (ctx, i) {
                  final alert = ap.alerts[i];
                  return TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 400 + (i * 100).clamp(0, 500)),
                    curve: Curves.easeOutQuart,
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, value, child) {
                      return Transform.translate(
                        offset: Offset(0, 50 * (1 - value)),
                        child: Opacity(opacity: value, child: child),
                      );
                    },
                    child: Dismissible(
                      key: Key(alert.id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(left: 20),
                        alignment: Alignment.centerLeft,
                        decoration: BoxDecoration(color: AppTheme.riskHigh.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.delete, color: AppTheme.riskHigh),
                      ),
                      secondaryBackground: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(color: AppTheme.safe.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(14)),
                        child: const Icon(Icons.check_circle_outline, color: AppTheme.safe),
                      ),
                      onDismissed: (direction) {
                        // Both directions must remove the item from the list
                        // to satisfy Flutter's Dismissible contract.
                        context.read<AlertProvider>().deleteAlert(alert.id);
                      },
                      child: _alertCard(ctx, alert),
                    ),
                  );
                },
              ),
          ),
        ],
      ),
    );
  });
}

  Widget _alertCard(BuildContext ctx, RiskAlert alert) {
    final c = getRiskColor(alert.riskScore);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.withValues(alpha: 0.25))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: c.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(alert.riskScore == 0 ? Icons.info_outline : Icons.warning_amber, color: c, size: 22)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(alert.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: c.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(6)),
                child: Text(alert.riskType.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c))),
              const SizedBox(width: 8),
              Text(timeAgo(alert.timestamp), style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              const Spacer(),
              if (alert.dismissed) const Icon(Icons.check_circle, color: AppTheme.safe, size: 18),
            ]),
          ])),
        ]),
        const SizedBox(height: 12),
        Text(alert.body, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: AppTheme.background.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(8)),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(alert.riskScore == 0 ? Icons.info_outline : Icons.lightbulb_outline, color: c, size: 16),
            const SizedBox(width: 8),
            Expanded(child: Text(alert.explanation, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4))),
          ])),
        if (!alert.dismissed) ...[
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerRight, child: TextButton.icon(
            onPressed: () { 
              ctx.read<AlertProvider>().dismissAlert(alert.id); 
              ctx.read<ScoreProvider>().recalculate(ctx.read<AlertProvider>().alerts, ctx.read<GamificationProvider>(), ctx.read<TestsProvider>()); 
            },
            icon: const Icon(Icons.check, size: 18), label: const Text('Dismiss'),
            style: TextButton.styleFrom(foregroundColor: AppTheme.safe))),
        ],
      ]),
    );
  }
}

// ─── Profile Tab ──────────────────────────────────────────────────
class _ProfileTab extends StatefulWidget {
  @override
  State<_ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<_ProfileTab> {
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _checkBackend();
  }

  Future<void> _checkBackend() async {
    final ok = await ApiService.checkHealth();
    if (mounted) setState(() => _isBackendConnected = ok);
  }

  Future<void> _editName() async {
    final storage = context.read<LocalStorageService>();
    final controller = TextEditingController(text: storage.userName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Name', style: TextStyle(color: AppTheme.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            hintText: 'Enter your name',
            hintStyle: const TextStyle(color: AppTheme.textMuted),
            filled: true,
            fillColor: AppTheme.background,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      if (!mounted) return;
      await context.read<LocalStorageService>().setUserName(newName);
    }
  }

  Future<void> _pickAvatar() async {
    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512, maxHeight: 512, imageQuality: 80);
      if (photo != null) {
        if (!mounted) return;
        await context.read<LocalStorageService>().setUserAvatarPath(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  Widget _fadeSlideItem(Widget child, int delayIndex) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 500 + (delayIndex * 150)),
      curve: Curves.easeOutQuart,
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GamificationProvider, LocalStorageService>(
      builder: (context, gp, storage, _) {
        final level = (gp.xp / 100).floor() + 1;
        final xpInLevel = gp.xp % 100;
        final uName = storage.userName;
        final displayName = uName.isEmpty ? 'Digital Guardian' : uName;
        final avatarPath = storage.userAvatarPath;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _fadeSlideItem(Text('Profile', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)), 0),
              const SizedBox(height: 24),

              // ─── User Card ───
              _fadeSlideItem(
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.cardColor.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _pickAvatar,
                            child: Stack(
                              children: [
                                CircleAvatar(
                                  radius: 36,
                                  backgroundColor: AppTheme.cardColor,
                                  backgroundImage: avatarPath.isNotEmpty
                                      ? FileImage(File(avatarPath))
                                      : null,
                                  child: avatarPath.isEmpty
                                      ? const Icon(Icons.person, size: 28, color: AppTheme.primary)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0, right: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle, border: Border.all(color: AppTheme.background, width: 2)),
                                    child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: _editName,
                                  child: Row(
                                    children: [
                                      Flexible(child: Text(displayName, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: AppTheme.textPrimary), overflow: TextOverflow.ellipsis)),
                                      const SizedBox(width: 6),
                                      const Icon(Icons.edit, size: 16, color: AppTheme.textMuted),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('Level $level Digital Guardian', style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${gp.xp} XP Total', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                          Text('$xpInLevel / 100 to Level ${level + 1}', style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: xpInLevel / 100.0,
                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accent),
                          minHeight: 8,
                        ),
                      ),
                    ],
                  ),
                ),
                1,
              ),
              const SizedBox(height: 24),

              // ─── Backend Status ───
              _fadeSlideItem(
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.2)),
                  ),
                  child: Row(children: [
                    Icon(_isBackendConnected ? Icons.cloud_done : Icons.cloud_off,
                      color: _isBackendConnected ? AppTheme.safe : AppTheme.accent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_isBackendConnected ? 'Cloud Connected' : 'Offline Mode',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: _isBackendConnected ? AppTheme.safe : AppTheme.accent)),
                      const SizedBox(height: 2),
                      Text(
                        _isBackendConnected
                            ? 'Real-time threat scanning via cloud backend'
                            : 'Using built-in heuristics for offline analysis',
                        style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                    ])),
                    if (!_isBackendConnected)
                      IconButton(icon: const Icon(Icons.refresh, size: 18, color: AppTheme.accent), onPressed: _checkBackend, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                  ]),
                ),
                2,
              ),
              const SizedBox(height: 32),

              // ─── Score Overview ───
              _fadeSlideItem(Text('Score Breakdown', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)), 3),
              const SizedBox(height: 16),
              _fadeSlideItem(_buildScoreBreakdown(context), 4),
              const SizedBox(height: 32),

              // ─── Achievements ───
              _fadeSlideItem(Text('Achievements', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)), 5),
              const SizedBox(height: 16),
              _fadeSlideItem(_buildAchievementsGrid(context), 6),
              const SizedBox(height: 32),

              // ─── Statistics ───
              _fadeSlideItem(Text('Statistics', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)), 7),
              const SizedBox(height: 16),
              _fadeSlideItem(_buildStatsRow(context), 8),
              const SizedBox(height: 32),

              // ─── App Info ───
              _fadeSlideItem(_buildAppInfoSection(context), 9),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildScoreBreakdown(BuildContext context) {
    return Consumer<ScoreProvider>(
      builder: (context, sp, _) {
        final s = sp.score;
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardColor.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          ),
          child: Column(
            children: [
              _scoreRow('Safe Browsing', s.safeBrowsing, AppTheme.safe),
              const SizedBox(height: 12),
              _scoreRow('Threat Response', s.threatResponse, AppTheme.primary),
              const SizedBox(height: 12),
              _scoreRow('Test Performance', s.testPerformance, AppTheme.accent),
              const SizedBox(height: 12),
              _scoreRow('Learning', s.learningCompletion, const Color(0xFF4CAF50)),
              const SizedBox(height: 12),
              _scoreRow('Password Strength', s.passwordStrength, const Color(0xFF9C27B0)),
              const SizedBox(height: 16),
              const Divider(color: AppTheme.textMuted, height: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Overall Score', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
                  Text('${s.overallScore.round()}/100', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.primary)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _scoreRow(String label, double value, Color color) {
    return Row(
      children: [
        Expanded(flex: 3, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))),
        Expanded(
          flex: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100.0, backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color), minHeight: 6),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 36, child: Text('${value.round()}', textAlign: TextAlign.right, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color))),
      ],
    );
  }

  Widget _buildAchievementsGrid(BuildContext context) {
    return Consumer<GamificationProvider>(
      builder: (context, gp, _) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 16, crossAxisSpacing: 16, childAspectRatio: 1.6),
          itemCount: gp.achievements.length,
          itemBuilder: (context, index) {
            final a = gp.achievements[index];
            final color = a.isUnlocked ? AppTheme.accent : AppTheme.textMuted;
            final progress = a.requiredProgress > 0 ? (a.currentProgress / a.requiredProgress).clamp(0.0, 1.0) : 0.0;
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardColor.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withValues(alpha: a.isUnlocked ? 0.6 : 0.15)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Text(a.iconEmoji, style: const TextStyle(fontSize: 22)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(a.name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: a.isUnlocked ? AppTheme.textPrimary : AppTheme.textMuted), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  if (a.isUnlocked) const Icon(Icons.check_circle, color: AppTheme.safe, size: 16),
                ]),
                Text('${a.currentProgress}/${a.requiredProgress}', style: TextStyle(fontSize: 11, color: a.isUnlocked ? AppTheme.accent : AppTheme.textMuted)),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white.withValues(alpha: 0.08),
                    valueColor: AlwaysStoppedAnimation<Color>(a.isUnlocked ? AppTheme.safe : AppTheme.primary), minHeight: 5),
                ),
              ]),
            );
          },
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Consumer<AlertProvider>(
      builder: (context, ap, _) {
        final totalHandled = ap.alerts.where((a) => a.dismissed).length;
        return Consumer<GamificationProvider>(
          builder: (context, gp, _) {
            final lessons = gp.achievements.firstWhere((a) => a.id == 'security_scholar');
            final links = gp.achievements.firstWhere((a) => a.id == 'link_defender');
            return Row(children: [
              Expanded(child: _statBox('Threats\nAvoided', totalHandled.toString(), Icons.shield_outlined, AppTheme.safe)),
              const SizedBox(width: 12),
              Expanded(child: _statBox('Lessons\nDone', '${lessons.currentProgress}', Icons.school_outlined, AppTheme.primary)),
              const SizedBox(width: 12),
              Expanded(child: _statBox('Links\nScanned', '${links.currentProgress}', Icons.link, AppTheme.accent)),
            ]);
          },
        );
      },
    );
  }

  Widget _statBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.cardColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 10),
        Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, height: 1.3)),
      ]),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('About', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
        const SizedBox(height: 16),
        _infoRow(Icons.info_outline, 'Version', '2.0.0'),
        const SizedBox(height: 12),
        _infoRow(Icons.security, 'Engine', 'Smart Heuristics + URLhaus + DNS'),
        const SizedBox(height: 12),
        _infoRow(Icons.cloud, 'Backend', _isBackendConnected ? 'dlg-backend.onrender.com' : 'Offline'),
        const SizedBox(height: 12),
        _infoRow(Icons.privacy_tip, 'Privacy', 'All data stays on your device'),
        const SizedBox(height: 16),
        ScaleTap(
          onTap: () => Navigator.pushNamed(context, '/privacy'),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: const Row(children: [
              Icon(Icons.privacy_tip_outlined, color: AppTheme.primary, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Privacy Settings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.primary))),
              Icon(Icons.chevron_right, color: AppTheme.primary),
            ]),
          ),
        ),
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(children: [
      Icon(icon, color: AppTheme.textMuted, size: 18),
      const SizedBox(width: 12),
      Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textMuted)),
      const Spacer(),
      Flexible(child: Text(value, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
    ]);
  }
}

// ─── Insights Tab ────────────────────────────────────────
class _InsightsTab extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return Consumer<InsightProvider>(builder: (context, ip, _) {
      final i = ip.weeklyInsight;
      return SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          _fadeSlideItem(Text('Behavior Insights', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)), 0),
          const SizedBox(height: 4),
          _fadeSlideItem(const Text('Your digital safety trends', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)), 0),
          const SizedBox(height: 24),
          if (i != null) ...[
            _fadeSlideItem(_weeklyChart(i), 1),
            const SizedBox(height: 20),
            _fadeSlideItem(_breakdown('Phishing', i.phishingCount, Icons.phishing, AppTheme.riskHigh), 2),
            _fadeSlideItem(_breakdown('Scam Messages', i.scamCount, Icons.warning_amber, AppTheme.riskMedium), 3),
            _fadeSlideItem(_breakdown('Fake Rewards', i.fakeRewardCount, Icons.card_giftcard, const Color(0xFFFFD740)), 4),
            _fadeSlideItem(_breakdown('Urgency Tactics', i.urgencyCount, Icons.access_time_filled, AppTheme.accent), 5),
            _fadeSlideItem(_breakdown('Risky Links', i.riskyLinksCount, Icons.link_off, AppTheme.secondary), 6),
            const SizedBox(height: 20),
            _fadeSlideItem(Container(padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.cardColor.withValues(alpha: 0.4), borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.psychology, color: AppTheme.primary, size: 22),
                  SizedBox(width: 10),
                  Text('Behavioral Suggestion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                ]),
                const SizedBox(height: 12),
                Text(i.suggestion, style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.6)),
              ])), 7),
          ] else
            _fadeSlideItem(const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.insights_outlined, size: 64, color: AppTheme.textMuted),
              SizedBox(height: 16),
              Text('No insights yet', style: TextStyle(fontSize: 16, color: AppTheme.textMuted)),
            ])), 1),
        ]));
    });
  }

  Widget _weeklyChart(WeeklyInsight insight) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final max = insight.dailyAlertCounts.reduce((a, b) => a > b ? a : b);
    final maxY = (max + 2).toDouble();
    return Container(padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(16)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Weekly Alert Trend', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const SizedBox(height: 20),
        SizedBox(height: 160, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (idx) {
            final cnt = insight.dailyAlertCounts[idx];
            final h = maxY > 0 ? (cnt / maxY) * 140 : 0.0;
            return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(cnt.toString(), style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Container(height: h.clamp(4.0, 140.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.accent], begin: Alignment.bottomCenter, end: Alignment.topCenter),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))),
                const SizedBox(height: 8),
                Text(days[idx], style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ])));
          }))),
      ]));
  }

  Widget _breakdown(String label, int count, IconData icon, Color c) {
    return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(gradient: AppTheme.cardGradient, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: c, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: AppTheme.textPrimary))),
        Text(count.toString(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c)),
      ]));
  }
}


