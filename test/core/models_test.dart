import 'package:chronos/features/activity/data/models/activity_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActivityModel', () {
    test('creates with required fields', () {
      final activity = ActivityModel(
        id: 'test-1',
        categoryId: 'work',
        durationMinutes: 120,
        date: DateTime(2026, 3, 1),
      );

      expect(activity.id, 'test-1');
      expect(activity.categoryId, 'work');
      expect(activity.durationMinutes, 120);
      expect(activity.note, '');
      expect(activity.duration, const Duration(hours: 2));
    });

    test('creates with optional note', () {
      final activity = ActivityModel(
        id: 'test-2',
        categoryId: 'learning',
        durationMinutes: 60,
        date: DateTime(2026, 3, 1),
        note: 'Flutter study session',
      );

      expect(activity.note, 'Flutter study session');
    });

    test('copyWith creates new instance with updated fields', () {
      final original = ActivityModel(
        id: 'test-1',
        categoryId: 'work',
        durationMinutes: 120,
        date: DateTime(2026, 3, 1),
      );

      final updated = original.copyWith(
        durationMinutes: 180,
        note: 'Extended session',
      );

      expect(updated.id, 'test-1'); // unchanged
      expect(updated.categoryId, 'work'); // unchanged
      expect(updated.durationMinutes, 180); // changed
      expect(updated.note, 'Extended session'); // changed
    });

    test('duration returns correct Duration object', () {
      final activity = ActivityModel(
        id: '1',
        categoryId: 'exercise',
        durationMinutes: 90,
        date: DateTime(2026, 3, 1),
      );

      expect(activity.duration, const Duration(minutes: 90));
      expect(activity.duration.inHours, 1);
      expect(activity.duration.inMinutes, 90);
    });
  });
}
