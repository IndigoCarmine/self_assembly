import 'package:flame/components.dart';
import '../game/self_assembly_game.dart';
import '../components/body_component.dart';

class EntityManager extends Component with HasGameReference<SelfAssemblyGame> {
  final List<SelfAssemblyBody> _bodies = [];

  List<SelfAssemblyBody> get bodies => List.unmodifiable(_bodies);

  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Initial setup if needed
  }

  void addBody(SelfAssemblyBody body) {
    _bodies.add(body);
    game.world.add(body);
  }

  void removeBody(SelfAssemblyBody body) {
    _bodies.remove(body);
    game.world.remove(body);
  }
  
  // Future: Add methods for finding neighbors, etc.
}
