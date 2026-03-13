import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'data/local_storage_service.dart';
import 'providers/alert_provider.dart';
import 'providers/score_provider.dart';
import 'providers/insight_provider.dart';
import 'providers/gamification_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/tests_provider.dart';
import 'services/notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for mobile
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style for dark theme
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF161B22),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize local storage
  final storage = LocalStorageService();
  await storage.init();

  // Initialize notification service
  await NotificationService.instance.init();

  final showOnboarding = !storage.isOnboardingComplete;

  // Create providers
  final alertProvider = AlertProvider(storage);
  final scoreProvider = ScoreProvider(storage);
  final insightProvider = InsightProvider();
  final gamificationProvider = GamificationProvider(storage);
  final learningProvider = LearningProvider(storage);
  final testsProvider = TestsProvider(storage);

  // Pre-load data if onboarding is already complete
  if (!showOnboarding) {
    await alertProvider.loadAlerts();
    await testsProvider.loadState();
    await scoreProvider.recalculate(alertProvider.alerts, gamificationProvider, testsProvider);
    insightProvider.generateInsight(alertProvider.alerts);
    await learningProvider.loadState();
  }

  // Wire up InsightProvider to automatically rebuild when AlertProvider updates
  alertProvider.addListener(() {
    insightProvider.generateInsight(alertProvider.alerts);
  });

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<LocalStorageService>.value(value: storage),
        ChangeNotifierProvider<AlertProvider>.value(value: alertProvider),
        ChangeNotifierProvider<ScoreProvider>.value(value: scoreProvider),
        ChangeNotifierProvider<InsightProvider>.value(value: insightProvider),
        ChangeNotifierProvider<GamificationProvider>.value(value: gamificationProvider),
        ChangeNotifierProvider<LearningProvider>.value(value: learningProvider),
        ChangeNotifierProvider<TestsProvider>.value(value: testsProvider),
      ],
      child: DLGApp(
        showOnboarding: showOnboarding,
      ),
    ),
  );
}
