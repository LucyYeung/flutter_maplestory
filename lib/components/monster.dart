import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_maplestory/components/custom_hit_box.dart';
import 'package:flutter_maplestory/components/player.dart';
import 'package:flutter_maplestory/data/monsters.dart';
import 'package:flutter_maplestory/maple_story.dart';
import 'package:flutter_maplestory/utils/check_collision.dart';

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
  double baseVelocity = 100;
  Vector2 velocity = Vector2.zero();

  final double _gravity = 9.8;
  final double _jumpVelocity = 160;
  final double _terminalVelocity = 300;
  bool isOnPlatform = false;

  late Component? damageText;

  @override
  Future<void> onLoad() async {
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

          final damageText = TextComponent(
            text: '$damage',
            position: position + Vector2(0, -50),
            size: Vector2(20, 20),
          );

          gameRef.add(damageText);
          gameRef.camera.viewport.add(damageText);
          Future.delayed(const Duration(milliseconds: 500), () {
            damageText.removeFromParent();
          });
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
      MonsterState.die: _spriteAnimation(MonsterState.die)..loop = false,
      MonsterState.hit: _spriteAnimation(MonsterState.hit)..loop = false,
      // MonsterState.jump: _spriteAnimation(MonsterState.jump),
      MonsterState.move: _spriteAnimation(MonsterState.move),
      MonsterState.stand: _spriteAnimation(MonsterState.stand),
    };
    current = MonsterState.stand;
  }

  SpriteAnimation _spriteAnimation(MonsterState state) {
    return SpriteAnimation.fromFrameData(
      // mixin from HasGameRef
      game.images.fromCache('monsters/$name/${state.name}.png'),
      SpriteAnimationData.sequenced(
        amount: monsterSprite[name]?[state]?['amount'] as int,
        stepTime: 0.5,
        textureSize: monsterSprite[name]?[state]?['size'] as Vector2,
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
