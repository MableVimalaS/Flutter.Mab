import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/storage_service.dart';

// --- Events ---

abstract class OnboardingEvent extends Equatable {
  const OnboardingEvent();

  @override
  List<Object?> get props => [];
}

class CheckOnboarding extends OnboardingEvent {
  const CheckOnboarding();
}

class CompleteOnboarding extends OnboardingEvent {
  const CompleteOnboarding();
}

class NextPage extends OnboardingEvent {
  const NextPage();
}

class PreviousPage extends OnboardingEvent {
  const PreviousPage();
}

// --- State ---

class OnboardingState extends Equatable {
  const OnboardingState({
    this.hasCompleted = false,
    this.currentPage = 0,
    this.isLoading = true,
  });

  final bool hasCompleted;
  final int currentPage;
  final bool isLoading;

  OnboardingState copyWith({
    bool? hasCompleted,
    int? currentPage,
    bool? isLoading,
  }) {
    return OnboardingState(
      hasCompleted: hasCompleted ?? this.hasCompleted,
      currentPage: currentPage ?? this.currentPage,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [hasCompleted, currentPage, isLoading];
}

// --- BLoC ---

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc(this._storage) : super(const OnboardingState()) {
    on<CheckOnboarding>(_onCheck);
    on<CompleteOnboarding>(_onComplete);
    on<NextPage>(_onNext);
    on<PreviousPage>(_onPrevious);
  }

  final StorageService _storage;

  Future<void> _onCheck(
    CheckOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    final completed = _storage.hasCompletedOnboarding;
    emit(
      state.copyWith(hasCompleted: completed, isLoading: false),
    );
  }

  Future<void> _onComplete(
    CompleteOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    await _storage.completeOnboarding();
    emit(state.copyWith(hasCompleted: true));
  }

  void _onNext(NextPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage < 2) {
      emit(state.copyWith(currentPage: state.currentPage + 1));
    }
  }

  void _onPrevious(PreviousPage event, Emitter<OnboardingState> emit) {
    if (state.currentPage > 0) {
      emit(state.copyWith(currentPage: state.currentPage - 1));
    }
  }
}
