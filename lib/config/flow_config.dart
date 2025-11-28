import 'dart:math';
import 'package:flame/components.dart';

/// Configuration for the flow mixing system
class FlowConfig {
  /// Position of the flow line
  final Vector2 flowLinePosition;
  
  /// Direction of the flow (normalized)
  final Vector2 flowDirection;
  
  /// Coefficient for distance scaling
  final double distanceCoefficient;
  
  /// Coefficient inside the exponential function
  final double expCoefficient;
  
  /// Maximum force magnitude
  final double maxForce;
  
  /// How long the flow stays active (seconds)
  final double activeDuration;
  
  /// How long between flow activations (seconds)
  final double inactiveDuration;

  const FlowConfig({
    required this.flowLinePosition,
    required this.flowDirection,
    this.distanceCoefficient = 1.0,
    this.expCoefficient = 0.5,
    this.maxForce = 50.0,
    this.activeDuration = 2.0,
    this.inactiveDuration = 10.0,
  });

  /// Generate a random flow configuration
  /// 
  /// [worldSize] The size of the world to generate the flow line within
  /// [random] Optional random number generator
  static FlowConfig random(Vector2 worldSize, {Random? random}) {
    final rng = random ?? Random();
    
    // Random position within the world
    final x = (rng.nextDouble() - 0.5) * worldSize.x;
    final y = (rng.nextDouble() - 0.5) * worldSize.y;
    final position = Vector2(x, y);
    
    // Random direction (normalized)
    final angle = rng.nextDouble() * 2 * pi;
    final direction = Vector2(cos(angle), sin(angle));
    
    return FlowConfig(
      flowLinePosition: position,
      flowDirection: direction,
      distanceCoefficient: 1.0,
      expCoefficient: 0.5,
      maxForce: 50.0,
      activeDuration: 2.0,
      inactiveDuration: 10.0,
    );
  }

  /// Create a copy with modified parameters
  FlowConfig copyWith({
    Vector2? flowLinePosition,
    Vector2? flowDirection,
    double? distanceCoefficient,
    double? expCoefficient,
    double? maxForce,
    double? activeDuration,
    double? inactiveDuration,
  }) {
    return FlowConfig(
      flowLinePosition: flowLinePosition ?? this.flowLinePosition,
      flowDirection: flowDirection ?? this.flowDirection,
      distanceCoefficient: distanceCoefficient ?? this.distanceCoefficient,
      expCoefficient: expCoefficient ?? this.expCoefficient,
      maxForce: maxForce ?? this.maxForce,
      activeDuration: activeDuration ?? this.activeDuration,
      inactiveDuration: inactiveDuration ?? this.inactiveDuration,
    );
  }
}
