import 'package:earnfit/services/model/dashboard/advertisement.dart';
import 'package:equatable/equatable.dart';
import '../../services/model/dashboard/steps_info.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeError extends HomeState {
  final String message;

  HomeError({required this.message});

  @override
  List<Object?> get props => [message];

  @override
  String toString() => 'HomeError { message: $message }';
}

class HomeData extends HomeState {
  final int steps;
  final double distance;
  final double calories;

  HomeData({
    required this.steps,
    required this.distance,
    required this.calories,
  });

  @override
  List<Object?> get props => [steps, distance, calories];

  @override
  String toString() => 'HomeData { steps: $steps, distance: $distance, calories: $calories }';

  HomeData copyWith({int? steps, double? distance, double? calories}) {
    return HomeData(
      steps: steps ?? this.steps,
      distance: distance ?? this.distance,
      calories: calories ?? this.calories,
    );
  }
}

class HomeScreenLoaded extends HomeState {
  final List<AdvertisementsInfo> advertisements;
  final StepsInfo stepsInfo;

  HomeScreenLoaded({
    required this.advertisements,
    required this.stepsInfo,
  });

  @override
  List<Object?> get props => [advertisements, stepsInfo];

  @override
  String toString() => 'HomeScreenLoaded { advertisements: $advertisements, stepsInfo: $stepsInfo }';
}
