import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../components/connector.dart';
import '../components/polygon_part.dart';

/// Cached connector data to avoid repeated trigonometric calculations
class _CachedConnectorData {
  final Connector connector;
  final PolygonPart part;
  final SelfAssemblyBody body;
  final Vector2 worldPosition;
  final double worldAngle;

  _CachedConnectorData({
    required this.connector,
    required this.part,
    required this.body,
    required this.worldPosition,
    required this.worldAngle,
  });
}

class ConnectionSystem extends Component with HasGameReference<SelfAssemblyGame> {
  final double attractionRange = 5.0;
  final double attractionForce = 10.0;
  final double repulsionRange = 3.0;
  final double repulsionForce = 15.0;
  final double connectionThreshold = 0.5;
  final double angleThreshold = 0.3;

  // Reusable vectors to reduce allocations
  final Vector2 _tempVector = Vector2.zero();
  final Vector2 _forceDir = Vector2.zero();
  final Vector2 _force = Vector2.zero();

  // Cached connector data for current frame
  final List<_CachedConnectorData> _cachedConnectors = [];

  @override
  void update(double dt) {
    super.update(dt);

    final bodies = game.entityManager.bodies;
    if (bodies.isEmpty) return;

    // Build cache of all connector world positions and angles
    _buildConnectorCache(bodies);

    // Process connector pairs using cached data
    _processConnectorPairs();
  }

  /// Build cache of connector world positions to avoid repeated trig calculations
  void _buildConnectorCache(List<SelfAssemblyBody> bodies) {
    _cachedConnectors.clear();

    for (final body in bodies) {
      if (!body.isMounted) continue;

      final pos = body.body.position;
      final angle = body.body.angle;
      
      // Pre-compute sin and cos once per body
      final cosAngle = cos(angle);
      final sinAngle = sin(angle);

      for (final part in body.parts) {
        for (final conn in part.connectors) {
          // Skip already connected connectors
          if (conn.isConnected) continue;

          // Calculate world position using cached trig values
          final relX = conn.relativePosition.x;
          final relY = conn.relativePosition.y;
          final worldX = pos.x + relX * cosAngle - relY * sinAngle;
          final worldY = pos.y + relX * sinAngle + relY * cosAngle;

          _cachedConnectors.add(_CachedConnectorData(
            connector: conn,
            part: part,
            body: body,
            worldPosition: Vector2(worldX, worldY),
            worldAngle: angle + conn.relativeAngle,
          ));
        }
      }
    }
  }

  /// Process all connector pairs using cached data
  void _processConnectorPairs() {
    final count = _cachedConnectors.length;

    for (var i = 0; i < count; i++) {
      final dataA = _cachedConnectors[i];
      
      // Skip if connector was connected during this frame
      if (dataA.connector.isConnected) continue;

      for (var j = i + 1; j < count; j++) {
        final dataB = _cachedConnectors[j];
        
        // Skip if same body or connector already connected
        if (dataA.body == dataB.body) continue;
        if (dataB.connector.isConnected) continue;

        _processConnectorPair(dataA, dataB);
      }
    }
  }

  /// Process a single connector pair
  void _processConnectorPair(_CachedConnectorData dataA, _CachedConnectorData dataB) {
    _getShortestVector(dataA.worldPosition, dataB.worldPosition, _tempVector);
    final dist = _tempVector.length;

    final sameType = dataA.connector.type == dataB.connector.type;

    if (sameType && dist < repulsionRange) {
      // Apply repulsion force
      _forceDir.setFrom(_tempVector);
      _forceDir.normalize();
      _force.setFrom(_forceDir);
      _force.scale(repulsionForce * (1.0 - dist / repulsionRange));

      dataA.body.body.applyForce(-_force, point: dataA.worldPosition);
      dataB.body.body.applyForce(_force, point: dataB.worldPosition);
    } else if (!sameType && dist < connectionThreshold) {
      // Check angle alignment
      final angleDiff = _normalizeAngle(dataA.worldAngle - dataB.worldAngle);
      if ((angleDiff - pi).abs() < angleThreshold) {
        print('Connecting! dist=$dist, angleDiff=$angleDiff');
        _connectBodies(dataA.body, dataB.body, dataA.connector, dataB.connector);
      }
    } else if (!sameType && dist < attractionRange) {
      // Apply attraction force
      _forceDir.setFrom(_tempVector);
      _forceDir.normalize();
      _force.setFrom(_forceDir);
      _force.scale(attractionForce * (1.0 - dist / attractionRange));

      dataA.body.body.applyForce(_force, point: dataA.worldPosition);
      dataB.body.body.applyForce(-_force, point: dataB.worldPosition);
    }
  }

  void _connectBodies(
    SelfAssemblyBody bodyA,
    SelfAssemblyBody bodyB,
    Connector connA,
    Connector connB,
  ) {
    final posA = bodyA.body.position;
    final angleA = bodyA.body.angle;
    final posB = bodyB.body.position;
    final angleB = bodyB.body.angle;

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
    
    // Pre-compute sin and cos for the delta angle
    final cosDelta = cos(deltaAngle);
    final sinDelta = sin(deltaAngle);
    
    for (final partB in bodyB.parts) {
      final transformedVertices = <Vector2>[];
      for (final v in partB.vertices) {
        final rotatedX = v.x * cosDelta - v.y * sinDelta;
        final rotatedY = v.x * sinDelta + v.y * cosDelta;
        transformedVertices.add(Vector2(rotatedX + deltaPos.x, rotatedY + deltaPos.y));
      }
      
      final transformedConnectors = <Connector>[];
      for (final conn in partB.connectors) {
        final relX = conn.relativePosition.x;
        final relY = conn.relativePosition.y;
        final rotatedX = relX * cosDelta - relY * sinDelta;
        final rotatedY = relX * sinDelta + relY * cosDelta;
        transformedConnectors.add(Connector(
          relativePosition: Vector2(rotatedX + deltaPos.x, rotatedY + deltaPos.y),
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
    final massA = bodyA.body.mass;
    final massB = bodyB.body.mass;
    final totalMass = massA + massB;
    
    final velA = bodyA.body.linearVelocity;
    final velB = bodyB.body.linearVelocity;
    final combinedVel = (velA * massA + velB * massB) / totalMass;
    
    final angVelA = bodyA.body.angularVelocity;
    final angVelB = bodyB.body.angularVelocity;
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

  /// Calculate the shortest vector between two points, considering periodic boundary
  /// Uses the provided output vector to avoid allocations
  void _getShortestVector(Vector2 from, Vector2 to, Vector2 output) {
    final worldSize = game.worldSize;
    final halfX = worldSize.x * 0.5;
    final halfY = worldSize.y * 0.5;
    
    var dx = to.x - from.x;
    var dy = to.y - from.y;

    if (dx > halfX) dx -= worldSize.x;
    else if (dx < -halfX) dx += worldSize.x;

    if (dy > halfY) dy -= worldSize.y;
    else if (dy < -halfY) dy += worldSize.y;

    output.setValues(dx, dy);
  }
}
