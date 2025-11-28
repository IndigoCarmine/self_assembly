import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'polygon_part.dart';
import 'body_renderer.dart';
import '../interfaces/interfaces.dart';

/// Forge2D Bodyをラップしてインターフェースを実装
class Forge2DPhysicsBody implements IPhysicsBody {
  final Body _body;
  
  Forge2DPhysicsBody(this._body);
  
  @override
  Vector2 get position => _body.position;
  
  @override
  double get angle => _body.angle;
  
  @override
  Vector2 get linearVelocity => _body.linearVelocity;
  
  @override
  double get angularVelocity => _body.angularVelocity;
  
  @override
  double get mass => _body.mass;
  
  @override
  void applyForce(Vector2 force, {Vector2? point}) {
    _body.applyForce(force, point: point);
  }
  
  @override
  void setTransform(Vector2 position, double angle) {
    _body.setTransform(position, angle);
  }
}

class SelfAssemblyBody extends BodyComponent implements IAssemblyBody {
  @override
  final List<PolygonPart> parts;
  final Vector2 initialPosition;
  final Vector2 initialLinearVelocity;
  final double initialAngularVelocity;
  final IBodyRenderer renderer;
  
  Forge2DPhysicsBody? _physicsBody;

  SelfAssemblyBody({
    required this.parts,
    required this.initialPosition,
    Vector2? initialLinearVelocity,
    double? initialAngularVelocity,
    IBodyRenderer? renderer,
  })  : initialLinearVelocity = initialLinearVelocity ?? Vector2.zero(),
        initialAngularVelocity = initialAngularVelocity ?? 0.0,
        renderer = renderer ?? BodyRenderer();
  
  /// Create a copy of this body with different parameters
  SelfAssemblyBody copyWith({
    List<PolygonPart>? parts,
    Vector2? initialPosition,
    Vector2? initialLinearVelocity,
    double? initialAngularVelocity,
    IBodyRenderer? renderer,
  }) {
    return SelfAssemblyBody(
      parts: parts ?? this.parts,
      initialPosition: initialPosition ?? this.initialPosition,
      initialLinearVelocity: initialLinearVelocity ?? this.initialLinearVelocity,
      initialAngularVelocity: initialAngularVelocity ?? this.initialAngularVelocity,
      renderer: renderer ?? this.renderer,
    );
  }
  
  @override
  IPhysicsBody get physicsBody {
    _physicsBody ??= Forge2DPhysicsBody(body);
    return _physicsBody!;
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      linearVelocity: initialLinearVelocity,
      angularVelocity: initialAngularVelocity,
      type: BodyType.dynamic,
      angularDamping: 0.0,
      linearDamping: 0.0,
    );

    final body = world.createBody(bodyDef);
    body.setSleepingAllowed(false);

    for (final part in parts) {
      final shape = PolygonShape();
      shape.set(part.vertices);

      final fixtureDef = FixtureDef(
        shape,
        density: 1.0,
        friction: 0.3,
        restitution: 0.2,
      );
      
      body.createFixture(fixtureDef);
    }

    return body;
  }

  @override
  Vector2 get linearVelocity => body.linearVelocity;

  @override
  double get angularVelocity => body.angularVelocity;

  @override
  double get mass => body.mass;

  @override
  void applyForce(Vector2 force, {Vector2? point}) {
    body.applyForce(force, point: point);
  }

  @override
  void setTransform(Vector2 position, double angle) {
    body.setTransform(position, angle);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    if (!isMounted) return;

    renderer.render(canvas, this);
  }
}
