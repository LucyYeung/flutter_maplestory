import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_maplestory/maple_story.dart';

class AttackButton extends SpriteComponent
    with HasGameRef<MapleStory>, TapCallbacks {
  AttackButton({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
        );
  @override
  FutureOr<void> onLoad() {
    sprite = Sprite(game.images.fromCache('HUD/attack_button.png'));

    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.attack = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.attack = false;
    super.onTapUp(event);
  }
}
