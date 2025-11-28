import 'dart:async';
import '../interfaces/interfaces.dart';

/// Event fired when two bodies connect
class ConnectionEvent extends GameEvent {
  final IAssemblyBody bodyA;
  final IAssemblyBody bodyB;
  final IAssemblyBody newBody;

  ConnectionEvent({
    required this.bodyA,
    required this.bodyB,
    required this.newBody,
  });
}

/// Event fired when a body breaks apart
class DetachmentEvent extends GameEvent {
  final IAssemblyBody originalBody;
  final List<IAssemblyBody> newBodies;

  DetachmentEvent({
    required this.originalBody,
    required this.newBodies,
  });
}

/// Event fired when a hexamer (6-part assembly) is formed
class HexamerFormedEvent extends GameEvent {
  final IAssemblyBody hexamer;

  HexamerFormedEvent({
    required this.hexamer,
  });
}

/// Simple EventBus implementation using Dart Streams
class EventBus implements IEventBus {
  final _controller = StreamController<GameEvent>.broadcast();

  @override
  Stream<T> on<T extends GameEvent>() {
    if (T == GameEvent) {
      return _controller.stream as Stream<T>;
    }
    return _controller.stream.where((event) => event is T).cast<T>();
  }

  @override
  void fire(GameEvent event) {
    _controller.add(event);
  }

  void dispose() {
    _controller.close();
  }
}
