import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class Level extends World {
  final String levelName;

  Level({required this.levelName});

  late TiledComponent level;

  @override
  Future<void> onLoad() async {
    level = await TiledComponent.load('$levelName.tmx', Vector2.all(16));
    add(level);
    await super.onLoad();
  }
}
