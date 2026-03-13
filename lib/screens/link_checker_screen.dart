import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/score_provider.dart';
import '../providers/alert_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/tests_provider.dart';
import '../services/api_service.dart';
import '../utils/app_theme.dart';

/// Link Checker Screen — paste a URL and get an instant safety analysis
/// powered by the backend API (VirusTotal + Google Safe Browsing + heuristics).
class LinkCheckerScreen extends StatefulWidget {
  const LinkCheckerScreen({super.key});

  @override
  State<LinkCheckerScreen> createState() => _LinkCheckerScreenState();
}

class _LinkCheckerScreenState extends State<LinkCheckerScreen> {
  final TextEditingController _urlController = TextEditingController();
  Map<String, dynamic>? _result;
  bool _isChecking = false;
  bool _isBackendConnected = false;

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
  }

  Future<void> _checkBackendStatus() async {
    final connected = await ApiService.checkHealth();
    if (mounted) {
      setState(() => _isBackendConnected = connected);
    }
  }

  Future<void> _checkLink() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) return;

    setState(() {
      _isChecking = true;
      _result = null;
    });

    try {
      final result = await ApiService.scanLink(url);

      if (mounted) {
        final gp = context.read<GamificationProvider>();
        gp.addXp(5);
        gp.updateAchievementProgress('link_defender', 1);
        context.read<ScoreProvider>().recalculate(
          context.read<AlertProvider>().alerts,
          gp,
          context.read<TestsProvider>()
        );

        setState(() {
          _result = result;
          _isChecking = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isChecking = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan error: $e')),
        );
      }
    }
  }

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Backend status indicator
                    _fadeSlideItem(_buildBackendStatus(), 0),
                    const SizedBox(height: 16),

                    _fadeSlideItem(_buildUrlInput(), 1),
                    const SizedBox(height: 16),

                    // Scan button
                    _fadeSlideItem(
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _isChecking ? null : _checkLink,
                          icon: const Icon(Icons.security),
                          label: Text(
                            _isChecking ? 'Scanning...' : 'Scan URL',
                            style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      2,
                    ),
                    const SizedBox(height: 24),

                    if (_isChecking)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Column(
                            children: [
                              CircularProgressIndicator(color: AppTheme.primary),
                              SizedBox(height: 16),
                              Text(
                                'Scanning with threat intelligence APIs...',
                                style: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (_result != null)
                      _fadeSlideItem(_buildResultCard(_result!), 3),
                  ],
                ),
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
                'Link Checker',
                style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
              ),
            ],
          ),
          // Connection status dot
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(
                    color: _isBackendConnected ? AppTheme.safe : AppTheme.accent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _isBackendConnected ? 'Online' : 'Offline',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _isBackendConnected ? AppTheme.safe : AppTheme.accent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackendStatus() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (_isBackendConnected ? AppTheme.safe : AppTheme.accent).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isBackendConnected ? Icons.cloud_done : Icons.cloud_off,
            color: _isBackendConnected ? AppTheme.safe : AppTheme.accent,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _isBackendConnected
                  ? 'Connected — Smart Heuristics, URLhaus, DNS Check active'
                  : 'Offline mode — using built-in heuristic analysis',
              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
            ),
          ),
          if (!_isBackendConnected)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.accent, size: 18),
              onPressed: _checkBackendStatus,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }

  Widget _buildUrlInput() {
    final hasResult = _result != null;
    final riskLevel = _result?['riskLevel'] ?? 'LOW';
    final borderColor = hasResult
        ? (riskLevel == 'HIGH' ? AppTheme.riskHigh : riskLevel == 'MEDIUM' ? AppTheme.accent : AppTheme.safe)
        : AppTheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
        boxShadow: [
          BoxShadow(color: borderColor.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 5))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: TextField(
        controller: _urlController,
        style: GoogleFonts.inter(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Paste URL to scan...',
          hintStyle: const TextStyle(color: AppTheme.textMuted, fontSize: 15),
          suffixIcon: _urlController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.textMuted, size: 20),
                  onPressed: () => setState(() { _urlController.clear(); _result = null; }),
                )
              : null,
        ),
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _checkLink(),
      ),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    final riskLevel = result['riskLevel'] as String? ?? 'LOW';
    final riskScore = (result['riskScore'] as num?)?.toInt() ?? 0;
    final checks = (result['checks'] as List<dynamic>?) ?? [];
    final isOffline = result['offline'] == true;
    final isDanger = riskLevel == 'HIGH' || riskLevel == 'MEDIUM';
    final color = riskLevel == 'HIGH' ? AppTheme.riskHigh : riskLevel == 'MEDIUM' ? AppTheme.accent : AppTheme.safe;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(isDanger ? Icons.gpp_bad : Icons.verified_user, color: color, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isDanger ? 'Potentially Dangerous' : 'Appears Safe',
                          style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: color),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Risk Score: $riskScore/100',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: color.withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Risk score bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: riskScore / 100.0,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 6,
                ),
              ),
              if (isOffline) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off, size: 12, color: AppTheme.accent),
                      SizedBox(width: 6),
                      Text('Scanned in offline mode', style: TextStyle(fontSize: 11, color: AppTheme.accent)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Scan sources
        if (checks.isNotEmpty) ...[
          Text('Scan Sources', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),

          for (final check in checks)
            _buildCheckRow(check as Map<String, dynamic>),

          const SizedBox(height: 16),
        ],

        // Warnings
        if (checks.any((c) => (c as Map)['warnings'] != null && (c['warnings'] as List).isNotEmpty)) ...[
          Text('Risk Indicators', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          for (final check in checks)
            if (check is Map && check['warnings'] != null)
              for (final w in check['warnings'])
                _indicatorRow(Icons.warning_amber_rounded, w.toString(), AppTheme.riskHigh),
        ],

        // Scan another
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => setState(() {
              _urlController.clear();
              _result = null;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Scan Another URL'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckRow(Map<String, dynamic> check) {
    final source = check['source'] as String? ?? 'Unknown';
    final status = check['status'] as String? ?? 'unknown';
    final detail = check['detail'] as String? ?? '';

    Color statusColor;
    IconData statusIcon;
    switch (status) {
      case 'safe':
        statusColor = AppTheme.safe;
        statusIcon = Icons.check_circle;
        break;
      case 'warning':
      case 'suspicious':
        statusColor = AppTheme.accent;
        statusIcon = Icons.warning_amber;
        break;
      case 'dangerous':
        statusColor = AppTheme.riskHigh;
        statusIcon = Icons.dangerous;
        break;
      case 'unavailable':
      case 'pending':
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.cloud_off;
        break;
      default:
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.help_outline;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardColor.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(source, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: statusColor)),
                if (detail.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(detail, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.3)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _indicatorRow(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.4)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }
}
