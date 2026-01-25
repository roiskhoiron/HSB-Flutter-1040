class Habit {
  final String name;
  final String frequency;
  final int target;
  int currentProgress;

  Habit({
    required this.name,
    required this.frequency,
    required this.target,
    this.currentProgress = 0,
  });
}