import 'package:bloc_test/bloc_test.dart';
import 'package:chronos/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:chronos/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockActivityRepository extends Mock implements ActivityRepositoryImpl {}

void main() {
  late MockActivityRepository mockRepository;

  setUp(() {
    mockRepository = MockActivityRepository();
  });

  group('DashboardBloc', () {
    blocTest<DashboardBloc, DashboardState>(
      'emits loaded state with weekly data when LoadDashboard is added',
      setUp: () {
        when(() => mockRepository.getWeeklyCategoryTotals()).thenReturn({
          'work': 600,
          'exercise': 180,
          'learning': 240,
        });
        when(() => mockRepository.getDailyTotalsForWeek()).thenReturn([
          MapEntry(DateTime(2026, 3, 2), 180),
          MapEntry(DateTime(2026, 3, 3), 240),
          MapEntry(DateTime(2026, 3, 4), 120),
          MapEntry(DateTime(2026, 3, 5), 300),
          MapEntry(DateTime(2026, 3, 6), 200),
          MapEntry(DateTime(2026, 3, 7), 60),
          MapEntry(DateTime(2026, 3, 8), 0),
        ]);
        when(() => mockRepository.getStreakDays()).thenReturn(5);
        when(() => mockRepository.getTotalMinutesForDate(any()))
            .thenReturn(180);
      },
      build: () => DashboardBloc(mockRepository),
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.streakDays, 'streakDays', 5)
            .having((s) => s.todaySpentMinutes, 'todaySpent', 180)
            .having((s) => s.weekTotalMinutes, 'weekTotal', 1020)
            .having(
              (s) => s.weeklyCategoryTotals.length,
              'categories',
              3,
            ),
      ],
    );

    blocTest<DashboardBloc, DashboardState>(
      'emits empty state when no data exists',
      setUp: () {
        when(() => mockRepository.getWeeklyCategoryTotals()).thenReturn({});
        when(() => mockRepository.getDailyTotalsForWeek()).thenReturn([]);
        when(() => mockRepository.getStreakDays()).thenReturn(0);
        when(() => mockRepository.getTotalMinutesForDate(any()))
            .thenReturn(0);
      },
      build: () => DashboardBloc(mockRepository),
      act: (bloc) => bloc.add(const LoadDashboard()),
      expect: () => [
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', true),
        isA<DashboardState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.weekTotalMinutes, 'weekTotal', 0)
            .having((s) => s.streakDays, 'streakDays', 0),
      ],
    );
  });
}
