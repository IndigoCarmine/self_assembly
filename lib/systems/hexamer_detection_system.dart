import 'package:flame/components.dart';
import '../interfaces/interfaces.dart';
import '../events/event_bus.dart';
import '../state/game_state.dart';

/// System that detects hexamers (6-part assemblies) and removes them
class HexamerDetectionSystem extends Component {
  final IEntityManager entityManager;
  final IEventBus eventBus;
  final GameState gameState;

  HexamerDetectionSystem({
    required this.entityManager,
    required this.eventBus,
    required this.gameState,
  });

  @override
  void update(double dt) {
    super.update(dt);

    final bodies = entityManager.bodies.toList();
    
    for (final body in bodies) {
      if (!body.isMounted) continue;
      
      // Check if this body is a hexamer (6 parts)
      if (body.parts.length >= 6) {
        _removeHexamer(body);
      }
    }
  }

  void _removeHexamer(IAssemblyBody hexamer) {
    // Remove the hexamer
    entityManager.removeBody(hexamer);
    
    // Award points and increment count
    gameState.registerHexamer();
    
    // Fire event
    eventBus.fire(HexamerFormedEvent(hexamer: hexamer));
  }
}
