import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    this.isLoading = true,
  });

  final Map<String, int> weeklyCategoryTotals;
  final List<MapEntry<DateTime, int>> dailyTotals;
  final int streakDays;
  final int todaySpentMinutes;
  final int weekTotalMinutes;
  final bool isLoading;

  DashboardState copyWith({
    Map<String, int>? weeklyCategoryTotals,
    List<MapEntry<DateTime, int>>? dailyTotals,
    int? streakDays,
    int? todaySpentMinutes,
    int? weekTotalMinutes,
    bool? isLoading,
  }) {
    return DashboardState(
      weeklyCategoryTotals:
          weeklyCategoryTotals ?? this.weeklyCategoryTotals,
      dailyTotals: dailyTotals ?? this.dailyTotals,
      streakDays: streakDays ?? this.streakDays,
      todaySpentMinutes: todaySpentMinutes ?? this.todaySpentMinutes,
      weekTotalMinutes: weekTotalMinutes ?? this.weekTotalMinutes,
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

    final weeklyTotals = _repository.getWeeklyCategoryTotals();
    final dailyTotals = _repository.getDailyTotalsForWeek();
    final streak = _repository.getStreakDays();
    final todaySpent = _repository.getTotalMinutesForDate(DateTime.now());
    final weekTotal =
        weeklyTotals.values.fold<int>(0, (sum, v) => sum + v);

    emit(
      state.copyWith(
        weeklyCategoryTotals: weeklyTotals,
        dailyTotals: dailyTotals,
        streakDays: streak,
        todaySpentMinutes: todaySpent,
        weekTotalMinutes: weekTotal,
        isLoading: false,
      ),
    );
  }
}
