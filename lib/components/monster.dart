import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter_maplestory/components/custom_hit_box.dart';
import 'package:flutter_maplestory/maple_story.dart';

enum MonsterState {
  die,
  hit,
  jump,
  move,
  stand,
}

class Monster extends SpriteAnimationGroupComponent
    with HasGameRef<MapleStory> {
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
  final int hp;
  final double speedRatio;
  final bool canJump;

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

  Future<void> _loadAllAnimations() async {
    animations = {
      MonsterState.die: _spriteAnimation('die', 3, Vector2(65, 74))
        ..loop = false,
      MonsterState.hit: _spriteAnimation('hit', 1, Vector2(62, 65)),
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
}
