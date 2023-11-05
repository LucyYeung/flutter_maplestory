import 'package:flutter_maplestory/game/collision_block.dart';
import 'package:flutter_maplestory/game/player.dart';

bool checkCollision(Player player, CollisionBlock block) {
  final hitbox = player.hitbox;

  final hitboxWidth = hitbox.width;
  final hitboxHeight = hitbox.height;

  // calculate left corner of player hitbox
  final playerX = (player.scale.x < 0)
      ? player.x - hitbox.offsetX - hitboxWidth
      : player.x + hitbox.offsetX;

  final playerY = player.y + hitbox.offsetY;

  // calculate bottom corner of player hitbox
  // if player is on platform, use the bottom of the hitbox
  // otherwise use the top of the hitbox
  final fixedY = playerY + (block.isPlatform ? hitboxHeight : 0);

  final blockX = block.x;
  final blockY = block.y;
  final blockWidth = block.width;
  final blockHeight = block.height;

  // check if player's left & right side is inside the block
  // check if player's top & bottom side is over the block
  return (playerX < blockX + blockWidth &&
      playerX + hitboxWidth > blockX &&
      fixedY < blockY + blockHeight &&
      playerY + hitboxHeight > blockY);
}
