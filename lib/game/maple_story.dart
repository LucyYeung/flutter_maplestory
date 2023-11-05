import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter_maplestory/data/levels.dart';
import 'package:flutter_maplestory/game/background.dart';
import 'package:flutter_maplestory/game/level.dart';
import 'package:flutter_maplestory/game/player.dart';

class MapleStory extends FlameGame {
  int currentLevelIndex = 0;
  Player player = Player(character: 'boy');

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();

    _loadLevel();

    await super.onLoad();
  }

  void _loadLevel() {
    final level = levels[currentLevelIndex];
    Level world = Level(levelName: level.levelName, player: player);

    final background = Background(
      backgroundName: level.backgroundName,
      height: level.height,
    );

    final cam = CameraComponent.withFixedResolution(
      world: world,
      width: level.height / size.y * size.x,
      height: level.height,
    );
    cam.viewfinder
      ..zoom = level.height / size.y * 0.8
      ..position = Vector2(960, 1248);

    addAll([cam, world, background]);
  }
}
