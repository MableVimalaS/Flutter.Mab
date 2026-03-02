import 'package:chronos/core/extensions/date_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DateTimeX', () {
    test('formatted returns correct string', () {
      final date = DateTime(2026, 3, 15);
      expect(date.formatted, 'Mar 15, 2026');
    });

    test('dayMonth returns correct string', () {
      final date = DateTime(2026, 1, 5);
      expect(date.dayMonth, 'Jan 5');
    });

    test('isSameDay returns true for same day', () {
      final a = DateTime(2026, 3, 15, 10, 30);
      final b = DateTime(2026, 3, 15, 22, 0);
      expect(a.isSameDay(b), isTrue);
    });

    test('isSameDay returns false for different days', () {
      final a = DateTime(2026, 3, 15);
      final b = DateTime(2026, 3, 16);
      expect(a.isSameDay(b), isFalse);
    });

    test('startOfDay returns midnight', () {
      final date = DateTime(2026, 3, 15, 14, 30, 45);
      final start = date.startOfDay;
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('daysOfWeek returns 7 days', () {
      final date = DateTime(2026, 3, 4); // Wednesday
      final days = date.daysOfWeek;
      expect(days.length, 7);
    });
  });

  group('DurationX', () {
    test('formatted returns hours and minutes', () {
      expect(const Duration(hours: 2, minutes: 30).formatted, '2h 30m');
    });

    test('formatted returns only hours when no minutes', () {
      expect(const Duration(hours: 3).formatted, '3h');
    });

    test('formatted returns only minutes when under an hour', () {
      expect(const Duration(minutes: 45).formatted, '45m');
    });

    test('hoursDecimal returns decimal string', () {
      expect(const Duration(minutes: 90).hoursDecimal, '1.5');
      expect(const Duration(minutes: 60).hoursDecimal, '1.0');
    });
  });
}
