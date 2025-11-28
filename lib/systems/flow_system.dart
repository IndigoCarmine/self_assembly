import 'dart:math';
import 'package:flame/components.dart';
import '../interfaces/interfaces.dart';
import '../config/flow_config.dart';

/// System that applies periodic flow forces to mix particles
class FlowSystem extends Component {
  final IEntityManager entityManager;
  final Vector2 worldSize;
  FlowConfig config;
  
  double _elapsedTime = 0.0;
  bool _isActive = false;

  FlowSystem({
    required this.entityManager,
    required this.worldSize,
    FlowConfig? config,
  }) : config = config ?? FlowConfig.random(worldSize);

  @override
  void update(double dt) {
    super.update(dt);
    
    _elapsedTime += dt;
    
    // Check if we should toggle flow state
    if (_isActive) {
      if (_elapsedTime >= config.activeDuration) {
        _isActive = false;
        _elapsedTime = 0.0;
        // Generate new random flow configuration for next activation
        config = FlowConfig.random(worldSize);
      }
    } else {
      if (_elapsedTime >= config.inactiveDuration) {
        _isActive = true;
        _elapsedTime = 0.0;
      }
    }
    
    // Apply flow forces if active
    if (_isActive) {
      _applyFlowForces();
    }
  }

  void _applyFlowForces() {
    for (final body in entityManager.bodies) {
      if (!body.isMounted) continue;
      
      final bodyPos = body.physicsBody.position;
      
      // Calculate distance from body to flow line
      // Flow line: P = flowLinePosition + t * flowDirection
      // Distance from point to line: ||(P0 - P) - ((P0 - P) · d)d||
      // where P0 is the point, P is a point on the line, d is the direction
      final toBody = bodyPos - config.flowLinePosition;
      final projection = toBody.dot(config.flowDirection);
      final closestPoint = config.flowLinePosition + config.flowDirection * projection;
      final distance = (bodyPos - closestPoint).length;
      
      // Calculate force magnitude: maxForce * exp(-distance * expCoefficient) * distanceCoefficient
      final forceMagnitude = config.maxForce * 
                            exp(-distance * config.expCoefficient) * 
                            config.distanceCoefficient;
      
      // Apply force in flow direction
      final force = config.flowDirection * forceMagnitude;
      body.applyForce(force);
    }
  }
}
