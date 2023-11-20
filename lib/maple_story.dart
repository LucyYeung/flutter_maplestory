import 'dart:io';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_maplestory/components/collision_block.dart';
import 'package:flutter_maplestory/components/jump_button.dart';
import 'package:flutter_maplestory/data/levels.dart';
import 'package:flutter_maplestory/components/background.dart';
import 'package:flutter_maplestory/components/level.dart';
import 'package:flutter_maplestory/components/player.dart';

class MapleStory extends FlameGame
    with
        HasKeyboardHandlerComponents,
        LongPressDetector,
        HasCollisionDetection,
        DragCallbacks {
  int currentLevelIndex = 0;
  Player player = Player(character: 'boy');
  List<CollisionBlock> collisionBlocks = [];

  late JoystickComponent joystick;

  @override
  Future<void> onLoad() async {
    await images.loadAllImages();

    _loadLevel();

    if (Platform.isAndroid || Platform.isIOS) {
      _loadJoystick();
      _loadJumpButton();
    }

    await super.onLoad();
  }

  @override
  void update(double dt) {
    if (Platform.isAndroid || Platform.isIOS) {
      _updateJoystick(dt);
    }
    super.update(dt);
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

  void _loadJoystick() {
    final knobPaint = BasicPalette.gray.withAlpha(200).paint();
    final backgroundPaint = BasicPalette.gray.withAlpha(100).paint();
    joystick = JoystickComponent(
      knob: CircleComponent(radius: 24, paint: knobPaint),
      background: CircleComponent(radius: 48, paint: backgroundPaint),
      margin: const EdgeInsets.only(left: 32, bottom: 32),
    );
    add(joystick);
    camera.viewport.add(joystick);
  }

  void _updateJoystick(double dt) {
    switch (joystick.direction) {
      case JoystickDirection.up:
        player.verticalMove = -1;
        break;
      case JoystickDirection.down:
        player.verticalMove = 1;
        break;
      case JoystickDirection.left:
        player.horizontalMove = -1;
        break;
      case JoystickDirection.right:
        player.horizontalMove = 1;
        break;
      case JoystickDirection.upLeft:
        player.horizontalMove = -1;
        player.verticalMove = -1;
        break;
      case JoystickDirection.upRight:
        player.horizontalMove = 1;
        player.verticalMove = -1;
        break;
      case JoystickDirection.downLeft:
        player.horizontalMove = -1;
        player.verticalMove = 1;
        break;
      case JoystickDirection.downRight:
        player.horizontalMove = 1;
        player.verticalMove = 1;
        break;
      case JoystickDirection.idle:
        player.horizontalMove = 0;
        player.verticalMove = 0;
        break;
      default:
        break;
    }
  }

  void _loadJumpButton() {
    JumpButton jumpButton = JumpButton(
      position: Vector2(
        size.x - 100,
        size.y - 100,
      ),
      size: Vector2(50, 50),
    );
    add(jumpButton);
    camera.viewport.add(jumpButton);
  }
}
