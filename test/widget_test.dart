import 'package:driving_rule/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App opens directly to home page', (WidgetTester tester) async {
    await tester.pumpWidget(const DrivingRuleApp());

    expect(find.text('Driving Rule'), findsOneWidget);
    expect(find.text('Welcome to Driving Rule'), findsOneWidget);
    expect(find.text('Login'), findsNothing);
    expect(find.text('Register'), findsNothing);
  });
}
