import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';

/// Start screen with title and start button
class StartScreen extends PositionComponent with TapCallbacks {
  final GameState gameState;
  final VoidCallback onStart;

  StartScreen({
    required this.gameState,
    required this.onStart,
  }) : super(priority: 200);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Title
    final title = TextComponent(
      text: 'Self-Assembly Game',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, -100),
    );
    add(title);

    // Instructions
    final instructions = TextComponent(
      text: 'Form hexamers to earn points!\nClick to spawn triangles (1 point each)\nYou have 2 minutes!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, 0),
    );
    add(instructions);

    // Start button
    final startButton = TextComponent(
      text: 'START GAME',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, 100),
    );
    add(startButton);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onStart();
  }
}
