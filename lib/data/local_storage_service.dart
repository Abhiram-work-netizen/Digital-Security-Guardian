import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/risk_alert.dart';
import '../models/literacy_score.dart';

/// Local storage service using SharedPreferences.
/// All data stays on device — nothing is ever uploaded.
class LocalStorageService with ChangeNotifier {
  static const String _alertsKey = 'risk_alerts';
  static const String _scoreKey = 'literacy_score';
  static const String _onboardingKey = 'onboarding_complete';
  static const String _xpKey = 'total_xp';
  static const String _achievementsKey = 'achievements';
  static const String _lastScanKey = 'last_scan_time';
  static const String _linksScannedKey = 'links_scanned';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // ─── Risk Alerts ───────────────────────────────────────────

  Future<List<RiskAlert>> getAlerts() async {
    final json = _prefs.getString(_alertsKey);
    if (json == null) return [];
    final list = jsonDecode(json) as List;
    return list.map((e) => RiskAlert.fromMap(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAlerts(List<RiskAlert> alerts) async {
    final json = jsonEncode(alerts.map((e) => e.toMap()).toList());
    await _prefs.setString(_alertsKey, json);
  }

  Future<void> addAlert(RiskAlert alert) async {
    final alerts = await getAlerts();
    alerts.insert(0, alert);
    // Keep only last 200 alerts
    if (alerts.length > 200) {
      alerts.removeRange(200, alerts.length);
    }
    await saveAlerts(alerts);
  }

  // ─── Literacy Score ────────────────────────────────────────

  Future<LiteracyScore> getScore() async {
    final json = _prefs.getString(_scoreKey);
    if (json == null) return LiteracyScore.initial();
    return LiteracyScore.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  Future<void> saveScore(LiteracyScore score) async {
    await _prefs.setString(_scoreKey, jsonEncode(score.toMap()));
  }

  // ─── Onboarding ────────────────────────────────────────────

  bool get isOnboardingComplete => _prefs.getBool(_onboardingKey) ?? false;

  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingKey, true);
  }

  // ─── Gamification ────────────────────────────────────────────

  int get totalXp => _prefs.getInt(_xpKey) ?? 0;

  Future<void> setTotalXp(int xp) async {
    await _prefs.setInt(_xpKey, xp);
  }

  Map<String, dynamic> getAchievements() {
    final jsonStr = _prefs.getString(_achievementsKey);
    if (jsonStr == null) return {};
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }

  Future<void> saveAchievements(Map<String, dynamic> map) async {
    await _prefs.setString(_achievementsKey, jsonEncode(map));
  }

  // ─── Scan Tracking ──────────────────────────────────────────

  DateTime? get lastScanTime {
    final ms = _prefs.getInt(_lastScanKey);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastScanTime(DateTime time) async {
    await _prefs.setInt(_lastScanKey, time.millisecondsSinceEpoch);
  }

  int get linksScanned => _prefs.getInt(_linksScannedKey) ?? 0;

  Future<void> incrementLinksScanned() async {
    await _prefs.setInt(_linksScannedKey, linksScanned + 1);
  }

  // ─── User Profile ──────────────────────────────────────────

  static const String _userNameKey = 'user_name';
  static const String _userAvatarKey = 'user_avatar_path';

  String get userName => _prefs.getString(_userNameKey) ?? '';
  Future<void> setUserName(String name) async {
    await _prefs.setString(_userNameKey, name);
    notifyListeners();
  }

  String get userAvatarPath => _prefs.getString(_userAvatarKey) ?? '';
  Future<void> setUserAvatarPath(String path) async {
    await _prefs.setString(_userAvatarKey, path);
    notifyListeners();
  }

  // ─── Security Tips Module ──────────────────────────────────
  static const String _completedLessonsKey = 'completed_lessons';

  List<String> getCompletedLessons() {
    return _prefs.getStringList(_completedLessonsKey) ?? [];
  }

  Future<void> saveCompletedLessons(List<String> lessons) async {
    await _prefs.setStringList(_completedLessonsKey, lessons);
    notifyListeners();
  }

  // ─── Security Tests Module ─────────────────────────────────
  static const String _completedTestsKey = 'completed_tests';
  
  List<String> getCompletedTestsJson() {
    return _prefs.getStringList(_completedTestsKey) ?? [];
  }
  
  Future<void> saveCompletedTestsJson(List<String> jsonList) async {
    await _prefs.setStringList(_completedTestsKey, jsonList);
    notifyListeners();
  }
}
