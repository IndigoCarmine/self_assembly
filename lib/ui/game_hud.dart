import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../state/game_state.dart';

/// HUD component to display game statistics
class GameHUD extends PositionComponent {
  final GameState gameState;
  late TextComponent _pointsText;
  late TextComponent _hexamersText;
  late TextComponent _ratioText;
  late TextComponent _timerText;

  GameHUD({
    required this.gameState,
  }) : super(priority: 100); // High priority to render on top

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Position on the right side
    position = Vector2(10, 10);

    // Timer display (most important, at top)
    _timerText = TextComponent(
      text: 'Time: ${gameState.formattedTime}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
    add(_timerText);

    // Points display
    _pointsText = TextComponent(
      text: 'Points: ${gameState.points}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, 35),
    );
    add(_pointsText);

    // Hexamers display
    _hexamersText = TextComponent(
      text: 'Hexamers: ${gameState.hexamersFormed}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, 65),
    );
    add(_hexamersText);

    // Ratio display
    _ratioText = TextComponent(
      text: 'Ratio: ${gameState.assemblyRatio.toStringAsFixed(2)}',
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      position: Vector2(0, 95),
    );
    add(_ratioText);

    // Listen to game state changes
    gameState.addListener(_updateDisplay);
  }

  void _updateDisplay() {
    _timerText.text = 'Time: ${gameState.formattedTime}';
    _pointsText.text = 'Points: ${gameState.points}';
    _hexamersText.text = 'Hexamers: ${gameState.hexamersFormed}';
    _ratioText.text = 'Ratio: ${gameState.assemblyRatio.toStringAsFixed(2)}';
  }

  @override
  void onRemove() {
    gameState.removeListener(_updateDisplay);
    super.onRemove();
  }
}
