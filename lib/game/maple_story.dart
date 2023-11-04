import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:flutter_maplestory/game/level.dart';

class MapleStory extends FlameGame {
  List<String> levelNames = ['Henesys Hunting Ground I'];
  int currentLevelIndex = 0;

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();

    _loadLevel();

    await super.onLoad();
  }

  void _loadLevel() {
    Level world = Level(levelName: levelNames[currentLevelIndex]);
    final cam = CameraComponent.withFixedResolution(
      world: world,
      width: 2242,
      height: 1634,
    );
    cam.viewfinder
      ..zoom = 3
      ..position = Vector2(960, 1248);
    addAll([cam, world]);
  }
}
