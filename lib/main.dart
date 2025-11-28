import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/self_assembly_game.dart';
import 'ui/start_screen_widget.dart';
import 'ui/result_screen_widget.dart';

void main() {
  runApp(const SelfAssemblyApp());
}

class SelfAssemblyApp extends StatefulWidget {
  const SelfAssemblyApp({super.key});

  @override
  State<SelfAssemblyApp> createState() => _SelfAssemblyAppState();
}

class _SelfAssemblyAppState extends State<SelfAssemblyApp> {
  late SelfAssemblyGame game;
  GameScreen currentScreen = GameScreen.start;

  @override
  void initState() {
    super.initState();
    game = SelfAssemblyGame(
      onScreenChange: (screen) {
        setState(() {
          currentScreen = screen;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Stack(
          children: [
            // Game widget (always present)
            GameWidget(game: game),
            
            // Overlay screens
            if (currentScreen == GameScreen.start)
              StartScreenWidget(
                gameState: game.gameState,
                onStart: game.startGame,
              ),
            
            if (currentScreen == GameScreen.result)
              ResultScreenWidget(
                gameState: game.gameState,
                onRestart: game.restartGame,
              ),
          ],
        ),
      ),
    );
  }
}
