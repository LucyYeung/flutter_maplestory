import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter_maplestory/maple_story.dart';

class JumpButton extends SpriteComponent
    with HasGameRef<MapleStory>, TapCallbacks {
  JumpButton({
    required Vector2 position,
    required Vector2 size,
  }) : super(
          position: position,
          size: size,
        );

  @override
  void onLoad() async {
    sprite = Sprite(game.images.fromCache('HUD/jump_button.png'));
    return super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    game.player.hasJumped = true;
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.player.hasJumped = false;
    super.onTapUp(event);
  }
}
