import 'package:flame/components.dart';

enum ConnectorType {
  plus,
  minus,
}

enum ConnectorState {
  idle,
  attracting,
  connected,
}

class Connector {
  final Vector2 relativePosition;
  final double relativeAngle;
  final ConnectorType type;
  ConnectorState state = ConnectorState.idle;
  
  // ID of the connected connector (if any)
  // In a real implementation, we might want a direct reference or a weak reference,
  // but for now, we'll just track state.
  
  Connector({
    required this.relativePosition,
    required this.relativeAngle,
    required this.type,
  });
}
