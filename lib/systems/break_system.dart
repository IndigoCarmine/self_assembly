import 'dart:math';
import 'package:flame/components.dart';
import '../interfaces/interfaces.dart';

import '../events/event_bus.dart';

class BreakSystem extends Component implements IBreakSystem {
  final IEntityManager entityManager;
  final IBodySplitter bodySplitter;
  final IEventBus eventBus;
  final BreakSystemConfig config;
  final Random _rng = Random();

  BreakSystem({
    required this.entityManager,
    required this.bodySplitter,
    required this.eventBus,
    this.config = const BreakSystemConfig(),
  });

  @override
  void update(double dt) {
    super.update(dt);

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
