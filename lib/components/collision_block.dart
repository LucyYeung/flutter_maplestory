import 'package:flame/components.dart';

enum ClimbType {
  ladder,
  rope,
}

class CollisionBlock extends PositionComponent {
  CollisionBlock({
    position = true,
    size,
    this.isPlatform = false,
    this.climbType,
  }) : super(
          position: position,
          size: size,
        );

  final bool isPlatform;
  final ClimbType? climbType;
}
