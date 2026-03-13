import 'package:flutter/material.dart';
import 'utils/app_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/permission_screen.dart';
import 'screens/home_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/tips_screen.dart';
import 'screens/privacy_panel_screen.dart';
import 'screens/link_checker_screen.dart';
import 'screens/document_verify_screen.dart';
import 'screens/tests_screen.dart';

/// App root widget with routing.
class DLGApp extends StatelessWidget {
  final bool showOnboarding;

  const DLGApp({
    super.key, 
    required this.showOnboarding,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DLG',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: showOnboarding ? '/onboarding' : '/home',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/permissions': (context) => const PermissionScreen(),
        '/home': (context) => const HomeScreen(),
        '/alerts': (context) => const AlertsScreen(),
        '/insights': (context) => const InsightsScreen(),
        '/tips': (context) => const TipsScreen(),
        '/privacy': (context) => const PrivacyPanelScreen(),
        '/link-checker': (context) => const LinkCheckerScreen(),
        '/document-verify': (context) => const DocumentVerifyScreen(),
        '/tests': (context) => const TestsScreen(),
      },
    );
  }
}
