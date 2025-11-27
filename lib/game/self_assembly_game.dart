import 'package:flame_forge2d/flame_forge2d.dart';
import 'dart:math';
import '../managers/entity_manager.dart';
import '../components/body_component.dart';
import '../components/polygon_part.dart';
import '../components/connector.dart';

class SelfAssemblyGame extends Forge2DGame {
  late final EntityManager entityManager;

  SelfAssemblyGame() : super(gravity: Vector2.zero(), zoom: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    entityManager = EntityManager();
    await add(entityManager);

    // Test: Add a simple triangle body with one connector
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
            type: ConnectorType.plus,
          ),
        ],
      ),
    ];

    final body = SelfAssemblyBody(
      parts: parts,
      initialPosition: Vector2(0, 0),
    );

    entityManager.addBody(body);
  }
}
