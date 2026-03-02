import 'package:bloc_test/bloc_test.dart';
import 'package:chronos/core/storage/storage_service.dart';
import 'package:chronos/features/life_clock/presentation/bloc/life_clock_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockStorageService extends Mock implements StorageService {}

void main() {
  late MockStorageService mockStorage;

  setUp(() {
    mockStorage = MockStorageService();
  });

  group('LifeClockBloc', () {
    blocTest<LifeClockBloc, LifeClockState>(
      'emits state with no birth year when storage returns null',
      build: () {
        when(() => mockStorage.birthYear).thenReturn(null);
        return LifeClockBloc(mockStorage);
      },
      act: (bloc) => bloc.add(const LoadLifeClock()),
      expect: () => [
        isA<LifeClockState>()
            .having((s) => s.hasBirthYear, 'hasBirthYear', false)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<LifeClockBloc, LifeClockState>(
      'emits state with birth year and remaining time when storage has year',
      build: () {
        when(() => mockStorage.birthYear).thenReturn(1995);
        return LifeClockBloc(mockStorage);
      },
      act: (bloc) => bloc.add(const LoadLifeClock()),
      expect: () => [
        isA<LifeClockState>()
            .having((s) => s.hasBirthYear, 'hasBirthYear', true)
            .having((s) => s.birthYear, 'birthYear', 1995)
            .having((s) => s.remainingDuration.inDays, 'remaining > 0',
                greaterThan(0))
            .having((s) => s.isLoading, 'isLoading', false),
      ],
    );

    blocTest<LifeClockBloc, LifeClockState>(
      'SetBirthYear saves to storage and starts timer',
      build: () {
        when(() => mockStorage.birthYear).thenReturn(null);
        when(() => mockStorage.setBirthYear(any()))
            .thenAnswer((_) async {});
        return LifeClockBloc(mockStorage);
      },
      act: (bloc) => bloc.add(const SetBirthYear(2000)),
      expect: () => [
        isA<LifeClockState>()
            .having((s) => s.birthYear, 'birthYear', 2000)
            .having((s) => s.hasBirthYear, 'hasBirthYear', true)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (_) {
        verify(() => mockStorage.setBirthYear(2000)).called(1);
      },
    );

    test('lifeFraction is between 0 and 1 for valid birth year', () {
      final state = LifeClockState(
        birthYear: 1990,
        totalDuration: const Duration(days: 28470), // ~78 years
        elapsedDuration: const Duration(days: 13000), // ~36 years
      );
      expect(state.lifeFraction, greaterThan(0.0));
      expect(state.lifeFraction, lessThan(1.0));
    });

    test('lifeFraction is 0 when totalDuration is zero', () {
      const state = LifeClockState();
      expect(state.lifeFraction, 0.0);
    });

    test('remaining time components are computed correctly', () {
      final state = LifeClockState(
        birthYear: 1990,
        remainingDuration: const Duration(
          days: 365 * 42 + 30 * 5 + 15,
          hours: 8,
          minutes: 30,
          seconds: 45,
        ),
      );
      expect(state.remainingYears, 42);
      expect(state.remainingMonths, greaterThanOrEqualTo(0));
      expect(state.remainingDays, greaterThanOrEqualTo(0));
      expect(state.remainingHours, 8);
      expect(state.remainingMinutes, 30);
      expect(state.remainingSeconds, 45);
    });
  });
}
