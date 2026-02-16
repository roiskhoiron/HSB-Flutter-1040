import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 0)
class Habit {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String frequency;

  @HiveField(3)
  final int target;

  @HiveField(4)
  final int currentProgress;

  @HiveField(5)
  final DateTime dueDate;

  @HiveField(6)
  final String status; // 'Upcoming', 'Ongoing', 'Completed'

  @HiveField(7)
  final DateTime createdAt;

  Habit({
    required this.id,
    required this.name,
    required this.frequency,
    required this.target,
    required this.currentProgress,
    required this.dueDate,
    required this.status,
    required this.createdAt,
  });

  factory Habit.fromJson(Map<String, dynamic> json, String id) {
    // Parse status based on currentProgress vs target
    String status = 'Upcoming';
    if (json['currentProgress'] != null) {
      if (json['currentProgress'] >= (json['target'] ?? 0)) {
        status = 'Completed';
      } else if (json['currentProgress'] > 0) {
        status = 'Ongoing';
      }
    }

    return Habit(
      id: id,
      name: json['name'],
      frequency: json['frequency'],
      target: json['target'] ?? 0,
      currentProgress: json['currentProgress'] ?? 0,
      dueDate: json['dueDate'] != null
          ? (json['dueDate'] as dynamic).toDate()
          : DateTime.now().add(const Duration(days: 7)),
      status: status,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'frequency': frequency,
      'target': target,
      'currentProgress': currentProgress,
      'dueDate': dueDate,
      'createdAt': createdAt,
    };
  }
}
