import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/rewards_config.dart';
import '../../../../core/storage/storage_service.dart';

// --- Events ---

abstract class LifeClockEvent extends Equatable {
  const LifeClockEvent();

  @override
  List<Object?> get props => [];
}

class LoadLifeClock extends LifeClockEvent {
  const LoadLifeClock();
}

class SetBirthYear extends LifeClockEvent {
  const SetBirthYear(this.year);

  final int year;

  @override
  List<Object?> get props => [year];
}

class _Tick extends LifeClockEvent {
  const _Tick();
}

// --- State ---

class LifeClockState extends Equatable {
  const LifeClockState({
    this.birthYear,
    this.remainingDuration = Duration.zero,
    this.elapsedDuration = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isLoading = true,
  });

  final int? birthYear;
  final Duration remainingDuration;
  final Duration elapsedDuration;
  final Duration totalDuration;
  final bool isLoading;

  bool get hasBirthYear => birthYear != null;

  double get lifeFraction {
    if (totalDuration.inSeconds == 0) return 0.0;
    return (elapsedDuration.inSeconds / totalDuration.inSeconds)
        .clamp(0.0, 1.0);
  }

  int get remainingYears => remainingDuration.inDays ~/ 365;
  int get remainingMonths => (remainingDuration.inDays % 365) ~/ 30;
  int get remainingDays => remainingDuration.inDays % 30;
  int get remainingHours => remainingDuration.inHours % 24;
  int get remainingMinutes => remainingDuration.inMinutes % 60;
  int get remainingSeconds => remainingDuration.inSeconds % 60;

  LifeClockState copyWith({
    int? birthYear,
    Duration? remainingDuration,
    Duration? elapsedDuration,
    Duration? totalDuration,
    bool? isLoading,
  }) {
    return LifeClockState(
      birthYear: birthYear ?? this.birthYear,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        birthYear,
        remainingDuration,
        elapsedDuration,
        totalDuration,
        isLoading,
      ];
}

// --- BLoC ---

class LifeClockBloc extends Bloc<LifeClockEvent, LifeClockState> {
  LifeClockBloc(this._storage) : super(const LifeClockState()) {
    on<LoadLifeClock>(_onLoad);
    on<SetBirthYear>(_onSetBirthYear);
    on<_Tick>(_onTick);
  }

  final StorageService _storage;
  Timer? _timer;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const _Tick());
    });
  }

  Duration _calculateRemaining(int birthYear) {
    final now = DateTime.now();
    final deathDate = DateTime(
      birthYear + RewardsConfig.averageLifeExpectancyYears,
    );
    final remaining = deathDate.difference(now);
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration _calculateElapsed(int birthYear) {
    final now = DateTime.now();
    final birthDate = DateTime(birthYear);
    return now.difference(birthDate);
  }

  Duration _calculateTotal(int birthYear) {
    return Duration(
      days: RewardsConfig.averageLifeExpectancyYears * 365 +
          (RewardsConfig.averageLifeExpectancyYears ~/ 4),
    );
  }

  Future<void> _onLoad(
    LoadLifeClock event,
    Emitter<LifeClockState> emit,
  ) async {
    final birthYear = _storage.birthYear;
    if (birthYear != null) {
      final remaining = _calculateRemaining(birthYear);
      final elapsed = _calculateElapsed(birthYear);
      final total = _calculateTotal(birthYear);

      emit(state.copyWith(
        birthYear: birthYear,
        remainingDuration: remaining,
        elapsedDuration: elapsed,
        totalDuration: total,
        isLoading: false,
      ));
      _startTimer();
    } else {
      emit(state.copyWith(isLoading: false));
    }
  }

  Future<void> _onSetBirthYear(
    SetBirthYear event,
    Emitter<LifeClockState> emit,
  ) async {
    await _storage.setBirthYear(event.year);

    final remaining = _calculateRemaining(event.year);
    final elapsed = _calculateElapsed(event.year);
    final total = _calculateTotal(event.year);

    emit(state.copyWith(
      birthYear: event.year,
      remainingDuration: remaining,
      elapsedDuration: elapsed,
      totalDuration: total,
      isLoading: false,
    ));
    _startTimer();
  }

  void _onTick(_Tick event, Emitter<LifeClockState> emit) {
    if (state.birthYear == null) return;

    final remaining = _calculateRemaining(state.birthYear!);
    final elapsed = _calculateElapsed(state.birthYear!);

    emit(state.copyWith(
      remainingDuration: remaining,
      elapsedDuration: elapsed,
    ));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
