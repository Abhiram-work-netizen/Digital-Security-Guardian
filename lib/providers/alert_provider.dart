import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/risk_alert.dart';
import '../data/local_storage_service.dart';
import '../services/notification_analyzer.dart';
import '../services/notification_service.dart';

/// Alert Provider — manages risk alerts state and persistence.
class AlertProvider extends ChangeNotifier {
  final LocalStorageService _storage;
  List<RiskAlert> _alerts = [];
  bool _isLoaded = false;

  AlertProvider(this._storage);

  List<RiskAlert> get alerts => _alerts;
  List<RiskAlert> get activeAlerts => _alerts.where((a) => !a.dismissed).toList();
  int get activeCount => activeAlerts.length;
  bool get isLoaded => _isLoaded;

  static const EventChannel _notificationChannel = EventChannel('com.dlg.digital_literacy_guardian/notifications');
  final NotificationAnalyzer _analyzer = NotificationAnalyzer();

  Future<void> loadAlerts() async {
    _alerts = await _storage.getAlerts();
    _isLoaded = true;
    notifyListeners();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    _notificationChannel.receiveBroadcastStream().listen((dynamic event) {
      if (event is Map) {
        final title = event['title'] as String? ?? '';
        final body = event['text'] as String? ?? '';
        
        final alert = _analyzer.analyzeNotification(title, body);
        if (alert != null) {
          addAlert(alert);
        }
      }
    }, onError: (dynamic error) {
      debugPrint('Notification listening error: $error');
    });
  }

  Future<void> addAlert(RiskAlert alert) async {
    _alerts.insert(0, alert);
    await _storage.saveAlerts(_alerts);
    notifyListeners();

    // Send a local push notification for risky alerts
    if (alert.riskScore >= 0.5) {
      NotificationService.instance.showThreatNotification(alert);
    }
  }

  Future<void> dismissAlert(String id) async {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      _alerts[index].dismissed = true;
      await _storage.saveAlerts(_alerts);
      notifyListeners();
    }
  }

  Future<void> deleteAlert(String id) async {
    _alerts.removeWhere((a) => a.id == id);
    await _storage.saveAlerts(_alerts);
    notifyListeners();
  }

  Future<void> clearAll() async {
    _alerts.clear();
    await _storage.saveAlerts(_alerts);
    notifyListeners();
  }

  /// Get alerts from the last N days
  List<RiskAlert> getRecentAlerts(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _alerts.where((a) => a.timestamp.isAfter(cutoff)).toList();
  }
}
