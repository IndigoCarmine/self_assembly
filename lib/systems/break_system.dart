import 'dart:math';
import 'package:flame/components.dart';
import '../interfaces/interfaces.dart';
import '../events/event_bus.dart';

/// System responsible for breaking apart connected bodies based on probability.
/// 
/// Currently disabled. To re-enable, uncomment the body-breaking logic in [update]
/// which uses [_breakBody] to split bodies and fire [DetachmentEvent].
class BreakSystem extends Component implements IBreakSystem {
  final IEntityManager entityManager;
  final IBodySplitter bodySplitter;
  final IEventBus eventBus;
  final BreakSystemConfig config;
  
  // ignore: unused_field
  final Random _rng = Random();

  BreakSystem({
    required this.entityManager,
    required this.bodySplitter,
    required this.eventBus,
    this.config = const BreakSystemConfig(),
  });

  @override
  void update(double dt) {
    // Temporarily disabled decomposition
    // TODO: Re-enable when break system is needed by uncommenting the code below
    /*
    final bodies = entityManager.bodies.toList(); // Copy to avoid concurrent modification
    
    for (final body in bodies) {
      if (!body.isMounted) continue;
      
      // Only break bodies with multiple parts
      if (body.parts.length > 1) {
        // Check probability
        final breakChance = config.breakProbabilityPerSecond * dt;
        if (_rng.nextDouble() < breakChance) {
          _breakBody(body);
        }
      }
    }
    */
  }

  void _breakBody(IAssemblyBody body) {
    final newBodies = bodySplitter.split(body);
    
    for (final newBody in newBodies) {
      entityManager.addBody(newBody);
    }
    
    // Remove the original combined body
    entityManager.removeBody(body);

    eventBus.fire(DetachmentEvent(
      originalBody: body,
      newBodies: newBodies,
    ));
  }
}
