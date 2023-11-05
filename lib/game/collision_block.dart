import 'package:flame/components.dart';

class CollisionBlock extends PositionComponent {
  CollisionBlock({position, size, required this.isPlatform})
      : super(
          position: position,
          size: size,
        );

  final bool isPlatform;
}
