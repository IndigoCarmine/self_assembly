import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../managers/entity_manager.dart';
import '../systems/periodic_boundary_system.dart';
import '../systems/connection_system.dart';
import '../systems/break_system.dart';
import '../systems/flow_system.dart';
import '../logic/body_merger.dart';
import '../logic/body_splitter.dart';
import '../logic/entity_spawner.dart';
import '../interfaces/interfaces.dart';
import '../events/event_bus.dart';
import '../components/body_component.dart';

class SelfAssemblyGame extends Forge2DGame with ScrollDetector, ScaleDetector, TapCallbacks {
  late final EntityManager entityManager;
  late final EntitySpawner entitySpawner;
  final Vector2 worldSize = Vector2(100, 100);

  SelfAssemblyGame() : super(gravity: Vector2.zero(), zoom: 10);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    entityManager = EntityManager();
    await add(entityManager);

    // Dependencies
    final distanceCalculator = PeriodicDistanceCalculator(worldSize: worldSize);
    final forceModel = LinearForceModel(); // Or InverseSquareForceModel
    final connectorCompatibility = PlusMinusCompatibility();
    final bodyMerger = BodyMerger();
    final bodySplitter = BodySplitter();
    final eventBus = EventBus();

    // Add Periodic Boundary System
    await add(PeriodicBoundarySystem(worldSize: worldSize));
    
    // Add Flow System (activates every 10 seconds with random direction)
    await add(FlowSystem(
      entityManager: entityManager,
      worldSize: worldSize,
    ));
    
    // Add Connection System
    await add(ConnectionSystem(
      entityManager: entityManager,
      distanceCalculator: distanceCalculator,
      forceModel: forceModel,
      connectorCompatibility: connectorCompatibility,
      bodyMerger: bodyMerger,
      eventBus: eventBus,
    ));
    
    // Add Break System
    await add(BreakSystem(
      entityManager: entityManager,
      bodySplitter: bodySplitter,
      eventBus: eventBus,
    ));

    // Initialize entity spawner
    entitySpawner = EntitySpawner();
    
    // Test: Add multiple simple triangle bodies with two connectors
    final initialBodies = entitySpawner.createInitialBodies(100, worldSize);
    
    for (final body in initialBodies) {
      entityManager.addBody(body);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Convert screen position to world position
    final worldPosition = camera.viewfinder.globalToLocal(event.localPosition);
    
    // Create a new triangle at the clicked position
    final newBodies = entitySpawner.createInitialBodies(1, worldSize);
    if (newBodies.isNotEmpty) {
      final body = newBodies.first;
      // Update the body's initial position to the click position
      final newBody = (body as SelfAssemblyBody).copyWith(
        initialPosition: worldPosition,
      );
      entityManager.addBody(newBody);
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
