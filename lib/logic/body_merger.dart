import 'dart:math';
import 'dart:ui';
import 'package:flame/components.dart';
import '../components/body_component.dart';
import '../components/connector.dart';
import '../components/polygon_part.dart';
import '../interfaces/interfaces.dart';

class BodyMerger implements IBodyMerger {
  @override
  IAssemblyBody merge(
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
    
    return SelfAssemblyBody(
      parts: combinedParts,
      initialPosition: posA,
      initialLinearVelocity: combinedVel,
      initialAngularVelocity: combinedAngVel,
    );
  }
}
