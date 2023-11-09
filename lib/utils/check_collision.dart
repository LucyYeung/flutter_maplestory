import 'package:flutter_maplestory/components/collision_block.dart';
import 'package:flutter_maplestory/components/custom_hit_box.dart';
import 'package:flutter_maplestory/components/monster.dart';
import 'package:flutter_maplestory/components/player.dart';

bool checkCollision(dynamic target, CollisionBlock block) {
  late CustomHitBox hitbox;
  if (target is Player) {
    hitbox = target.hitbox;
  } else if (target is Monster) {
    hitbox = target.hitbox;
  }

  final hitboxWidth = hitbox.width;
  final hitboxHeight = hitbox.height;

  // calculate left corner of target hitbox
  final targetX = (target.scale.x < 0)
      ? target.x - hitbox.offsetX - hitboxWidth
      : target.x + hitbox.offsetX;

  final targetY = target.y + hitbox.offsetY;

  // calculate bottom corner of target hitbox
  // if target is on platform, use the bottom of the hitbox
  // otherwise use the top of the hitbox
  final fixedY = targetY + (block.isPlatform ? hitboxHeight : 0);

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // check if target's left & right side is inside the block
  // check if target's top & bottom side is over the block
  return (targetX < blockX + blockWidth &&
      targetX + hitboxWidth > blockX &&
      fixedY < blockY + blockHeight &&
      targetY + hitboxHeight > blockY);
}
