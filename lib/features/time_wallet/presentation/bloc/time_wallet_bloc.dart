import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activity/data/models/activity_model.dart';
import '../../../activity/data/repositories/activity_repository_impl.dart';

// --- Events ---

abstract class TimeWalletEvent extends Equatable {
  const TimeWalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadTimeWallet extends TimeWalletEvent {
  const LoadTimeWallet();
}

class RefreshTimeWallet extends TimeWalletEvent {
  const RefreshTimeWallet();
}

// --- State ---

class TimeWalletState extends Equatable {
  const TimeWalletState({
    this.totalBudgetMinutes = 960, // 16 hours
    this.spentMinutes = 0,
    this.todayActivities = const [],
    this.streakDays = 0,
    this.isLoading = true,
  });

  final int totalBudgetMinutes;
  final int spentMinutes;
  final List<ActivityModel> todayActivities;
  final int streakDays;
  final bool isLoading;

  int get remainingMinutes =>
      (totalBudgetMinutes - spentMinutes).clamp(0, totalBudgetMinutes);

  double get spentFraction =>
      totalBudgetMinutes > 0 ? spentMinutes / totalBudgetMinutes : 0;

  Duration get remainingDuration => Duration(minutes: remainingMinutes);
  Duration get spentDuration => Duration(minutes: spentMinutes);

  TimeWalletState copyWith({
    int? totalBudgetMinutes,
    int? spentMinutes,
    List<ActivityModel>? todayActivities,
    int? streakDays,
    bool? isLoading,
  }) {
    return TimeWalletState(
      totalBudgetMinutes: totalBudgetMinutes ?? this.totalBudgetMinutes,
      spentMinutes: spentMinutes ?? this.spentMinutes,
      todayActivities: todayActivities ?? this.todayActivities,
      streakDays: streakDays ?? this.streakDays,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        totalBudgetMinutes,
        spentMinutes,
        todayActivities,
        streakDays,
        isLoading,
      ];
}

// --- BLoC ---

class TimeWalletBloc extends Bloc<TimeWalletEvent, TimeWalletState> {
  TimeWalletBloc(this._repository) : super(const TimeWalletState()) {
    on<LoadTimeWallet>(_onLoad);
    on<RefreshTimeWallet>(_onRefresh);
  }

  final ActivityRepositoryImpl _repository;

  Future<void> _onLoad(
    LoadTimeWallet event,
    Emitter<TimeWalletState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    await _loadData(emit);
  }

  Future<void> _onRefresh(
    RefreshTimeWallet event,
    Emitter<TimeWalletState> emit,
  ) async {
    await _loadData(emit);
  }

  Future<void> _loadData(Emitter<TimeWalletState> emit) async {
    final today = DateTime.now();
    final activities = _repository.getActivitiesForDate(today);
    final spent = activities.fold<int>(0, (s, a) => s + a.durationMinutes);
    final budget = _repository.dailyHoursBudget * 60;
    final streak = _repository.getStreakDays();

    emit(
      state.copyWith(
        totalBudgetMinutes: budget,
        spentMinutes: spent,
        todayActivities: activities,
        streakDays: streak,
        isLoading: false,
      ),
    );
  }
}
