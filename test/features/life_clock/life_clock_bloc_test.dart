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
        when(() => mockStorage.dateOfBirth).thenReturn(null);
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
      'emits state with birth date and remaining time when storage has DOB',
      build: () {
        when(() => mockStorage.dateOfBirth).thenReturn(DateTime(1995, 6, 15));
        when(() => mockStorage.totalCoins).thenReturn(0);
        when(() => mockStorage.lifePenaltyMinutes).thenReturn(0);
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
        when(() => mockStorage.dateOfBirth).thenReturn(null);
        when(() => mockStorage.setBirthYear(any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.totalCoins).thenReturn(0);
        when(() => mockStorage.lifePenaltyMinutes).thenReturn(0);
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

    blocTest<LifeClockBloc, LifeClockState>(
      'SetBirthDate saves to storage and starts timer',
      build: () {
        when(() => mockStorage.dateOfBirth).thenReturn(null);
        when(() => mockStorage.setDateOfBirth(any()))
            .thenAnswer((_) async {});
        when(() => mockStorage.totalCoins).thenReturn(0);
        when(() => mockStorage.lifePenaltyMinutes).thenReturn(0);
        return LifeClockBloc(mockStorage);
      },
      act: (bloc) => bloc.add(SetBirthDate(DateTime(2000, 3, 15))),
      expect: () => [
        isA<LifeClockState>()
            .having((s) => s.birthYear, 'birthYear', 2000)
            .having((s) => s.dateOfBirth, 'dateOfBirth', DateTime(2000, 3, 15))
            .having((s) => s.hasBirthYear, 'hasBirthYear', true)
            .having((s) => s.isLoading, 'isLoading', false),
      ],
      verify: (_) {
        verify(() => mockStorage.setDateOfBirth(DateTime(2000, 3, 15))).called(1);
      },
    );

    test('lifeFraction is between 0 and 1 for valid birth year', () {
      final state = LifeClockState(
        birthYear: 1990,
        dateOfBirth: DateTime(1990),
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
        dateOfBirth: DateTime(1990),
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
