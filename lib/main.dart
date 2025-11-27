import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'game/self_assembly_game.dart';

void main() {
  runApp(const GameWidget.controlled(gameFactory: SelfAssemblyGame.new));
}
