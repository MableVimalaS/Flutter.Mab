import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activity/data/models/activity_model.dart';
import '../../../activity/data/repositories/activity_repository_impl.dart';

// --- Events ---

abstract class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  const LoadDashboard();
}

// --- State ---

class DashboardState extends Equatable {
  const DashboardState({
    this.weeklyCategoryTotals = const {},
    this.dailyTotals = const [],
    this.streakDays = 0,
    this.todaySpentMinutes = 0,
    this.weekTotalMinutes = 0,
    this.todayActivities = const [],
    this.todayCategoryMinutes = const {},
    this.isLoading = true,
  });

  final Map<String, int> weeklyCategoryTotals;
  final List<MapEntry<DateTime, int>> dailyTotals;
  final int streakDays;
  final int todaySpentMinutes;
  final int weekTotalMinutes;
  final List<ActivityModel> todayActivities;
  final Map<String, int> todayCategoryMinutes;
  final bool isLoading;

  DashboardState copyWith({
    Map<String, int>? weeklyCategoryTotals,
    List<MapEntry<DateTime, int>>? dailyTotals,
    int? streakDays,
    int? todaySpentMinutes,
    int? weekTotalMinutes,
    List<ActivityModel>? todayActivities,
    Map<String, int>? todayCategoryMinutes,
    bool? isLoading,
  }) {
    return DashboardState(
      weeklyCategoryTotals:
          weeklyCategoryTotals ?? this.weeklyCategoryTotals,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      streakDays: streakDays ?? this.streakDays,
      todaySpentMinutes: todaySpentMinutes ?? this.todaySpentMinutes,
      weekTotalMinutes: weekTotalMinutes ?? this.weekTotalMinutes,
      todayActivities: todayActivities ?? this.todayActivities,
      todayCategoryMinutes:
          todayCategoryMinutes ?? this.todayCategoryMinutes,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        weeklyCategoryTotals,
        dailyTotals,
        streakDays,
        todaySpentMinutes,
        weekTotalMinutes,
        todayActivities,
        todayCategoryMinutes,
        isLoading,
      ];
}

// --- BLoC ---

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc(this._repository) : super(const DashboardState()) {
    on<LoadDashboard>(_onLoad);
  }

  final ActivityRepositoryImpl _repository;

  Future<void> _onLoad(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    final now = DateTime.now();
    final weeklyTotals = _repository.getWeeklyCategoryTotals();
    final dailyTotals = _repository.getDailyTotalsForWeek();
    final streak = _repository.getStreakDays();
    final todaySpent = _repository.getTotalMinutesForDate(now);
    final weekTotal =
        weeklyTotals.values.fold<int>(0, (sum, v) => sum + v);
    final todayActivities = _repository.getActivitiesForDate(now);
    final todayCategoryMinutes = _repository.getCategoryMinutesForDate(now);

    emit(
      state.copyWith(
        weeklyCategoryTotals: weeklyTotals,
        dailyTotals: dailyTotals,
        streakDays: streak,
        todaySpentMinutes: todaySpent,
        weekTotalMinutes: weekTotal,
        todayActivities: todayActivities,
        todayCategoryMinutes: todayCategoryMinutes,
        isLoading: false,
      ),
    );
  }
}
