import 'dart:math';
import 'package:flame/components.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../components/polygon_part.dart';

class BreakSystem extends Component with HasGameReference<SelfAssemblyGame> {
  final double breakProbabilityPerSecond = 0.1; // 10% chance per second
  final Random _rng = Random();
  
  // Reusable vector to reduce allocations
  final Vector2 _separationVel = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);

    final bodies = game.entityManager.bodies.toList(); // Copy to avoid concurrent modification
    
    for (final body in bodies) {
      if (!body.isMounted) continue;
      
      // Only break bodies with multiple parts
      if (body.parts.length > 1) {
        // Check probability
        final breakChance = breakProbabilityPerSecond * dt;
        if (_rng.nextDouble() < breakChance) {
          _breakBody(body);
        }
      }
    }
  }

  void _breakBody(SelfAssemblyBody body) {
    // Split body into individual parts
    final position = body.body.position;
    final angle = body.body.angle;
    final velocity = body.body.linearVelocity;
    final angularVelocity = body.body.angularVelocity;

    // Create a new body for each part
    for (var i = 0; i < body.parts.length; i++) {
      final part = body.parts[i];
      
      // Reset separation velocity
      _separationVel.setZero();
      
      for (final conn in part.connectors) {
        if (conn.isConnected) {
          // Calculate connector's absolute angle
          final connAngle = angle + conn.relativeAngle;
          
          // Pre-compute sin and cos
          final cosAngle = cos(connAngle);
          final sinAngle = sin(connAngle);
          
          // Apply force in connector direction (push away)
          _separationVel.x += cosAngle * 3.0; // Separation force magnitude
          _separationVel.y += sinAngle * 3.0;
          
          // Mark as disconnected
          conn.isConnected = false;
        }
      }
      
      // Add some random component
      _separationVel.x += (_rng.nextDouble() - 0.5) * 1.0;
      _separationVel.y += (_rng.nextDouble() - 0.5) * 1.0;
      
      final newBody = SelfAssemblyBody(
        parts: [part],
        initialPosition: position.clone(),
        initialLinearVelocity: velocity + _separationVel,
        initialAngularVelocity: angularVelocity + (_rng.nextDouble() - 0.5) * 1.0,
      );
      
      game.entityManager.addBody(newBody);
    }
    
    // Remove the original combined body
    game.entityManager.removeBody(body);
  }
}
