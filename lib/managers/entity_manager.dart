import 'package:flame/components.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';
import '../interfaces/interfaces.dart';

class EntityManager extends Component with HasGameReference<SelfAssemblyGame> implements IEntityManager {
  final List<SelfAssemblyBody> _bodies = [];
  final List<SelfAssemblyBody> _bodiesToAdd = [];
  final List<SelfAssemblyBody> _bodiesToRemove = [];

  @override
  List<IAssemblyBody> get bodies => List<IAssemblyBody>.unmodifiable(_bodies);

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

  @override
  void addBody(IAssemblyBody body) {
    _bodiesToAdd.add(body as SelfAssemblyBody);
  }

  @override
  void removeBody(IAssemblyBody body) {
    _bodiesToRemove.add(body as SelfAssemblyBody);
  }
}
