import 'dart:math';
import 'package:flame/components.dart';
import '../components/body_component.dart';
import '../interfaces/interfaces.dart';

class BodySplitter implements IBodySplitter {
  final Random _rng = Random();

  @override
  List<IAssemblyBody> split(IAssemblyBody body) {
    final physicsBody = body.physicsBody;
    final position = physicsBody.position;
    final angle = physicsBody.angle;
    final velocity = physicsBody.linearVelocity;
    final angularVelocity = physicsBody.angularVelocity;

    final newBodies = <IAssemblyBody>[];

    // Create a new body for each part
    for (var i = 0; i < body.parts.length; i++) {
      final part = body.parts[i];
      
      // Calculate separation velocity based on connector direction
      var separationVel = Vector2.zero();
      
      for (final conn in part.connectors) {
        if (conn.isConnected) {
          // Calculate connector's absolute angle
          final connAngle = angle + conn.relativeAngle;
          
          // Apply force in connector direction (push away)
          final forceDir = Vector2(cos(connAngle), sin(connAngle));
          separationVel += forceDir * 3.0; // Separation force magnitude
          
          // Mark as disconnected
          conn.isConnected = false;
        }
      }
      
      // Add some random component
      separationVel += Vector2(
        (_rng.nextDouble() - 0.5) * 1.0,
        (_rng.nextDouble() - 0.5) * 1.0,
      );
      
      final newBody = SelfAssemblyBody(
        parts: [part],
        initialPosition: position.clone(),
        initialLinearVelocity: velocity + separationVel,
        initialAngularVelocity: angularVelocity + (_rng.nextDouble() - 0.5) * 1.0,
      );
      
      newBodies.add(newBody);
    }
    
    return newBodies;
  }
}
