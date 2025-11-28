import 'dart:math';
import 'package:flame/components.dart';
import '../interfaces/interfaces.dart';

import '../events/event_bus.dart';

class ConnectionSystem extends Component implements IConnectionSystem {
  final IEntityManager entityManager;
  final IDistanceCalculator distanceCalculator;
  final IForceModel forceModel;
  final IConnectorCompatibility connectorCompatibility;
  final IBodyMerger bodyMerger;
  final IEventBus eventBus;
  final ConnectionSystemConfig config;

  ConnectionSystem({
    required this.entityManager,
    required this.distanceCalculator,
    required this.forceModel,
    required this.connectorCompatibility,
    required this.bodyMerger,
    required this.eventBus,
    this.config = const ConnectionSystemConfig(),
  });

  @override
  void update(double dt) {
    super.update(dt);

    final bodies = entityManager.bodies;
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

  void _checkConnectors(IAssemblyBody bodyA, IAssemblyBody bodyB) {
    final physicsA = bodyA.physicsBody;
    final physicsB = bodyB.physicsBody;
    final posA = physicsA.position;
    final angleA = physicsA.angle;
    final posB = physicsB.position;
    final angleB = physicsB.angle;

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
            // Skip if either connector is already connected
            if (connA.isConnected || connB.isConnected) continue;

            final rotatedB = Vector2(
              connB.relativePosition.x * cos(angleB) - connB.relativePosition.y * sin(angleB),
              connB.relativePosition.x * sin(angleB) + connB.relativePosition.y * cos(angleB),
            );
            final connBPos = posB + rotatedB;
            final connBAngle = angleB + connB.relativeAngle;

            final distVec = distanceCalculator.getShortestVector(connAPos, connBPos);
            final dist = distVec.length;

            // Check compatibility
            if (connectorCompatibility.shouldRepel(connA.type, connB.type) && dist < config.repulsionRange) {
              // Apply repulsion force
              final forceDir = distVec.normalized();
              final forceFactor = forceModel.calculateForce(dist, config.repulsionRange);
              final force = forceDir * config.repulsionForce * forceFactor;
              
              physicsA.applyForce(-force, point: connAPos); // Push away
              physicsB.applyForce(force, point: connBPos);
            } else if (connectorCompatibility.shouldAttract(connA.type, connB.type)) {
               if (dist < config.connectionThreshold) {
                // Check angle alignment
                final angleDiff = _normalizeAngle(connAAngle - connBAngle);
                if ((angleDiff - pi).abs() < config.angleThreshold) {
                  // Align bodies before merging
                  // Calculate the required angle for bodyB so connB faces opposite to connA
                  final targetAngleB = connAAngle + pi - connB.relativeAngle;
                  
                  // Calculate the required position for bodyB
                  // After setting bodyB's angle to targetAngleB, connB's world position will be:
                  // targetPosB + rotate(connB.relativePosition, targetAngleB)
                  // We want this to equal connAPos
                  final rotatedConnBPos = Vector2(
                    connB.relativePosition.x * cos(targetAngleB) - connB.relativePosition.y * sin(targetAngleB),
                    connB.relativePosition.x * sin(targetAngleB) + connB.relativePosition.y * cos(targetAngleB),
                  );
                  final targetPosB = connAPos - rotatedConnBPos;
                  
                  // Apply corrections to bodyB BEFORE merging
                  physicsB.setTransform(targetPosB, targetAngleB);
                  
                  // Connect!
                  final newBody = bodyMerger.merge(bodyA, bodyB, connA, connB);
                  entityManager.removeBody(bodyA);
                  entityManager.removeBody(bodyB);
                  entityManager.addBody(newBody);
                  
                  eventBus.fire(ConnectionEvent(
                    bodyA: bodyA,
                    bodyB: bodyB,
                    newBody: newBody,
                  ));
                  
                  return; // Stop processing these bodies
                }
              } else if (dist < config.attractionRange) {
                // Apply attraction force
                final forceDir = distVec.normalized();
                final forceFactor = forceModel.calculateForce(dist, config.attractionRange);
                final force = forceDir * config.attractionForce * forceFactor;

                physicsA.applyForce(force, point: connAPos);
                physicsB.applyForce(-force, point: connBPos);
              }
            }
          }
        }
      }
    }
  }

  double _normalizeAngle(double angle) {
    while (angle > pi) {
      angle -= 2 * pi;
    }
    while (angle < -pi) {
      angle += 2 * pi;
    }
    return angle;
  }
}
