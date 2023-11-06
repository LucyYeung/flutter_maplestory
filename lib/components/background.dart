import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/painting.dart';

class Background extends ParallaxComponent {
  @override
  final double height;
  final String backgroundName;

  Background({required this.height, required this.backgroundName});

  @override
  Future<FutureOr<void>> onLoad() async {
    parallax = await game.loadParallax(
      [
        ParallaxImageData('maps/backgrounds/$backgroundName'),
      ],
      fill: LayerFill.none,
      size: Vector2(height / size.y * size.x, height),
      alignment: Alignment.center,
      filterQuality: FilterQuality.high,
      baseVelocity: Vector2(5, 0),
      velocityMultiplierDelta: Vector2(1.2, 1.0),
    );
  }
}
