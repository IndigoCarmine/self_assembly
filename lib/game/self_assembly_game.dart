import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import '../managers/entity_manager.dart';
import '../systems/periodic_boundary_system.dart';
import '../systems/connection_system.dart';
import '../systems/break_system.dart';
import '../logic/body_merger.dart';
import '../logic/body_splitter.dart';
import '../logic/entity_spawner.dart';
import '../interfaces/interfaces.dart';
import '../events/event_bus.dart';

class SelfAssemblyGame extends Forge2DGame with ScrollDetector, ScaleDetector {
  late final EntityManager entityManager;
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

    // Test: Add multiple simple triangle bodies with two connectors
    final entitySpawner = EntitySpawner();
    final initialBodies = entitySpawner.createInitialBodies(20, worldSize);
    
    for (final body in initialBodies) {
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
