class LevelData {
  final double width;
  final double height;
  final String levelName;
  final String backgroundName;

  LevelData({
    required this.width,
    required this.height,
    required this.levelName,
    required this.backgroundName,
  });
}

List<LevelData> levels = [
  LevelData(
    width: 2242,
    height: 1634,
    levelName: 'Henesys Hunting Ground I',
    backgroundName: 'Henesys Hunting Ground I.jpeg',
  ),
];
