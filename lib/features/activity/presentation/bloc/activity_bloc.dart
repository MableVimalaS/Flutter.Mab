import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/rewards_config.dart';
import '../../../../core/storage/storage_service.dart';
import '../../data/models/activity_model.dart';
import '../../data/repositories/activity_repository_impl.dart';

// --- Events ---

abstract class ActivityEvent extends Equatable {
  const ActivityEvent();

  @override
  List<Object?> get props => [];
}

class LoadActivities extends ActivityEvent {
  const LoadActivities();
}

class AddActivity extends ActivityEvent {
  const AddActivity({
    required this.categoryId,
    required this.durationMinutes,
    this.note = '',
    this.expenseAmount = 0.0,
  });

  final String categoryId;
  final int durationMinutes;
  final String note;
  final double expenseAmount;

  @override
  List<Object?> get props => [categoryId, durationMinutes, note, expenseAmount];
}

class DeleteActivity extends ActivityEvent {
  const DeleteActivity(this.activityId);

  final String activityId;

  @override
  List<Object?> get props => [activityId];
}

class ChangeDate extends ActivityEvent {
  const ChangeDate(this.date);

  final DateTime date;

  @override
  List<Object?> get props => [date];
}

// --- State ---

class ActivityState extends Equatable {
  const ActivityState({
    this.activities = const [],
    this.selectedDate,
    this.isLoading = true,
    this.error,
  });

  final List<ActivityModel> activities;
  final DateTime? selectedDate;
  final bool isLoading;
  final String? error;

  DateTime get currentDate => selectedDate ?? DateTime.now();

  ActivityState copyWith({
    List<ActivityModel>? activities,
    DateTime? selectedDate,
    bool? isLoading,
    String? error,
  }) {
    return ActivityState(
      activities: activities ?? this.activities,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [activities, selectedDate, isLoading, error];
}

// --- BLoC ---

class ActivityBloc extends Bloc<ActivityEvent, ActivityState> {
  ActivityBloc(this._repository, [this._storage])
      : super(const ActivityState()) {
    on<LoadActivities>(_onLoad);
    on<AddActivity>(_onAdd);
    on<DeleteActivity>(_onDelete);
    on<ChangeDate>(_onChangeDate);
  }

  final ActivityRepositoryImpl _repository;
  final StorageService? _storage;
  static const _uuid = Uuid();

  Future<void> _onLoad(
    LoadActivities event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final activities = _repository.getActivitiesForDate(state.currentDate);
    activities.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    emit(state.copyWith(activities: activities, isLoading: false));
  }

  Future<void> _onAdd(
    AddActivity event,
    Emitter<ActivityState> emit,
  ) async {
    final activity = ActivityModel(
      id: _uuid.v4(),
      categoryId: event.categoryId,
      durationMinutes: event.durationMinutes,
      date: state.currentDate,
      note: event.note,
      expenseAmount: event.expenseAmount,
    );

    await _repository.saveActivity(activity);

    // Award or deduct time coins
    final coins =
        RewardsConfig.calculateCoins(event.categoryId, event.durationMinutes);
    if (coins != 0 && _storage != null) {
      await _storage.addCoins(coins);
    }

    // Accumulate life penalty for bad habits
    if (RewardsConfig.isBadHabit(event.categoryId) && _storage != null) {
      final sessions = (event.durationMinutes / 30).ceil();
      final penaltyPerSession =
          RewardsConfig.badHabitPenaltyMinutes[event.categoryId] ?? 0;
      final totalPenalty = sessions * penaltyPerSession;
      await _storage.addLifePenaltyMinutes(totalPenalty);
    }

    add(const LoadActivities());
  }

  Future<void> _onDelete(
    DeleteActivity event,
    Emitter<ActivityState> emit,
  ) async {
    await _repository.deleteActivity(event.activityId);
    add(const LoadActivities());
  }

  Future<void> _onChangeDate(
    ChangeDate event,
    Emitter<ActivityState> emit,
  ) async {
    emit(state.copyWith(selectedDate: event.date));
    add(const LoadActivities());
  }
}
