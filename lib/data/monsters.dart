import 'package:flame/components.dart';

enum MonsterState {
  die,
  hit,
  jump,
  move,
  stand,
}

final monsterSprite = {
  'Orange Mushroom': {
    MonsterState.die: {
      'size': Vector2(65, 74),
      'amount': 3,
    },
    MonsterState.hit: {
      'size': Vector2(62, 65),
      'amount': 1,
    },
    MonsterState.jump: {
      'size': Vector2(62, 64),
      'amount': 1,
    },
    MonsterState.move: {
      'size': Vector2(65, 76),
      'amount': 3,
    },
    MonsterState.stand: {
      'size': Vector2(63, 61),
      'amount': 2,
    },
  },
  'Blue Snail': {
    MonsterState.die: {
      'size': Vector2(67, 37),
      'amount': 3,
    },
    MonsterState.hit: {
      'size': Vector2(41, 39),
      'amount': 1,
    },
    MonsterState.move: {
      'size': Vector2(44, 34),
      'amount': 4,
    },
    MonsterState.stand: {
      'size': Vector2(35, 34),
      'amount': 1,
    },
  },
};
