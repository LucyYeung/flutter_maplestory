import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_maplestory/components/custom_hit_box.dart';
import 'package:flutter_maplestory/components/player.dart';
import 'package:flutter_maplestory/maple_story.dart';
import 'package:flutter_maplestory/utils/check_collision.dart';

enum MonsterState {
  die,
  hit,
  jump,
  move,
  stand,
}

class Monster extends SpriteAnimationGroupComponent
    with HasGameRef<MapleStory>, CollisionCallbacks {
  Monster({
    required this.name,
    required this.hitbox,
    required Vector2 position,
    required Vector2 size,
    this.damage = 10,
    this.hp = 100,
    this.speedRatio = 1,
    this.canJump = false,
  }) : super(size: size, position: position - Vector2(0, 96));

  final String name;
  final CustomHitBox hitbox;
  final int damage;
  int hp;
  final double speedRatio;
  final bool canJump;

  bool hasAttacked = false;
  bool isDead = false;

  double horizontalMove = 0;
  double baseVelocity = 180;
  Vector2 velocity = Vector2.zero();

  final double _gravity = 9.8;
  final double _jumpVelocity = 160;
  final double _terminalVelocity = 300;
  bool isOnPlatform = false;

  @override
  Future<void> onLoad() async {
    debugMode = true;
    add(RectangleHitbox(
      position: Vector2(hitbox.offsetX, hitbox.offsetY),
      size: Vector2(hitbox.width, hitbox.height),
    ));
    _loadAllAnimations();
    await super.onLoad();
  }

  @override
  void update(double dt) {
    _updateMonsterVericalMovement(dt);
    _updateVerticalCollisions();
    _detectPlayer(dt);
    super.update(dt);
  }

  @override
  Future<void> onCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) async {
    if (other is Player && !isDead) {
      if (other.attack &&
          other.animationTicker?.currentIndex == 1 &&
          !hasAttacked) {
        hp -= other.damage;
        hasAttacked = true;
        if (hp <= 0) {
          isDead = true;
          current = MonsterState.die;
          await animationTicker?.completed;
          velocity = Vector2.zero();
          removeFromParent();
          return;
        } else {
          current = MonsterState.hit;
        }
      } else if (!other.attack || other.animationTicker?.currentIndex == 0) {
        hasAttacked = false;
        current = MonsterState.move;
      }
      return;
    }
    super.onCollision(intersectionPoints, other);
  }

  void _updateMonsterVericalMovement(double dt) {
    _applyGravity(dt);
  }

  void _applyGravity(double dt) {
    velocity.y += _gravity;
    velocity.y = velocity.y.clamp(-_jumpVelocity, _terminalVelocity);
    position.y += velocity.y * dt;
  }

  void _updateVerticalCollisions() {
    for (final block in game.collisionBlocks) {
      if (block.isPlatform) {
        if (checkCollision(this, block)) {
          isOnPlatform = true;
          velocity.y = 0;
          position.y = block.position.y - hitbox.offsetY - hitbox.height;
        }
      }
    }
  }

  Future<void> _loadAllAnimations() async {
    animations = {
      MonsterState.die: _spriteAnimation('die', 3, Vector2(65, 74))
        ..loop = false,
      MonsterState.hit: _spriteAnimation('hit', 1, Vector2(62, 65))
        ..loop = false,
      MonsterState.jump: _spriteAnimation('jump', 1, Vector2(62, 64)),
      MonsterState.move: _spriteAnimation('move', 3, Vector2(65, 76)),
      MonsterState.stand: _spriteAnimation('stand', 2, Vector2(63, 61)),
    };
    current = MonsterState.stand;
  }

  SpriteAnimation _spriteAnimation(String state, int amount, Vector2 size) {
    return SpriteAnimation.fromFrameData(
      // mixin from HasGameRef
      game.images.fromCache('monsters/$name/$state.png'),
      SpriteAnimationData.sequenced(
        amount: amount,
        stepTime: 0.5,
        textureSize: size,
      ),
    );
  }

  void _detectPlayer(dt) {
    if (hasAttacked) return;

    final player = game.player;

    if (scale.x > 0) {
      if (player.scale.x > 0) {
        if (position.x + hitbox.offsetX <
            player.position.x - player.hitbox.offsetX - player.hitbox.width) {
          horizontalMove = 1;
          scale.x = -1;
        }
      } else {
        if (position.x - hitbox.offsetX < player.position.x) {
          horizontalMove = 1;
          scale.x = -1;
        }
      }
    } else {
      if (player.scale.x > 0) {
        if (player.position.x - player.hitbox.offsetX <
            position.x - hitbox.offsetX - hitbox.width) {
          horizontalMove = -1;
          scale.x = 1;
        }
      } else {
        if (player.position.x + player.hitbox.offsetX + player.hitbox.width <
            position.x - hitbox.offsetX - hitbox.width) {
          horizontalMove = -1;
          scale.x = 1;
        }
      }
    }
    position.x += horizontalMove * baseVelocity * speedRatio * dt;
  }
}
