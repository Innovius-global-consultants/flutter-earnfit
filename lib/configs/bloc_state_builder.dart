import 'package:earnfit/configs/bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';


// Listen to a single state, eg BlocStateBuilder(state).build((context, state) => ...)
class BlocStateBuilder<State> {
  const BlocStateBuilder(this.blocState);

  final BlocState<State> blocState;

  Widget build(
      Widget Function(BuildContext context, State state) builder, {
        bool Function(State previousState, State newState)? buildWhen,
      }) {
    return BlocBuilder<BlocState<State>, State>(
      bloc: blocState,
      buildWhen: buildWhen,
      builder: builder,
    );
  }
}

// Listen to 2 related states, eg, BlocStateBuilder.double(s1, s2).build((context, s1, s2) => ...)
class DoubleBlocStateBuilder<State1, State2> {
  const DoubleBlocStateBuilder(this.blocState1, this.blocState2);

  final BlocState<State1> blocState1;
  final BlocState<State2> blocState2;

  Widget build(
      Widget Function(
          BuildContext context,
          State1 state1,
          State2 state2,
          ) builder,
      ) {
    return BlocBuilder<BlocState<State1>, State1>(
      bloc: blocState1,
      builder: (_, state1) {
        return BlocBuilder<BlocState<State2>, State2>(
          bloc: blocState2,
          builder: (context, state2) {
            return builder(context, state1, state2);
          },
        );
      },
    );
  }
}
