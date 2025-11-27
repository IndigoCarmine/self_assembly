import 'package:flutter/material.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'polygon_part.dart';
import 'connector.dart';

class SelfAssemblyBody extends BodyComponent {
  final List<PolygonPart> parts;
  final Vector2 initialPosition;
  final Vector2 initialLinearVelocity;
  final double initialAngularVelocity;

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
      final paint = Paint()
        ..color = part.color
        ..style = PaintingStyle.fill;
      
      final path = Path();
      if (part.vertices.isNotEmpty) {
        path.moveTo(part.vertices[0].x, part.vertices[0].y);
        for (var i = 1; i < part.vertices.length; i++) {
          path.lineTo(part.vertices[i].x, part.vertices[i].y);
        }
        path.close();
      }
      canvas.drawPath(path, paint);
      
      // Draw outline
      paint
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.1;
      canvas.drawPath(path, paint);
    }

    // Draw connectors
    final connectorPaint = Paint()
      ..strokeWidth = 0.2
      ..style = PaintingStyle.stroke;

    for (final part in parts) {
      for (final connector in part.connectors) {
        final cPos = connector.relativePosition;
        final cAng = connector.relativeAngle;
        
        // Draw arrow
        connectorPaint.color = connector.type == ConnectorType.plus ? Colors.red : Colors.blue;
        
        canvas.save();
        canvas.translate(cPos.x, cPos.y);
        canvas.rotate(cAng);
        
        // Draw an arrow pointing in the direction of the connector
        const arrowLen = 1.0;
        canvas.drawLine(Offset.zero, const Offset(arrowLen, 0), connectorPaint);
        // Arrow head
        canvas.drawLine(const Offset(arrowLen, 0), const Offset(arrowLen - 0.3, 0.3), connectorPaint);
        canvas.drawLine(const Offset(arrowLen, 0), const Offset(arrowLen - 0.3, -0.3), connectorPaint);
        
        canvas.restore();
      }
    }
  }
}
