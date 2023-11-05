import 'package:flame/components.dart';
import 'package:flutter_maplestory/game/maple_story.dart';

enum PlayerState { alert, hitAlert, jump, prone, proneStab, stand, swing, walk }

class Player extends SpriteAnimationGroupComponent with HasGameRef<MapleStory> {
  Player({required this.character, Vector2? position})
      : super(
          size: Vector2.all(96),
          position: position,
        );

  final String character;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    super.onLoad();
  }

  void _loadAllAnimations() {
    animations = {
      PlayerState.alert: _spriteAnimation('alert', 4, 2, Vector2(56, 71)),
      PlayerState.hitAlert:
          _spriteAnimation('hit_alert', 4, 2, Vector2(56, 71)),
      PlayerState.jump: _spriteAnimation('jump', 2, 2, Vector2(49, 70)),
      PlayerState.prone: _spriteAnimation('prone', 2, 2, Vector2(75, 44)),
      PlayerState.proneStab:
          _spriteAnimation('prone_stab', 3, 2, Vector2(89, 44)),
      PlayerState.stand: _spriteAnimation('stand', 4, 2, Vector2(49, 79)),
      PlayerState.swing: _spriteAnimation('swing', 12, 4, Vector2(87, 78)),
      PlayerState.walk: _spriteAnimation('walk', 5, 3, Vector2(57, 75)),
    };
    current = PlayerState.swing;
  }

  SpriteAnimation _spriteAnimation(
      String state, int amount, int amountPerRow, Vector2 size) {
    return SpriteAnimation.fromFrameData(
      // mixin from HasGameRef
      game.images.fromCache('players/$character/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.5,
        amountPerRow: amountPerRow,
        textureSize: size,
      ),
    );
  }
}
