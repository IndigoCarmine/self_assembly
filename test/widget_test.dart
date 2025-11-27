import 'package:flutter_test/flutter_test.dart';
import 'package:flame/game.dart';
import 'package:self_assembly/game/self_assembly_game.dart';

void main() {
  testWidgets('Game widget smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const GameWidget.controlled(gameFactory: SelfAssemblyGame.new));

    // Verify that the game widget is present.
    expect(find.byType(GameWidget<SelfAssemblyGame>), findsOneWidget);
  });
}
