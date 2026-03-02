import 'package:intl/intl.dart';

extension DateTimeX on DateTime {
  String get formatted => DateFormat('MMM d, y').format(this);
  String get dayMonth => DateFormat('MMM d').format(this);
  String get timeFormatted => DateFormat('h:mm a').format(this);
  String get dayName => DateFormat('EEEE').format(this);
  String get shortDay => DateFormat('E').format(this);

  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get startOfWeek {
    final diff = weekday - DateTime.monday;
    return subtract(Duration(days: diff)).startOfDay;
  }

  List<DateTime> get daysOfWeek {
    final start = startOfWeek;
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }
}

extension DurationX on Duration {
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    if (hours > 0 && minutes > 0) return '${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h';
    return '${minutes}m';
  }

  String get hoursDecimal => (inMinutes / 60).toStringAsFixed(1);
}
