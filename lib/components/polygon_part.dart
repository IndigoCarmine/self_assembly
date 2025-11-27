import 'package:flame/components.dart';
import 'connector.dart';

class PolygonPart {
  final List<Vector2> vertices;
  final List<Connector> connectors;
  final Vector2 relativePosition;
  final double relativeAngle;

  PolygonPart({
    required this.vertices,
    required this.connectors,
    Vector2? relativePosition,
    this.relativeAngle = 0,
  }) : relativePosition = relativePosition ?? Vector2.zero();
}
