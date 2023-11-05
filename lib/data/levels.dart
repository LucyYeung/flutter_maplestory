class LevelData {
  final double height;
  final String levelName;
  final String backgroundName;

  LevelData({
    required this.height,
    required this.levelName,
    required this.backgroundName,
  });
}

List<LevelData> levels = [
  LevelData(
    height: 1634,
    levelName: 'Henesys Hunting Ground I',
    backgroundName: 'Henesys Hunting Ground I.jpeg',
  ),
];
