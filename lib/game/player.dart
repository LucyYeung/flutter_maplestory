import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maplestory/game/collision_block.dart';
import 'package:flutter_maplestory/game/custom_hit_box.dart';
import 'package:flutter_maplestory/maple_story.dart';
import 'package:flutter_maplestory/utils/check_collision.dart';

enum PlayerState {
  alert,
  hitAlert,
  jump,
  prone,
  proneStab,
  stand,
  swing1,
  swing2,
  swing3,
  walk
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<MapleStory>, KeyboardHandler {
  Player({required this.character, Vector2? position})
      : super(
          size: Vector2.all(96),
          position: position,
        );

  final String character;
  late CustomHitBox hitbox = CustomHitBox(30, 0, 40, size.y);

  double horizontalMove = 0;
  double baseVelocity = 180;
  Vector2 velocity = Vector2.zero();

  late List<CollisionBlock> collisionBlocks;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    super.onLoad();
  }

  void _loadAllAnimations() {
    animations = {
      PlayerState.alert: _spriteAnimation('alert', 4, Vector2(56, 71)),
      PlayerState.hitAlert: _spriteAnimation('hit_alert', 4, Vector2(56, 71)),
      PlayerState.jump: _spriteAnimation('jump', 1, Vector2(49, 70)),
      PlayerState.prone: _spriteAnimation('prone', 1, Vector2(75, 44)),
      PlayerState.proneStab: _spriteAnimation('prone_stab', 2, Vector2(89, 44)),
      PlayerState.stand: _spriteAnimation('stand', 4, Vector2(49, 79)),
      PlayerState.swing1: _spriteAnimation('swing1', 3, Vector2(99, 78)),
      PlayerState.swing2: _spriteAnimation('swing2', 3, Vector2(121, 83)),
      PlayerState.swing3: _spriteAnimation('swing3', 3, Vector2(116, 70)),
      PlayerState.walk: _spriteAnimation('walk', 4, Vector2(58, 75)),
    };
    current = PlayerState.stand;
  }

  @override
  void update(double dt) {
    _updatePlayerState(dt);
    _updatePlayerHorizontalMovement(dt);

    _checkHorizontalCollisions();

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
    if (isRight && scale.x < 0) {
      flipHorizontallyAroundCenter();
    } else if (isLeft && scale.x > 0) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x != 0) current = PlayerState.walk;
  }

  void _updatePlayerHorizontalMovement(double dt) {
    velocity.x = horizontalMove * baseVelocity;
    position.x += velocity.x * dt;
  }

  void _checkHorizontalCollisions() {
    for (final block in collisionBlocks) {
      if (!block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.x > 0) {
            velocity.x = 0;
            position.x = block.x - hitbox.offsetX - hitbox.width;
            break;
          } else if (velocity.x < 0) {
            velocity.x = 0;
            position.x = block.x + block.width + hitbox.width + hitbox.offsetX;
            break;
          }
        }
      }
    }
  }

  SpriteAnimation _spriteAnimation(String state, int amount, Vector2 size) {
    return SpriteAnimation.fromFrameData(
      // mixin from HasGameRef
      game.images.fromCache('players/$character/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.5,
        textureSize: size,
      ),
    );
  }
}
