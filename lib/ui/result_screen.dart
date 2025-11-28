import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';

/// Result screen showing final score
class ResultScreen extends PositionComponent with TapCallbacks {
  final GameState gameState;
  final VoidCallback onRestart;

  ResultScreen({
    required this.gameState,
    required this.onRestart,
  }) : super(priority: 200);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Title
    final title = TextComponent(
      text: 'Game Over!',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 48,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, -150),
    );
    add(title);

    // Hexamers count
    final hexamersText = TextComponent(
      text: 'Hexamers Formed: ${gameState.hexamersFormed}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, -50),
    );
    add(hexamersText);

    // Ratio
    final ratioText = TextComponent(
      text: 'Assembly Ratio: ${gameState.assemblyRatio.toStringAsFixed(2)}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, 10),
    );
    add(ratioText);

    // Monomers spawned
    final monomersText = TextComponent(
      text: 'Monomers Spawned: ${gameState.monomersSpawned}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, 50),
    );
    add(monomersText);

    // Play again button
    final playAgainButton = TextComponent(
      text: 'PLAY AGAIN',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.green,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
      ),
      anchor: Anchor.center,
      position: Vector2(0, 120),
    );
    add(playAgainButton);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onRestart();
  }
}
