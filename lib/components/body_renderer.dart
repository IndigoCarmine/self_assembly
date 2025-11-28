import 'package:flutter/material.dart';
import '../interfaces/interfaces.dart';
import 'connector.dart';

class BodyRenderer implements IBodyRenderer {
  @override
  void render(Canvas canvas, IAssemblyBody body) {
    // Draw polygon parts with their colors
    for (final part in body.parts) {
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

    for (final part in body.parts) {
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
