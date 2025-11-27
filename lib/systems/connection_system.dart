import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../components/connector.dart';

class ConnectionSystem extends Component with HasGameReference<SelfAssemblyGame> {
  final double attractionRange = 5.0;
  final double attractionForce = 100.0;
  final double connectionThreshold = 0.5;
  final double angleThreshold = 0.3;

  @override
  void update(double dt) {
    super.update(dt);

    final bodies = game.entityManager.bodies;
    if (bodies.isEmpty) return;

    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        final bodyA = bodies[i];
        final bodyB = bodies[j];

        if (!bodyA.isMounted || !bodyB.isMounted) continue;
        
        _checkConnectors(bodyA, bodyB);
      }
    }
  }

  void _checkConnectors(SelfAssemblyBody bodyA, SelfAssemblyBody bodyB) {
    final posA = bodyA.body.position;
    final angleA = bodyA.body.angle;
    final posB = bodyB.body.position;
    final angleB = bodyB.body.angle;

    for (final partA in bodyA.parts) {
      for (final connA in partA.connectors) {
        final rotatedA = Vector2(
          connA.relativePosition.x * cos(angleA) - connA.relativePosition.y * sin(angleA),
          connA.relativePosition.x * sin(angleA) + connA.relativePosition.y * cos(angleA),
        );
        final connAPos = posA + rotatedA;
        final connAAngle = angleA + connA.relativeAngle;

        for (final partB in bodyB.parts) {
          for (final connB in partB.connectors) {
            if (!_areCompatible(connA, connB)) continue;

            final rotatedB = Vector2(
              connB.relativePosition.x * cos(angleB) - connB.relativePosition.y * sin(angleB),
              connB.relativePosition.x * sin(angleB) + connB.relativePosition.y * cos(angleB),
            );
            final connBPos = posB + rotatedB;
            final connBAngle = angleB + connB.relativeAngle;

            final distVec = _getShortestVector(connAPos, connBPos);
            final dist = distVec.length;

            if (dist < connectionThreshold) {
              final angleDiff = _normalizeAngle(connAAngle - connBAngle);
              if ((angleDiff - pi).abs() < angleThreshold) {
                print('Connection detected!');
                return;
              }
            } else if (dist < attractionRange) {
              final forceDir = distVec.normalized();
              final force = forceDir * attractionForce * (1.0 - dist / attractionRange);

              bodyA.body.applyForce(force, point: connAPos);
              bodyB.body.applyForce(-force, point: connBPos);
            }
          }
        }
      }
    }
  }

  bool _areCompatible(Connector a, Connector b) {
    return (a.type == ConnectorType.plus && b.type == ConnectorType.minus) ||
           (a.type == ConnectorType.minus && b.type == ConnectorType.plus);
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) angle -= 2 * pi;
    while (angle < -pi) angle += 2 * pi;
    return angle;
  }

  Vector2 _getShortestVector(Vector2 from, Vector2 to) {
    final worldSize = game.worldSize;
    final halfWorldSize = worldSize / 2;
    
    var dx = to.x - from.x;
    var dy = to.y - from.y;

    if (dx > halfWorldSize.x) dx -= worldSize.x;
    else if (dx < -halfWorldSize.x) dx += worldSize.x;

    if (dy > halfWorldSize.y) dy -= worldSize.y;
    else if (dy < -halfWorldSize.y) dy += worldSize.y;

    return Vector2(dx, dy);
  }
}
