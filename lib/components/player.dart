import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flutter_maplestory/maple_story.dart';
import 'package:flutter_maplestory/utils/check_collision.dart';

import 'collision_block.dart';
import 'custom_hit_box.dart';

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
  walk,
  ladder,
  stopLadder,
  rope,
  stopRope,
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<MapleStory>, KeyboardHandler {
  Player({required this.character, Vector2? position, this.damage = 20})
      : super(
          size: Vector2.all(96),
          position: position,
        );

  final String character;
  final int damage;
  late CustomHitBox hitbox = CustomHitBox(6, 0, 40, 79);
  late RectangleHitbox attackHitbox = RectangleHitbox(
    position: Vector2(hitbox.offsetX, hitbox.offsetY),
    size: Vector2(hitbox.width, hitbox.height),
  );

  double horizontalMove = 0;
  double baseVelocity = 300;
  Vector2 velocity = Vector2.zero();

  final double _gravity = 9.8;
  final double _jumpVelocity = 280;
  final double _terminalVelocity = 280;
  bool hasJumped = false;
  bool isOnPlatform = false;
  double timeElapsed = 0;
  static const timePerFrame = 1 / 60;

  bool upPressed = false;
  ClimbType? climbType;
  double verticalMove = 0;
  double climbVelocity = 70;
  double? climbingMinY;
  double? climbingMaxY;

  bool attack = false;
  double attackTime = 0.0;
  int attckType = 0;
  bool hitMonster = false;

  @override
  Future<void> onLoad() async {
    _loadAllAnimations();
    add(attackHitbox);
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
      PlayerState.ladder: _spriteAnimation('ladder', 2, Vector2(52, 77)),
      PlayerState.stopLadder: _spriteAnimation('ladder', 1, Vector2(52, 77)),
      PlayerState.rope: _spriteAnimation('rope', 2, Vector2(49, 83)),
      PlayerState.stopRope: _spriteAnimation('rope', 1, Vector2(49, 83)),
    };
    current = PlayerState.stand;
  }

  @override
  void update(double dt) {
    _updatePlayerState(dt);
    _updatePlayerHorizontalMovement(dt);
    _updatePlayerVerticalMovement(dt);

    _checkHorizontalCollisions();
    _checkVerticalCollisions();

    super.update(dt);
  }

  @override
  void updateTree(double dt) {
    timeElapsed += dt;

    if (timeElapsed > timePerFrame) {
      timeElapsed -= timePerFrame;
      super.updateTree(timePerFrame);
    }
  }

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalMove = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      horizontalMove = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      horizontalMove = 1;
    }

    verticalMove = 0;
    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      verticalMove = -1;
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      verticalMove = 1;
    }

    hasJumped = keysPressed.contains(LogicalKeyboardKey.space);

    attack = keysPressed.contains(LogicalKeyboardKey.controlLeft);

    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerState(double dt) {
    hitbox = CustomHitBox((size.x - 40) / 2, 2, 40, 65);

    final isRight = horizontalMove > 0;
    final isLeft = horizontalMove < 0;
    if (isRight && scale.x < 0 && climbType == null) {
      flipHorizontallyAroundCenter();
    } else if (isLeft && scale.x > 0 && climbType == null) {
      flipHorizontallyAroundCenter();
    }
    if (velocity.x == 0 && !attack) {
      current = PlayerState.stand;
      size = Vector2(49, 79);
    }
    if (velocity.x != 0) {
      current = PlayerState.walk;
      size = Vector2(58, 75);
    }
    if (velocity.y != 0) {
      current = PlayerState.jump;
      size = Vector2(49, 70);
    }

    if (attack) {
      attackTime += dt;
      if (attackTime >= 1) {
        attackTime = 0;
        attckType = (attckType + 1) % 3;
      }
      if (attckType == 0) {
        current = PlayerState.swing1;
        size = Vector2(99, 78);
      }

      if (attckType == 1) {
        current = PlayerState.swing2;
        size = Vector2(121, 83);
      }

      if (attckType == 2) {
        current = PlayerState.swing3;
        size = Vector2(116, 70);
      }
      hitbox = CustomHitBox((size.x - 90) / 2, 2, 90, 65);
    } else {
      attackTime = 0;
      attckType = 0;
    }

    if (climbType == ClimbType.ladder) {
      current = verticalMove == 0 ? PlayerState.stopLadder : PlayerState.ladder;
      size = Vector2(52, 77);
    }
    if (climbType == ClimbType.rope) {
      current = verticalMove == 0 ? PlayerState.stopRope : PlayerState.rope;
      size = Vector2(49, 83);
    }

    attackHitbox.position = Vector2(hitbox.offsetX, hitbox.offsetY);
    attackHitbox.size = Vector2(hitbox.width, hitbox.height);
  }

  void _updatePlayerHorizontalMovement(double dt) {
    if (climbType != null) return;
    velocity.x = horizontalMove * baseVelocity;
    position.x += velocity.x * dt;
  }

  void _updatePlayerVerticalMovement(double dt) {
    if (velocity.y == 0 && climbType == null) {
      isOnPlatform = true;
    }

    if (hasJumped && isOnPlatform) _playerJump(dt);

    if (climbType != null) _playerClimb(dt);

    if (climbType == null) _applyGravity(dt);
  }

  void _playerJump(double dt) {
    velocity.y = -_jumpVelocity;
    position.y += velocity.y * dt;
    isOnPlatform = false;
    hasJumped = false;
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _playerClimb(double dt) {
    final y = position.y + verticalMove * climbVelocity * dt;

    final headY = y + hitbox.offsetY;
    final footY = y + hitbox.offsetY + hitbox.height;

    bool isLeave = false;

    if (footY < climbingMinY!) {
      position.y = climbingMinY! - hitbox.height - hitbox.offsetY;
      isLeave = true;
    } else if (headY > climbingMaxY!) {
      position.y = climbingMaxY! - hitbox.offsetY;
      isLeave = true;
    } else {
      position.y = y;
    }

    if (isLeave || hasJumped) {
      climbType = null;
      climbingMinY = null;
      climbingMaxY = null;
      velocity.y = 0;
    }
  }

  void _checkHorizontalCollisions() {
    for (final block in game.collisionBlocks) {
      if (!block.isPlatform && block.climbType == null) {
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

  void _checkVerticalCollisions() {
    for (final block in game.collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          if (velocity.y > 0) {
            velocity.y = 0;
            position.y = block.y - hitbox.height - hitbox.offsetY;
            isOnPlatform = true;
            break;
          }
        }
      }
      if (block.climbType != null) {
        if (verticalMove < 0) {
          if (checkCollision(this, block)) {
            isOnPlatform = false;
            climbType = block.climbType;

            climbingMinY = block.y;
            climbingMaxY = block.y + block.height;

            final climbingMidX = block.x + block.width / 2;

            position.x = climbingMidX - width / 2 * (scale.x > 0 ? 1 : -1);
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
          amount: amount, stepTime: 0.5, textureSize: size, loop: true),
    );
  }
}
