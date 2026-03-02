import 'package:bloc_test/bloc_test.dart';
import 'package:chronos/features/activity/data/models/activity_model.dart';
import 'package:chronos/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:chronos/features/time_wallet/presentation/bloc/time_wallet_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockActivityRepository extends Mock implements ActivityRepositoryImpl {}

void main() {
  late MockActivityRepository mockRepository;

  setUp(() {
    mockRepository = MockActivityRepository();
  });

  group('TimeWalletBloc', () {
    test('initial state is correct', () {
      when(() => mockRepository.getActivitiesForDate(any()))
          .thenReturn([]);
      when(() => mockRepository.dailyHoursBudget).thenReturn(16);
      when(() => mockRepository.getStreakDays()).thenReturn(0);

      final bloc = TimeWalletBloc(mockRepository);
      expect(bloc.state.isLoading, isTrue);
      expect(bloc.state.spentMinutes, equals(0));
      expect(bloc.state.totalBudgetMinutes, equals(960));
    });

    blocTest<TimeWalletBloc, TimeWalletState>(
      'emits loaded state with activities when LoadTimeWallet is added',
      setUp: () {
        when(() => mockRepository.getActivitiesForDate(any())).thenReturn([
          ActivityModel(
            id: '1',
            categoryId: 'work',
            durationMinutes: 120,
            date: DateTime.now(),
          ),
          ActivityModel(
            id: '2',
            categoryId: 'exercise',
            durationMinutes: 60,
            date: DateTime.now(),
          ),
        ]);
        when(() => mockRepository.dailyHoursBudget).thenReturn(16);
        when(() => mockRepository.getStreakDays()).thenReturn(3);
      },
      build: () => TimeWalletBloc(mockRepository),
      act: (bloc) => bloc.add(const LoadTimeWallet()),
      expect: () => [
        isA<TimeWalletState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TimeWalletState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.spentMinutes, 'spentMinutes', 180)
            .having(
              (s) => s.totalBudgetMinutes,
              'totalBudgetMinutes',
              960,
            )
            .having((s) => s.streakDays, 'streakDays', 3)
            .having(
              (s) => s.todayActivities.length,
              'activities count',
              2,
            ),
      ],
    );

    blocTest<TimeWalletBloc, TimeWalletState>(
      'emits empty state when no activities exist',
      setUp: () {
        when(() => mockRepository.getActivitiesForDate(any()))
            .thenReturn([]);
        when(() => mockRepository.dailyHoursBudget).thenReturn(16);
        when(() => mockRepository.getStreakDays()).thenReturn(0);
      },
      build: () => TimeWalletBloc(mockRepository),
      act: (bloc) => bloc.add(const LoadTimeWallet()),
      expect: () => [
        isA<TimeWalletState>().having((s) => s.isLoading, 'isLoading', true),
        isA<TimeWalletState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.spentMinutes, 'spentMinutes', 0)
            .having((s) => s.remainingMinutes, 'remainingMinutes', 960)
            .having(
              (s) => s.todayActivities.length,
              'activities count',
              0,
            ),
      ],
    );

    test('remainingMinutes is clamped to 0', () {
      const state = TimeWalletState(
        totalBudgetMinutes: 960,
        spentMinutes: 1200,
      );
      expect(state.remainingMinutes, equals(0));
    });

    test('spentFraction computes correctly', () {
      const state = TimeWalletState(
        totalBudgetMinutes: 960,
        spentMinutes: 480,
      );
      expect(state.spentFraction, equals(0.5));
    });
  });
}
