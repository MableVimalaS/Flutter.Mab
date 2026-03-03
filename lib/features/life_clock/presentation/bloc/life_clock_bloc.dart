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

class SetBirthDate extends LifeClockEvent {
  const SetBirthDate(this.dateOfBirth);

  final DateTime dateOfBirth;

  @override
  List<Object?> get props => [dateOfBirth];
}

class RefreshLifeAdjustments extends LifeClockEvent {
  const RefreshLifeAdjustments();
}

class _Tick extends LifeClockEvent {
  const _Tick();
}

// --- State ---

class LifeClockState extends Equatable {
  const LifeClockState({
    this.birthYear,
    this.dateOfBirth,
    this.remainingDuration = Duration.zero,
    this.elapsedDuration = Duration.zero,
    this.totalDuration = Duration.zero,
    this.isLoading = true,
    this.lifeBonusDays = 0,
    this.lifePenaltyMinutes = 0,
    this.adjustedLifeExpectancyDays = 0,
  });

  final int? birthYear;
  final DateTime? dateOfBirth;
  final Duration remainingDuration;
  final Duration elapsedDuration;
  final Duration totalDuration;
  final bool isLoading;
  final int lifeBonusDays;
  final int lifePenaltyMinutes;
  final int adjustedLifeExpectancyDays;

  bool get hasBirthYear => dateOfBirth != null || birthYear != null;

  DateTime? get effectiveBirthDate =>
      dateOfBirth ?? (birthYear != null ? DateTime(birthYear!) : null);

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
    DateTime? dateOfBirth,
    Duration? remainingDuration,
    Duration? elapsedDuration,
    Duration? totalDuration,
    bool? isLoading,
    int? lifeBonusDays,
    int? lifePenaltyMinutes,
    int? adjustedLifeExpectancyDays,
  }) {
    return LifeClockState(
      birthYear: birthYear ?? this.birthYear,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      remainingDuration: remainingDuration ?? this.remainingDuration,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      isLoading: isLoading ?? this.isLoading,
      lifeBonusDays: lifeBonusDays ?? this.lifeBonusDays,
      lifePenaltyMinutes: lifePenaltyMinutes ?? this.lifePenaltyMinutes,
      adjustedLifeExpectancyDays:
          adjustedLifeExpectancyDays ?? this.adjustedLifeExpectancyDays,
    );
  }

  @override
  List<Object?> get props => [
        birthYear,
        dateOfBirth,
        remainingDuration,
        elapsedDuration,
        totalDuration,
        isLoading,
        lifeBonusDays,
        lifePenaltyMinutes,
        adjustedLifeExpectancyDays,
      ];
}

// --- Helper ---

class _LifeAdjustments {
  const _LifeAdjustments({required this.bonusDays, required this.penaltyMinutes});
  final int bonusDays;
  final int penaltyMinutes;
}

// --- BLoC ---

class LifeClockBloc extends Bloc<LifeClockEvent, LifeClockState> {
  LifeClockBloc(this._storage) : super(const LifeClockState()) {
    on<LoadLifeClock>(_onLoad);
    on<SetBirthYear>(_onSetBirthYear);
    on<SetBirthDate>(_onSetBirthDate);
    on<RefreshLifeAdjustments>(_onRefreshAdjustments);
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

  _LifeAdjustments _getAdjustments() {
    final totalCoins = _storage.totalCoins;
    final bonusDays = RewardsConfig.totalLifeBonusDays(totalCoins);
    final penaltyMinutes = _storage.lifePenaltyMinutes;
    return _LifeAdjustments(bonusDays: bonusDays, penaltyMinutes: penaltyMinutes);
  }

  Duration _calculateAdjustedTotal(_LifeAdjustments adj) {
    final baseDays = RewardsConfig.averageLifeExpectancyYears * 365 +
        (RewardsConfig.averageLifeExpectancyYears ~/ 4);
    final totalMinutes =
        (baseDays + adj.bonusDays) * 24 * 60 - adj.penaltyMinutes;
    return Duration(minutes: totalMinutes > 0 ? totalMinutes : 0);
  }

  Duration _calculateRemaining(DateTime birthDate, _LifeAdjustments adj) {
    final now = DateTime.now();
    final elapsed = now.difference(birthDate);
    final total = _calculateAdjustedTotal(adj);
    final remaining = total - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  Duration _calculateElapsed(DateTime birthDate) {
    final now = DateTime.now();
    return now.difference(birthDate);
  }

  int _adjustedDays(_LifeAdjustments adj) {
    final baseDays = RewardsConfig.averageLifeExpectancyYears * 365 +
        (RewardsConfig.averageLifeExpectancyYears ~/ 4);
    final totalMinutes =
        (baseDays + adj.bonusDays) * 24 * 60 - adj.penaltyMinutes;
    return totalMinutes > 0 ? totalMinutes ~/ (24 * 60) : 0;
  }

  void _emitClock(DateTime birthDate, Emitter<LifeClockState> emit) {
    final adj = _getAdjustments();
    final remaining = _calculateRemaining(birthDate, adj);
    final elapsed = _calculateElapsed(birthDate);
    final total = _calculateAdjustedTotal(adj);

    emit(state.copyWith(
      birthYear: birthDate.year,
      dateOfBirth: birthDate,
      remainingDuration: remaining,
      elapsedDuration: elapsed,
      totalDuration: total,
      isLoading: false,
      lifeBonusDays: adj.bonusDays,
      lifePenaltyMinutes: adj.penaltyMinutes,
      adjustedLifeExpectancyDays: _adjustedDays(adj),
    ));
  }

  Future<void> _onLoad(
    LoadLifeClock event,
    Emitter<LifeClockState> emit,
  ) async {
    final dob = _storage.dateOfBirth;
    if (dob != null) {
      _emitClock(dob, emit);
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
    _emitClock(DateTime(event.year), emit);
    _startTimer();
  }

  Future<void> _onSetBirthDate(
    SetBirthDate event,
    Emitter<LifeClockState> emit,
  ) async {
    await _storage.setDateOfBirth(event.dateOfBirth);
    _emitClock(event.dateOfBirth, emit);
    _startTimer();
  }

  Future<void> _onRefreshAdjustments(
    RefreshLifeAdjustments event,
    Emitter<LifeClockState> emit,
  ) async {
    final birthDate = state.effectiveBirthDate;
    if (birthDate == null) return;
    _emitClock(birthDate, emit);
  }

  void _onTick(_Tick event, Emitter<LifeClockState> emit) {
    final birthDate = state.effectiveBirthDate;
    if (birthDate == null) return;
    _emitClock(birthDate, emit);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
