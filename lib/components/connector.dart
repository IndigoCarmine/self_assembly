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
  bool isConnected = false; // Track if this connector is connected
  
  Connector({
    required this.relativePosition,
    required this.relativeAngle,
    required this.type,
  });
}
