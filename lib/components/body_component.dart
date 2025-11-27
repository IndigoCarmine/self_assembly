import 'package:flame_forge2d/flame_forge2d.dart';
import 'polygon_part.dart';

class SelfAssemblyBody extends BodyComponent {
  final List<PolygonPart> parts;
  final Vector2 initialPosition;

  SelfAssemblyBody({
    required this.parts,
    required this.initialPosition,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      type: BodyType.dynamic,
      angularDamping: 0.5,
      linearDamping: 0.5,
    );

    final body = world.createBody(bodyDef);

    for (final part in parts) {
      final shape = PolygonShape();
      // Transform vertices based on part's relative position and angle
      // For simplicity in this initial version, we assume vertices are already relative to center
      // In a full implementation, we'd need to apply rotation/translation to vertices here
      shape.set(part.vertices);

      final fixtureDef = FixtureDef(
        shape,
        density: 1.0,
        friction: 0.3,
        restitution: 0.2,
      );
      
      body.createFixture(fixtureDef);
    }

    return body;
  }
}
