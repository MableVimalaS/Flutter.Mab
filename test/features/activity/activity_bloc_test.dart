import 'package:bloc_test/bloc_test.dart';
import 'package:chronos/features/activity/data/models/activity_model.dart';
import 'package:chronos/features/activity/data/repositories/activity_repository_impl.dart';
import 'package:chronos/features/activity/presentation/bloc/activity_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockActivityRepository extends Mock implements ActivityRepositoryImpl {}

class FakeActivityModel extends Fake implements ActivityModel {}

void main() {
  late MockActivityRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeActivityModel());
  });

  setUp(() {
    mockRepository = MockActivityRepository();
  });

  group('ActivityBloc', () {
    final testActivities = [
      ActivityModel(
        id: '1',
        categoryId: 'work',
        durationMinutes: 120,
        date: DateTime.now(),
        note: 'Deep focus session',
      ),
      ActivityModel(
        id: '2',
        categoryId: 'exercise',
        durationMinutes: 45,
        date: DateTime.now(),
      ),
    ];

    blocTest<ActivityBloc, ActivityState>(
      'emits activities when LoadActivities is added',
      setUp: () {
        when(() => mockRepository.getActivitiesForDate(any()))
            .thenReturn(testActivities);
      },
      build: () => ActivityBloc(mockRepository),
      act: (bloc) => bloc.add(const LoadActivities()),
      expect: () => [
        isA<ActivityState>().having((s) => s.isLoading, 'isLoading', true),
        isA<ActivityState>()
            .having((s) => s.isLoading, 'isLoading', false)
            .having((s) => s.activities.length, 'count', 2),
      ],
    );

    blocTest<ActivityBloc, ActivityState>(
      'saves activity and reloads on AddActivity',
      setUp: () {
        when(() => mockRepository.saveActivity(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getActivitiesForDate(any()))
            .thenReturn(testActivities);
      },
      build: () => ActivityBloc(mockRepository),
      act: (bloc) => bloc.add(
        const AddActivity(
          categoryId: 'learning',
          durationMinutes: 60,
          note: 'Flutter study',
        ),
      ),
      verify: (_) {
        verify(() => mockRepository.saveActivity(any())).called(1);
      },
    );

    blocTest<ActivityBloc, ActivityState>(
      'deletes activity and reloads on DeleteActivity',
      setUp: () {
        when(() => mockRepository.deleteActivity(any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getActivitiesForDate(any()))
            .thenReturn([]);
      },
      build: () => ActivityBloc(mockRepository),
      act: (bloc) => bloc.add(const DeleteActivity('1')),
      verify: (_) {
        verify(() => mockRepository.deleteActivity('1')).called(1);
      },
    );

    test('ChangeDate updates selectedDate', () {
      when(() => mockRepository.getActivitiesForDate(any()))
          .thenReturn([]);

      final bloc = ActivityBloc(mockRepository);
      final newDate = DateTime(2026, 1, 15);

      bloc.add(ChangeDate(newDate));

      // State will be updated asynchronously
      expectLater(
        bloc.stream,
        emitsThrough(
          isA<ActivityState>().having(
            (s) => s.selectedDate,
            'selectedDate',
            newDate,
          ),
        ),
      );
    });
  });
}
