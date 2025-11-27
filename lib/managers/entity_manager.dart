import 'package:flame/components.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';

class EntityManager extends Component with HasGameReference<SelfAssemblyGame> {
  final List<SelfAssemblyBody> _bodies = [];
  final List<SelfAssemblyBody> _bodiesToAdd = [];
  final List<SelfAssemblyBody> _bodiesToRemove = [];
  
  // Cached unmodifiable view - recreated only when bodies list changes
  List<SelfAssemblyBody>? _cachedBodiesView;

  /// Returns an unmodifiable view of the bodies list.
  /// The view is cached and only recreated when the list changes.
  List<SelfAssemblyBody> get bodies {
    _cachedBodiesView ??= List.unmodifiable(_bodies);
    return _cachedBodiesView!;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
    final hasChanges = _bodiesToRemove.isNotEmpty || _bodiesToAdd.isNotEmpty;
    
    // Process pending additions and removals
    for (final body in _bodiesToRemove) {
      _bodies.remove(body);
      body.removeFromParent();
    }
    _bodiesToRemove.clear();
    
    for (final body in _bodiesToAdd) {
      _bodies.add(body);
      game.world.add(body);
    }
    _bodiesToAdd.clear();
    
    // Invalidate cache if bodies list changed
    if (hasChanges) {
      _cachedBodiesView = null;
    }
  }

  void addBody(SelfAssemblyBody body) {
    _bodiesToAdd.add(body);
  }

  void removeBody(SelfAssemblyBody body) {
    _bodiesToRemove.add(body);
  }
}
