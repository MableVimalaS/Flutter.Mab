import 'package:hive/hive.dart';

part 'activity_model.g.dart';

@HiveType(typeId: 0)
class ActivityModel extends HiveObject {
  ActivityModel({
    required this.id,
    required this.categoryId,
    required this.durationMinutes,
    required this.date,
    this.note = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final int durationMinutes;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String note;

  @HiveField(5)
  final DateTime createdAt;

  Duration get duration => Duration(minutes: durationMinutes);

  ActivityModel copyWith({
    String? id,
    String? categoryId,
    int? durationMinutes,
    DateTime? date,
    String? note,
  }) {
    return ActivityModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt,
    );
  }
}
