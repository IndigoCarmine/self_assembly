import 'package:flutter/material.dart';
import '../state/game_state.dart';

/// Result screen widget
class ResultScreenWidget extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onRestart;

  const ResultScreenWidget({
    super.key,
    required this.gameState,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Game Over!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 56,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),
            Text(
              'Hexamers Formed: ${gameState.hexamersFormed}',
              style: const TextStyle(
                color: Colors.yellow,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              'Assembly Ratio: ${gameState.assemblyRatio.toStringAsFixed(2)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Monomers Spawned: ${gameState.monomersSpawned}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 22,
              ),
            ),
            const SizedBox(height: 80),
            ElevatedButton(
              onPressed: onRestart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              child: const Text('PLAY AGAIN'),
            ),
          ],
        ),
      ),
    );
  }
}
