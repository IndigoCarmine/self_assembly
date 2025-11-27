import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../components/connector.dart';

class ConnectionSystem extends Component with HasGameReference<SelfAssemblyGame> {
  final double attractionRange = 5.0;
  final double attractionForce = 100.0;

  @override
  void update(double dt) {
    super.update(dt);

    final bodies = game.entityManager.bodies;
    if (bodies.isEmpty) return;

    // Iterate all pairs of bodies
    for (var i = 0; i < bodies.length; i++) {
      for (var j = i + 1; j < bodies.length; j++) {
        final bodyA = bodies[i];
        final bodyB = bodies[j];

        if (!bodyA.isMounted || !bodyB.isMounted) continue;
        
        // Check all connector pairs between bodyA and bodyB
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
        // Calculate absolute position and angle of connA
        // Assuming part is centered at body origin for now (as per current impl)
        // If part had offset, we'd add it.
        
        final connAPos = posA + (connA.relativePosition..rotate(angleA));
        // final connAAngle = angleA + connA.relativeAngle;

        for (final partB in bodyB.parts) {
          for (final connB in partB.connectors) {
            // Check compatibility
            if (!_areCompatible(connA, connB)) continue;

            // Calculate absolute position of connB
            final rotatedB = Vector2(
              connB.relativePosition.x * cos(angleB) - connB.relativePosition.y * sin(angleB),
              connB.relativePosition.x * sin(angleB) + connB.relativePosition.y * cos(angleB),
            );
            final connBPos = posB + rotatedB;

            // Calculate distance with PBC
            final distVec = _getShortestVector(connAPos, connBPos);
            final dist = distVec.length;

            if (dist < attractionRange) {
              // Apply attraction force
              final forceDir = distVec.normalized();
              final force = forceDir * attractionForce * (1.0 - dist / attractionRange);

              // Apply force to bodies at connector positions
              bodyA.body.applyForce(force, point: connAPos);
              bodyB.body.applyForce(-force, point: connBPos);
            }
          }
        }
      }
    }
  }

  bool _areCompatible(Connector a, Connector b) {
    // Plus attracts Minus
    return (a.type == ConnectorType.plus && b.type == ConnectorType.minus) ||
           (a.type == ConnectorType.minus && b.type == ConnectorType.plus);
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
