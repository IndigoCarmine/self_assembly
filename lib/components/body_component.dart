import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'polygon_part.dart';
import 'connector.dart';

class SelfAssemblyBody extends BodyComponent {
  final List<PolygonPart> parts;
  final Vector2 initialPosition;
  final Vector2 initialLinearVelocity;
  final double initialAngularVelocity;
  
  // Reusable paint objects to reduce allocations
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _strokePaint = Paint()
    ..color = Colors.black
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.1;
  static final Paint _connectorPlusPaint = Paint()
    ..color = Colors.red
    ..strokeWidth = 0.2
    ..style = PaintingStyle.stroke;
  static final Paint _connectorMinusPaint = Paint()
    ..color = Colors.blue
    ..strokeWidth = 0.2
    ..style = PaintingStyle.stroke;
  
  // Arrow head offset constants
  static const Offset _arrowEnd = Offset(1.0, 0);
  static const Offset _arrowHead1 = Offset(0.7, 0.3);
  static const Offset _arrowHead2 = Offset(0.7, -0.3);

  SelfAssemblyBody({
    required this.parts,
    required this.initialPosition,
    Vector2? initialLinearVelocity,
    double? initialAngularVelocity,
  })  : initialLinearVelocity = initialLinearVelocity ?? Vector2.zero(),
        initialAngularVelocity = initialAngularVelocity ?? 0.0;

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
  void render(Canvas canvas) {
    super.render(canvas);
    
    // BodyComponent already applies the body's transform to the canvas,
    // so we can draw directly in local body coordinates.
    
    if (!isMounted) return;

    // Draw polygon parts with their colors
    for (final part in parts) {
      _fillPaint.color = part.color;
      
      final path = Path();
      if (part.vertices.isNotEmpty) {
        path.moveTo(part.vertices[0].x, part.vertices[0].y);
        for (var i = 1; i < part.vertices.length; i++) {
          path.lineTo(part.vertices[i].x, part.vertices[i].y);
        }
        path.close();
      }
      canvas.drawPath(path, _fillPaint);
      
      // Draw outline
      canvas.drawPath(path, _strokePaint);
    }

    // Draw connectors
    for (final part in parts) {
      for (final connector in part.connectors) {
        final cPos = connector.relativePosition;
        final cAng = connector.relativeAngle;
        
        // Select paint based on connector type
        final paint = connector.type == ConnectorType.plus 
            ? _connectorPlusPaint 
            : _connectorMinusPaint;
        
        canvas.save();
        canvas.translate(cPos.x, cPos.y);
        canvas.rotate(cAng);
        
        // Draw an arrow pointing in the direction of the connector
        canvas.drawLine(Offset.zero, _arrowEnd, paint);
        // Arrow head
        canvas.drawLine(_arrowEnd, _arrowHead1, paint);
        canvas.drawLine(_arrowEnd, _arrowHead2, paint);
        
        canvas.restore();
      }
    }
  }
}
