import 'package:flutter_test/flutter_test.dart';
import 'package:self_assembly/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SelfAssemblyApp());

    // Verify that the app is present.
    expect(find.byType(SelfAssemblyApp), findsOneWidget);
  });
}
