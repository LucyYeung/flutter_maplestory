import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_maplestory/components/collision_block.dart';
import 'package:flutter_maplestory/components/player.dart';

class Level extends World {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;
  List<CollisionBlock> collisionBlocks = [];

  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _spawningObjects();
    _addCollisions();

    await super.onLoad();
  }

  void _spawningObjects() {
    final spawnPointLyayer = level.tileMap.getLayer<ObjectGroup>('SpawnPoint');

    if (spawnPointLyayer != null) {
      for (final spawnPoint in spawnPointLyayer.objects) {
        if (spawnPoint.class_ == 'Player') {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          player.scale.x = 1;
          add(player);
          break;
        }
      }
    }
  }

  void _addCollisions() {
    final collisionsPointLyayer =
        level.tileMap.getLayer<ObjectGroup>('Collisions');

    if (collisionsPointLyayer != null) {
      for (final collision in collisionsPointLyayer.objects) {
        switch (collision.class_) {
          case 'Platform':
            final platform = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: true,
            );
            collisionBlocks.add(platform);
            add(platform);
          case 'Wall':
            final wall = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: false,
            );
            collisionBlocks.add(wall);
          default:
            break;
        }
      }
      player.collisionBlocks = collisionBlocks;
    }
  }
}
