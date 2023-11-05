import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_maplestory/game/player.dart';

class Level extends World {
  final String levelName;
  final Player player;

  Level({required this.levelName, required this.player});

  late TiledComponent level;

  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);

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
}
