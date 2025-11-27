import 'package:flame/components.dart';
import '../game/self_assembly_game.dart';
import '../managers/entity_manager.dart';

class PeriodicBoundarySystem extends Component with HasGameReference<SelfAssemblyGame> {
  final Vector2 worldSize;
  late final Vector2 _halfWorldSize;

  PeriodicBoundarySystem({required this.worldSize}) {
    _halfWorldSize = worldSize / 2;
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final entityManager = game.entityManager;
    
    for (final bodyComponent in entityManager.bodies) {
      if (!bodyComponent.isMounted) continue;
      final body = bodyComponent.body;
      final position = body.position;
      
      // Modulo arithmetic for periodic boundary
      // Map [-half, half] to [0, size], mod size, then map back to [-half, half]
      final x = ((position.x + _halfWorldSize.x) % worldSize.x + worldSize.x) % worldSize.x - _halfWorldSize.x;
      final y = ((position.y + _halfWorldSize.y) % worldSize.y + worldSize.y) % worldSize.y - _halfWorldSize.y;

      if ((x - position.x).abs() > 0.001 || (y - position.y).abs() > 0.001) {
        body.setTransform(Vector2(x, y), body.angle);
      }
    }
  }
}
