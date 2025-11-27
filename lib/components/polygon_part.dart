import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'connector.dart';

class PolygonPart {
  final List<Vector2> vertices;
  final List<Connector> connectors;
  final Vector2 relativePosition;
  final double relativeAngle;
  Color color;

  PolygonPart({
    required this.vertices,
    required this.connectors,
    Vector2? relativePosition,
    this.relativeAngle = 0.0,
    this.color = Colors.white,
  }) : relativePosition = relativePosition ?? Vector2.zero();
}
