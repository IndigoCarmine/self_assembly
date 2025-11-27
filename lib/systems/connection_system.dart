import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../components/connector.dart';
import '../components/polygon_part.dart';
import '../interfaces/interfaces.dart';

class ConnectionSystem extends Component with HasGameReference<SelfAssemblyGame> implements IConnectionSystem {
  final double attractionRange = 5.0;
  final double attractionForce = 10.0;
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

            final distVec = _getShortestVector(connAPos, connBPos);
            final dist = distVec.length;

            // Check if same type (repulsion) or different type (attraction)
            final sameType = connA.type == connB.type;
            
            if (sameType && dist < repulsionRange) {
              // Apply repulsion force
              final forceDir = distVec.normalized();
              final force = forceDir * repulsionForce * (1.0 - dist / repulsionRange);
              
              physicsA.applyForce(-force, point: connAPos); // Push away
              physicsB.applyForce(force, point: connBPos);
            } else if (!sameType && dist < connectionThreshold) {
              // Check angle alignment
              final angleDiff = _normalizeAngle(connAAngle - connBAngle);
              if ((angleDiff - pi).abs() < angleThreshold) {
                print('Connecting! dist=$dist, angleDiff=$angleDiff');
                _connectBodies(bodyA, bodyB, connA, connB);
                return;
              }
            } else if (!sameType && dist < attractionRange) {
              // Apply attraction force
              final forceDir = distVec.normalized();
              final force = forceDir * attractionForce * (1.0 - dist / attractionRange);

              physicsA.applyForce(force, point: connAPos);
              physicsB.applyForce(-force, point: connBPos);
            }
          }
        }
      }
    }
  }

  void _connectBodies(
    IAssemblyBody bodyA,
    IAssemblyBody bodyB,
    Connector connA,
    Connector connB,
  ) {
    final physicsA = bodyA.physicsBody;
    final physicsB = bodyB.physicsBody;
    final posA = physicsA.position;
    final angleA = physicsA.angle;
    final posB = physicsB.position;
    final angleB = physicsB.angle;

    final combinedParts = <PolygonPart>[];
    
    connA.isConnected = true;
    connB.isConnected = true;
    
    // Generate new color
    final random = Random();
    final newColor = Color.fromARGB(
      255,
      100 + random.nextInt(156),
      100 + random.nextInt(156),
      100 + random.nextInt(156),
    );
    
    // Add parts from bodyA
    for (final part in bodyA.parts) {
      part.color = newColor;
    }
    combinedParts.addAll(bodyA.parts);
    
    // Transform and add parts from bodyB
    final deltaPos = posB - posA;
    final deltaAngle = angleB - angleA;
    
    for (final partB in bodyB.parts) {
      final transformedVertices = <Vector2>[];
      for (final v in partB.vertices) {
        final rotated = Vector2(
          v.x * cos(deltaAngle) - v.y * sin(deltaAngle),
          v.x * sin(deltaAngle) + v.y * cos(deltaAngle),
        );
        transformedVertices.add(rotated + deltaPos);
      }
      
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
    
    // Calculate combined velocity
    final massA = physicsA.mass;
    final massB = physicsB.mass;
    final totalMass = massA + massB;
    
    final velA = physicsA.linearVelocity;
    final velB = physicsB.linearVelocity;
    final combinedVel = (velA * massA + velB * massB) / totalMass;
    
    final angVelA = physicsA.angularVelocity;
    final angVelB = physicsB.angularVelocity;
    final combinedAngVel = (angVelA * massA + angVelB * massB) / totalMass;
    
    final newBody = SelfAssemblyBody(
      parts: combinedParts,
      initialPosition: posA,
      initialLinearVelocity: combinedVel,
      initialAngularVelocity: combinedAngVel,
    );
    
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
