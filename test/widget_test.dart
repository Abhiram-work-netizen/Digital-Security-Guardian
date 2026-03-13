import 'package:flutter_test/flutter_test.dart';
import 'package:digital_literacy_guardian/app.dart';

void main() {
  testWidgets('App loads and shows onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const DLGApp(showOnboarding: true));
    expect(find.text('Digital Literacy\nGuardian'), findsOneWidget);
  });
}
