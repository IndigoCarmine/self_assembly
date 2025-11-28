import 'dart:math';
import 'package:flame/components.dart';
import '../components/body_component.dart';
import '../components/polygon_part.dart';
import '../components/connector.dart';
import '../interfaces/interfaces.dart';

class EntitySpawner implements IEntityFactory {
  @override
  List<IAssemblyBody> createInitialBodies(int count, Vector2 worldSize) {
    final bodies = <IAssemblyBody>[];
    final rng = Random();

    for (var i = 0; i < count; i++) {
      // Triangle vertices
      final v0 = Vector2(0, -2);
      final v1 = Vector2(2, 2);
      final v2 = Vector2(-2, 2);
      
      // Calculate edge midpoints and perpendicular angles
      // Edge 0-1 (top-right)
      final edge01Mid = (v0 + v1) / 2;
      final edge01Vec = v1 - v0;
      final edge01Angle = atan2(edge01Vec.y, edge01Vec.x);
      final perp01 = edge01Angle + pi / 2;
      
      // Edge 1-2 (bottom)
      final edge12Mid = (v1 + v2) / 2;
      final edge12Vec = v2 - v1;
      final edge12Angle = atan2(edge12Vec.y, edge12Vec.x);
      final perp12 = edge12Angle + pi / 2;
      
      final parts = [
        PolygonPart(
          vertices: [v0, v1, v2],
          connectors: [
            Connector(
              relativePosition: edge01Mid,
              relativeAngle: perp01,
              type: ConnectorType.plus,
            ),
            Connector(
              relativePosition: edge12Mid,
              relativeAngle: perp12,
              type: ConnectorType.minus,
            ),
          ],
        ),
      ];

      final x = (rng.nextDouble() - 0.5) * worldSize.x;
      final y = (rng.nextDouble() - 0.5) * worldSize.y;
      final initialPosition = Vector2(x, y);
      
      final initialLinearVelocity = Vector2(
        (rng.nextDouble() - 0.5) * 15,
        (rng.nextDouble() - 0.5) * 15,
      );
      final initialAngularVelocity = (rng.nextDouble() - 0.5) * 2;

      final body = SelfAssemblyBody(
        parts: parts,
        initialPosition: initialPosition,
        initialLinearVelocity: initialLinearVelocity,
        initialAngularVelocity: initialAngularVelocity,
      );
      
      bodies.add(body);
    }
    
    return bodies;
  }
}
