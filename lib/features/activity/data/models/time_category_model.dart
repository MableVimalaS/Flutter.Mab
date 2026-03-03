import 'package:hive_ce/hive.dart';

part 'time_category_model.g.dart';

@HiveType(typeId: 1)
class TimeCategoryModel extends HiveObject {
  TimeCategoryModel({
    required this.id,
    required this.name,
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;
}
