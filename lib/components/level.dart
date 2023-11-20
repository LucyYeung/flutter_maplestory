import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_maplestory/components/collision_block.dart';
import 'package:flutter_maplestory/components/custom_hit_box.dart';
import 'package:flutter_maplestory/components/monster.dart';
import 'package:flutter_maplestory/components/player.dart';
import 'package:flutter_maplestory/maple_story.dart';

class Level extends World with HasGameRef<MapleStory> {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;

  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

    _addCollisions();
    _addClimbings();
    _addMonsters();
    _spawningObjects();

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
            game.collisionBlocks.add(platform);
            add(platform);
          case 'Wall':
            final wall = CollisionBlock(
              position: Vector2(collision.x, collision.y),
              size: Vector2(collision.width, collision.height),
              isPlatform: false,
            );
            game.collisionBlocks.add(wall);
          default:
            break;
        }
      }
    }
  }

  void _addClimbings() {
    final climbingsLayer = level.tileMap.getLayer<ObjectGroup>('Climbings');
    if (climbingsLayer == null) return;

    for (final climbing in climbingsLayer.objects) {
      final climbingBlock = CollisionBlock(
        position: Vector2(climbing.x, climbing.y),
        size: Vector2(climbing.width, climbing.height),
        climbType: ClimbType.values
            .firstWhere((v) => v.name == climbing.class_.toLowerCase()),
      );
      game.collisionBlocks.add(climbingBlock);
      add(climbingBlock);
    }
  }

  void _addMonsters() {
    final monstersLayer = level.tileMap.getLayer<ObjectGroup>('Monsters');
    if (monstersLayer == null) return;

    for (final monsterPoint in monstersLayer.objects) {
      switch (monsterPoint.class_) {
        case 'Orange Mushroom':
          final monster = Monster(
            name: monsterPoint.class_,
            hitbox: CustomHitBox(0, 0, 65, 70),
            size: Vector2(65, 76),
            speedRatio: 1.0,
            position: Vector2(monsterPoint.x, monsterPoint.y),
            canJump: true,
          );
          add(monster);
          break;
        case 'Blue Snail':
          final monster = Monster(
            name: monsterPoint.class_,
            hitbox: CustomHitBox(0, 0, 44, 34),
            size: Vector2(44, 34),
            speedRatio: 0.3,
            position: Vector2(monsterPoint.x, monsterPoint.y),
            canJump: false,
          );
          add(monster);
          break;
        default:
          break;
      }
    }
  }
}
