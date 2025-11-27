import 'package:flame/components.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';

class EntityManager extends Component with HasGameReference<SelfAssemblyGame> {
  final List<SelfAssemblyBody> _bodies = [];
  final List<SelfAssemblyBody> _bodiesToAdd = [];
  final List<SelfAssemblyBody> _bodiesToRemove = [];

  List<SelfAssemblyBody> get bodies => List.unmodifiable(_bodies);

  @override
  Future<void> onLoad() async {
    super.onLoad();
  }

  @override
  void update(double dt) {
    super.update(dt);
    
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
  }

  void addBody(SelfAssemblyBody body) {
    _bodiesToAdd.add(body);
  }

  void removeBody(SelfAssemblyBody body) {
    _bodiesToRemove.add(body);
  }
}
