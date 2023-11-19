import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter_maplestory/components/collision_block.dart';
import 'package:flutter_maplestory/data/levels.dart';
import 'package:flutter_maplestory/components/background.dart';
import 'package:flutter_maplestory/components/level.dart';
import 'package:flutter_maplestory/components/player.dart';

class MapleStory extends FlameGame
    with
        HasKeyboardHandlerComponents,
        LongPressDetector,
        HasCollisionDetection {
  int currentLevelIndex = 0;
  Player player = Player(character: 'boy');
  List<CollisionBlock> collisionBlocks = [];

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

    // default viewport size is the size of the screen
    camera = CameraComponent(world: world, viewfinder: Viewfinder());

    // Set the camera bounds to the level size
    camera.setBounds(Rectangle.fromCenter(
      center: Vector2(level.width / 2, level.height / 2),
      size: Vector2(level.width / 2 + player.width * 2, level.height),
    ));
    camera.follow(player, snap: true, maxSpeed: 200);
    addAll([world, background]);
  }
}
