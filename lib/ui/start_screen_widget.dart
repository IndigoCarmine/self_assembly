import 'package:flutter/material.dart';
import '../state/game_state.dart';

/// Start screen widget
class StartScreenWidget extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onStart;

  const StartScreenWidget({
    super.key,
    required this.gameState,
    required this.onStart,
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
              'Self-Assembly Game',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            const Text(
              'Form hexamers to earn points!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const Text(
              'Click to spawn triangles (1 point each)',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'You have 2 minutes!',
              style: TextStyle(
                color: Colors.yellow,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 60),
            ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                textStyle: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              child: const Text('START GAME'),
            ),
          ],
        ),
      ),
    );
  }
}
