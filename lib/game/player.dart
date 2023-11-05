import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maplestory/game/maple_story.dart';

enum PlayerState { alert, hitAlert, jump, prone, proneStab, stand, swing, walk }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<MapleStory>, KeyboardHandler {
  Player({required this.character, Vector2? position})
      : super(
          size: Vector2.all(96),
          position: position,
        );

  final String character;

  double horizontalMove = 0;
  double velocity = 180;

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
    current = PlayerState.stand;
  }

  @override
  void update(double dt) {
    _updatePlayerState(dt);

    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMove = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      horizontalMove = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      horizontalMove = 1;
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerState(double dt) {
    current = PlayerState.stand;
    final isRight = horizontalMove > 0;
    final isLeft = horizontalMove < 0;
    if (isRight && scale.x > 0) {
      flipHorizontallyAroundCenter();
    } else if (isLeft && scale.x < 0) {
      flipHorizontallyAroundCenter();
    }
    if (horizontalMove != 0) {
      current = PlayerState.walk;
    }
    position.x += horizontalMove * dt * velocity;
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
