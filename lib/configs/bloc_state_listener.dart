import 'package:earnfit/configs/bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


class BlocStateListener<State> {
  const BlocStateListener(this.blocState);

  final BlocState<State> blocState;

  Widget build({
    required void Function(BuildContext context, State state) listener,
    bool Function(State previousState, State currentState)? listenWhen,
    required Widget child,
  }) {
    return BlocListener<BlocState<State>, State>(
      bloc: blocState,
      listenWhen: listenWhen,
      listener: listener,
      child: child,
    );
  }
}

class DoubleBlocStateListener<State1, State2> {
  const DoubleBlocStateListener(this.blocState1, this.blocState2);

  final BlocState<State1> blocState1;
  final BlocState<State2> blocState2;

  Widget build({
    required void Function(BuildContext context, State1 state1, State2 state2)
    listener,
    bool Function(
        State1? previousState1,
        State1 currentState1,
        State2? previousState2,
        State2 currentState2,
        )? listenWhen,
    required Widget child,
  }) {
    // To achieve the double listener, we repeate the bloc listener widget
    return BlocListener<BlocState<State1>, State1>(
      bloc: blocState1,
      listenWhen: listenWhen == null
          ? null
          : (previousState1, currentState1) {
        return listenWhen(
          previousState1,
          currentState1,
          blocState2.previousState,
          blocState2.state,
        );
      },
      listener: (context, state1) {
        return listener(context, state1, blocState2.state);
      },
      child: BlocListener<BlocState<State2>, State2>(
        bloc: blocState2,
        listenWhen: listenWhen == null
            ? null
            : (previousState2, currentState2) {
          return listenWhen(
            blocState1.previousState,
            blocState1.state,
            previousState2,
            currentState2,
          );
        },
        listener: (context, state2) {
          // Note that a listener will fire as many times as one of the values changed, does not matter if they changed at the same time
          return listener(context, blocState1.state, state2);
        },
        child: child,
      ),
    );
  }
}
