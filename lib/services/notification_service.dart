import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/risk_alert.dart';

/// Local push notification service — sends alerts to the user
/// when threats are detected in real-time.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Android notification channel for threat alerts.
  static const AndroidNotificationChannel _threatChannel = AndroidNotificationChannel(
    'dlg_threat_alerts',
    'DLG Threat Alerts',
    description: 'Real-time warnings when suspicious notifications or links are detected',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  /// Initialize the notification plugin and create channels.
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Create the notification channel on Android 8+
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      AndroidNotificationChannel(
        _threatChannel.id,
        _threatChannel.name,
        description: _threatChannel.description,
        importance: _threatChannel.importance,
        playSound: _threatChannel.playSound,
        enableVibration: _threatChannel.enableVibration,
      ),
    );

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Request notification permission (Android 13+).
  Future<bool> requestPermission() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.requestNotificationsPermission();
    return granted ?? true;
  }

  /// Show a threat notification when a risky alert is detected.
  Future<void> showThreatNotification(RiskAlert alert) async {
    if (!_initialized) return;

    final riskLabel = alert.riskType.label;
    final emoji = alert.riskType.icon;

    await _plugin.show(
      alert.id.hashCode,
      '$emoji $riskLabel Detected',
      '${alert.title}: ${alert.body}',
      NotificationDetails(
        android: AndroidNotificationDetails(
          _threatChannel.id,
          _threatChannel.name,
          channelDescription: _threatChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'DLG Threat Alert',
          styleInformation: BigTextStyleInformation(
            alert.explanation,
            contentTitle: '$emoji $riskLabel — ${alert.title}',
            summaryText: 'Risk Score: ${(alert.riskScore * 100).round()}%',
          ),
        ),
      ),
    );
  }

  /// Show a daily summary notification.
  Future<void> showSummaryNotification({
    required int totalThreats,
    required int highRiskCount,
  }) async {
    if (!_initialized) return;

    final title = totalThreats == 0
        ? '✅ All Clear Today!'
        : '🛡️ Daily Security Summary';
    final body = totalThreats == 0
        ? 'No threats detected. Your digital safety score is holding strong.'
        : '$totalThreats threat${totalThreats > 1 ? 's' : ''} detected today '
            '($highRiskCount high-risk). Open DLG to review.';

    await _plugin.show(
      999999, // Fixed ID for summary
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _threatChannel.id,
          _threatChannel.name,
          channelDescription: _threatChannel.description,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    // The app will naturally open to HomeScreen since that's the default route.
  }
}
