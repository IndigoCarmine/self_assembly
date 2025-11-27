import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../components/connector.dart';
import '../components/polygon_part.dart';

class ConnectionSystem extends Component with HasGameReference<SelfAssemblyGame> {
  final double attractionRange = 5.0;
  final double attractionForce = 10.0; // Reduced from 100.0
  final double repulsionRange = 3.0;
  final double repulsionForce = 15.0;
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

  void _connectBodies(
    SelfAssemblyBody bodyA,
    SelfAssemblyBody bodyB,
    Connector connA,
    Connector connB,
    Vector2 connAPos,
    Vector2 connBPos,
  ) {
    // Calculate the transformation needed to align connB to connA
    final posA = bodyA.body.position;
    final angleA = bodyA.body.angle;
    final posB = bodyB.body.position;
    final angleB = bodyB.body.angle;

    // Combined parts from both bodies
    final combinedParts = <PolygonPart>[];
    
    // Mark the connecting connectors as connected
    connA.isConnected = true;
    connB.isConnected = true;
    
    // Generate a new color for the merged body
    final random = Random();
    final newColor = Color.fromARGB(
      255,
      100 + random.nextInt(156), // 100-255
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
    
    // Add parts from bodyA (update color)
    for (final part in bodyA.parts) {
      part.color = newColor;
    }
    combinedParts.addAll(bodyA.parts);
    
    // Add parts from bodyB with transformation
    // We need to transform bodyB's parts to bodyA's local coordinate system
    final deltaPos = posB - posA;
    final deltaAngle = angleB - angleA;
    
    for (final partB in bodyB.parts) {
      // Transform vertices
      final transformedVertices = <Vector2>[];
      for (final v in partB.vertices) {
        // Rotate by deltaAngle, then translate by deltaPos
        final rotated = Vector2(
          v.x * cos(deltaAngle) - v.y * sin(deltaAngle),
          v.x * sin(deltaAngle) + v.y * cos(deltaAngle),
        );
        transformedVertices.add(rotated + deltaPos);
      }
      
      // Transform connectors
      final transformedConnectors = <Connector>[];
      for (final conn in partB.connectors) {
        final rotatedPos = Vector2(
          conn.relativePosition.x * cos(deltaAngle) - conn.relativePosition.y * sin(deltaAngle),
          conn.relativePosition.x * sin(deltaAngle) + conn.relativePosition.y * cos(deltaAngle),
        );
        transformedConnectors.add(Connector(
          relativePosition: rotatedPos + deltaPos,
          relativeAngle: conn.relativeAngle + deltaAngle,
          type: conn.type,
        ));
      }
      
      combinedParts.add(PolygonPart(
        vertices: transformedVertices,
        connectors: transformedConnectors,
        color: newColor,
      ));
    }
    
    // Calculate combined velocity (momentum conservation)
    final massA = bodyA.body.mass;
    final massB = bodyB.body.mass;
    final totalMass = massA + massB;
    
    final velA = bodyA.body.linearVelocity;
    final velB = bodyB.body.linearVelocity;
    final combinedVel = (velA * massA + velB * massB) / totalMass;
    
    final angVelA = bodyA.body.angularVelocity;
    final angVelB = bodyB.body.angularVelocity;
    final combinedAngVel = (angVelA * massA + angVelB * massB) / totalMass;
    
    // Create new combined body
    final newBody = SelfAssemblyBody(
      parts: combinedParts,
      initialPosition: posA,
      initialLinearVelocity: combinedVel,
      initialAngularVelocity: combinedAngVel,
    );
    
    // Remove old bodies and add new one
    game.entityManager.removeBody(bodyA);
    game.entityManager.removeBody(bodyB);
    game.entityManager.addBody(newBody);
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
