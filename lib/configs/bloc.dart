import 'package:flutter_bloc/flutter_bloc.dart' as flutter_bloc;

export 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider;

// We do not use Events nor State like the raw Bloc from the pkg
abstract class Bloc extends flutter_bloc.BlocBase<void> {
  // Our Bloc class supports multiple states via BlocState, so, we register them to be opened/closed
  Bloc() : super(null) {
    _allStates = registerStates();

    for (final state in _allStates) {
      state.register();
    }
  }

  late final List<BlocState> _allStates;

  @override
  close() async {
    for (final state in _allStates) {
      state.close();
    }

    super.close();
  }

  // This function helps us to always remember of registering/closing the bloc states
  List<BlocState> registerStates();
}

// Our reactive state that can be used directly (no need to be extended like Cubit nor events like Bloc)
class BlocState<State> extends flutter_bloc.BlocBase<State> {
  BlocState(
    State state, {
    // A validator and formatter function to help with state manipulation
    this.validator = _noopValidator,
    State Function(State state)? formatter,
  }) : super(state) {
    this.formatter = formatter ?? _noopFormatter;
  }

  static bool _noopValidator(state) => true;

  State _noopFormatter(State state) => state;

  final bool Function(State state) validator;
  late final State Function(State state) formatter;

  State? previousState;
  var _isRegistered = false;

  bool get isValid => validator(state);

  State get formatted => formatter(state);

  void register() {
    _isRegistered = true;
  }

  void add(State state) {
    if (_isRegistered) {
      if (!isClosed) {
        previousState = state;
        emit(state);
      }
    } else {
      throw Exception(
        'BlocState was not registered via Bloc.registerStates',
      );
    }
  }
}

// This is a bloc state based on future features, with idle, loading, success and failure statuses
class BlocFuture<SuccessState, FailureState>
    extends BlocState<BlocFutureState<SuccessState, FailureState>> {
  BlocFuture({
    BlocFutureStatus status = BlocFutureStatus.idle,
  }) : super(BlocFutureState<SuccessState, FailureState>(status: status));

  void addIdle() {
    if (!state.isIdle) {
      add(
        BlocFutureState<SuccessState, FailureState>(),
      );
    }
  }

  void addLoading() {
    if (!state.isLoading) {
      add(
        BlocFutureState<SuccessState, FailureState>(
          status: BlocFutureStatus.loading,
        ),
      );
    }
  }

  void addSuccess(SuccessState successState, {bool forceUpdate = false}) {
    if (!state.isSuccess || forceUpdate) {
      add(
        BlocFutureState<SuccessState, FailureState>(
          status: BlocFutureStatus.success,
          successState: successState,
        ),
      );
    }
  }

  void addFailure(FailureState failureState, {bool forceUpdate = false}) {
    if (!state.isFailure || forceUpdate) {
      add(
        BlocFutureState<SuccessState, FailureState>(
          status: BlocFutureStatus.failure,
          failureState: failureState,
        ),
      );
    }
  }
}

class BlocFutureState<SuccessState, FailureState> {
  const BlocFutureState({
    this.status = BlocFutureStatus.idle,
    this.successState,
    this.failureState,
  });

  final BlocFutureStatus status;
  final SuccessState? successState;
  final FailureState? failureState;

  bool get isIdle => status == BlocFutureStatus.idle;

  bool get isLoading => status == BlocFutureStatus.loading;

  bool get isSuccess => status == BlocFutureStatus.success;

  bool get isFailure => status == BlocFutureStatus.failure;

  void onIdle(void Function() callback) {
    if (isIdle) {
      callback();
    }
  }

  void onLoading(void Function() callback) {
    if (isLoading) {
      callback();
    }
  }

  void onSuccess(void Function(SuccessState successState) callback) {
    if (isSuccess) {
      callback(successState as SuccessState);
    }
  }

  void onFailure(void Function(FailureState failureState) callback) {
    if (isFailure) {
      callback(failureState as FailureState);
    }
  }
}

enum BlocFutureStatus { idle, loading, success, failure }
