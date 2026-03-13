import 'package:flutter/material.dart';

/// App-wide constants and utility helpers
class AppConstants {
  static const String appName = 'DLG';
  static const String appTagline = 'Your Privacy-First Digital Safety Assistant';

  // Route names
  static const String onboardingRoute = '/onboarding';
  static const String permissionRoute = '/permissions';
  static const String homeRoute = '/home';
  static const String alertsRoute = '/alerts';
  static const String insightsRoute = '/insights';
  static const String tipsRoute = '/tips';
  static const String privacyRoute = '/privacy';
  static const String linkCheckerRoute = '/link-checker';
}

/// Utility to get risk color from score
Color getRiskColor(double score) {
  if (score >= 0.8) return const Color(0xFFFF5252);
  if (score >= 0.6) return const Color(0xFFFFAB40);
  if (score >= 0.4) return const Color(0xFFFFD740);
  return const Color(0xFF69F0AE);
}

/// Utility to get score color
Color getScoreColor(double score) {
  if (score >= 80) return const Color(0xFF00E676);
  if (score >= 60) return const Color(0xFF69F0AE);
  if (score >= 40) return const Color(0xFFFFD740);
  if (score >= 20) return const Color(0xFFFFAB40);
  return const Color(0xFFFF5252);
}

/// Format relative time
String timeAgo(DateTime dateTime) {
  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${(diff.inDays / 7).floor()}w ago';
}
