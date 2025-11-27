import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:math';
import '../managers/entity_manager.dart';
import '../components/body_component.dart';
import '../components/polygon_part.dart';
import '../components/connector.dart';
import '../systems/periodic_boundary_system.dart';
import '../systems/connection_system.dart';

class SelfAssemblyGame extends Forge2DGame with ScrollDetector, ScaleDetector {
  late final EntityManager entityManager;
  final Vector2 worldSize = Vector2(100, 100);

  SelfAssemblyGame() : super(gravity: Vector2.zero(), zoom: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add Periodic Boundary System
    await add(PeriodicBoundarySystem(worldSize: worldSize));
    
    // Add Connection System
    await add(ConnectionSystem());

    entityManager = EntityManager();
    await add(entityManager);

    // Test: Add multiple simple triangle bodies with one connector
    final rng = Random();
    for (var i = 0; i < 20; i++) {
      final connectorType = rng.nextBool() ? ConnectorType.plus : ConnectorType.minus;
      
      final parts = [
        PolygonPart(
          vertices: [
            Vector2(0, -2),
            Vector2(2, 2),
            Vector2(-2, 2),
          ],
          connectors: [
            Connector(
              relativePosition: Vector2(0, -2),
              relativeAngle: -pi / 2, // Pointing up
              type: connectorType,
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
      
      entityManager.addBody(body);
    }
  }

  @override
  void onScroll(PointerScrollInfo info) {
    // Zoom with scroll
    final zoomDelta = info.scrollDelta.global.y * 0.01;
    camera.viewfinder.zoom = (camera.viewfinder.zoom - zoomDelta).clamp(1.0, 50.0);
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    // Zoom with pinch
    final scaleDelta = info.delta.global.y * 0.01;
    camera.viewfinder.zoom = (camera.viewfinder.zoom + scaleDelta).clamp(1.0, 50.0);
  }
}
