import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_theme.dart';
import '../data/local_storage_service.dart';
import 'package:provider/provider.dart';
import '../providers/alert_provider.dart';
import '../providers/score_provider.dart';
import '../providers/gamification_provider.dart';
import '../providers/tests_provider.dart';
import '../providers/insight_provider.dart';
import '../services/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/services.dart';

/// Permission Setup Screen — explains and requests all required permissions.
class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  static const MethodChannel _methodChannel = MethodChannel('com.dlg.digital_literacy_guardian/methods');
  bool _isNotificationAccessGranted = false;
  bool _isPushNotificationGranted = false;
  bool _isCameraGranted = false;
  bool _isStorageGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    // Check notification listener
    try {
      final bool isEnabled = await _methodChannel.invokeMethod('isNotificationListenerEnabled');
      _isNotificationAccessGranted = isEnabled;
    } on PlatformException catch (e) {
      debugPrint("Failed to check permission: '${e.message}'.");
    }

    // Check push notification permission (Android 13+)
    _isPushNotificationGranted = await Permission.notification.isGranted;

    // Check camera
    _isCameraGranted = await Permission.camera.isGranted;

    // Check storage (photos/media)
    _isStorageGranted = await Permission.photos.isGranted || await Permission.storage.isGranted;

    if (mounted) setState(() {});
  }

  Future<void> _openNotificationSettings() async {
    try {
      await _methodChannel.invokeMethod('openNotificationListenerSettings');
    } on PlatformException catch (e) {
      debugPrint("Failed to open settings: '${e.message}'.");
    }
  }

  Future<void> _requestCamera() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() => _isCameraGranted = status.isGranted);
    }
  }

  Future<void> _requestPushNotification() async {
    final granted = await NotificationService.instance.requestPermission();
    if (mounted) {
      setState(() => _isPushNotificationGranted = granted);
    }
  }

  Future<void> _requestStorage() async {
    // Android 13+ uses READ_MEDIA_IMAGES, older uses READ_EXTERNAL_STORAGE
    PermissionStatus status = await Permission.photos.request();
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    if (mounted) {
      setState(() => _isStorageGranted = status.isGranted);
    }
  }

  bool get _allCriticalGranted => _isCameraGranted && _isStorageGranted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.backgroundGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 24),
                // Header
                Text(
                  'Permission Setup',
                  style: GoogleFonts.inter(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'To protect you, we need a few permissions',
                  style: TextStyle(fontSize: 15, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 32),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // 1. Notification Access Card
                        _PermissionCard(
                          icon: Icons.notifications_active_outlined,
                          title: 'Notification Access',
                          description:
                              'Analyze incoming notifications for scam patterns. '
                              'No notification content is ever saved or uploaded.',
                          gradient: const [AppTheme.primary, AppTheme.accent],
                          isGranted: _isNotificationAccessGranted,
                          onEnable: _openNotificationSettings,
                        ),
                        const SizedBox(height: 14),

                        // 2. Push Notification Permission Card
                        _PermissionCard(
                          icon: Icons.notifications_outlined,
                          title: 'Push Notifications',
                          description:
                              'Receive instant alerts when threats are detected. '
                              'We\'ll notify you in real-time about phishing, scams, and suspicious links.',
                          gradient: const [Color(0xFFFF6D00), Color(0xFFFFAB40)],
                          isGranted: _isPushNotificationGranted,
                          onEnable: _requestPushNotification,
                        ),
                        const SizedBox(height: 14),

                        // 2. Camera Permission Card
                        _PermissionCard(
                          icon: Icons.camera_alt_outlined,
                          title: 'Camera Access',
                          description:
                              'Capture photos of suspicious documents, QR codes, '
                              'or screenshots for instant security analysis.',
                          gradient: const [Color(0xFF00BFA6), Color(0xFF00E5FF)],
                          isGranted: _isCameraGranted,
                          onEnable: _requestCamera,
                        ),
                        const SizedBox(height: 14),

                        // 3. Storage/Photos Permission Card
                        _PermissionCard(
                          icon: Icons.folder_outlined,
                          title: 'File & Photo Access',
                          description:
                              'Upload documents, PDFs, and screenshots from your device '
                              'for malware and phishing analysis.',
                          gradient: const [AppTheme.secondary, Color(0xFF7C4DFF)],
                          isGranted: _isStorageGranted,
                          onEnable: _requestStorage,
                        ),
                        const SizedBox(height: 14),

                        // 5. Internet (always granted)
                        const _PermissionCard(
                          icon: Icons.public_outlined,
                          title: 'Internet Access',
                          description:
                              'Used only to check domain reputation when you manually scan a link. '
                              'No personal data is ever transmitted.',
                          gradient: [Color(0xFF42A5F5), Color(0xFF1565C0)],
                          isGranted: true,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Privacy note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.lock_outline, color: AppTheme.primary, size: 20),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'All analysis happens locally on your device. '
                          'We never store or upload your personal content.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Continue button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Mark onboarding as complete
                      final storage = context.read<LocalStorageService>();
                      await storage.setOnboardingComplete();

                      // Load initial data
                      if (context.mounted) {
                        final alertProvider = context.read<AlertProvider>();
                        await alertProvider.loadAlerts();
                        if (context.mounted) {
                          final scoreProvider = context.read<ScoreProvider>();
                          await scoreProvider.recalculate(alertProvider.alerts, context.read<GamificationProvider>(), context.read<TestsProvider>());
                          
                          if (!context.mounted) return;
                          final insightProvider = context.read<InsightProvider>();
                          insightProvider.generateInsight(alertProvider.alerts);
                          
                          if (!context.mounted) return;
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _allCriticalGranted ? AppTheme.primary : AppTheme.textMuted,
                      foregroundColor: AppTheme.background,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      _allCriticalGranted ? 'Continue to Dashboard' : 'Grant Permissions to Continue',
                      style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final List<Color> gradient;
  final VoidCallback? onEnable;
  final bool isGranted;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.gradient,
    this.onEnable,
    this.isGranted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppTheme.cardGradient,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGranted ? AppTheme.safe.withValues(alpha: 0.3) : gradient.first.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                ),
              ),
              if (isGranted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.safe.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppTheme.safe, size: 14),
                      SizedBox(width: 4),
                      Text('Granted', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.safe)),
                    ],
                  ),
                )
              else if (onEnable != null)
                TextButton(
                  onPressed: onEnable,
                  style: TextButton.styleFrom(
                    backgroundColor: gradient.first.withValues(alpha: 0.15),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    'Enable',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: gradient.first),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5),
          ),
        ],
      ),
    );
  }
}
