import 'package:bloc/bloc.dart';
import 'package:earnfit/screens/home/home_event.dart';
import 'package:earnfit/screens/home/home_state.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/repository/home_repository.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository homeRepository;

  HomeBloc({required this.homeRepository}) : super(HomeInitial()) {
    on<FetchAdvertisements>(_onFetchAdvertisements);
    requestPermissions(); // Initiate permission request
  }

  Future<void> _onFetchAdvertisements(FetchAdvertisements event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      final stepsInfo = await homeRepository.fetchTodayStepsInfo();
      final advertisements = stepsInfo.data?.advertisementsInfo;

      if (advertisements != null) {
        emit(HomeScreenLoaded(advertisements: advertisements, stepsInfo: stepsInfo));
      }

    } catch (error) {
      emit(HomeError(message: error.toString()));
    }
  }

  void requestPermissions() async {
    final statusActivityRecognition = await Permission.activityRecognition.status;

    if (statusActivityRecognition.isDenied) {
      final permissions = await Permission.location.request();

      if (permissions.isGranted) {
        _initPlatformState();
      } else {
        emit(HomeInitial());
      }
    } else {
      _initPlatformState();
    }
  }

  void _initPlatformState() async {
    final statusLocation = await Permission.location.status;
    final statusActivityRecognition = await Permission.activityRecognition.status;

    if (statusLocation.isGranted && statusActivityRecognition.isGranted) {
      _listenToStepCountStream();
    } else {
      emit(HomeInitial());
    }
  }

  void _listenToStepCountStream() {
    Stream<StepCount>? _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(onStepCount).onError(onStepCountError);
  }

  void onStepCount(StepCount event) {
    final steps = event.steps;
    final distance = steps * 0.78 / 1000; // converting to kilometers
    final calories = steps * 0.04;
    emit(HomeData(steps: steps.toInt(), distance: distance, calories: calories));
  }

  void onStepCountError(error) {
    emit(HomeData(steps: 0, distance: 0.0, calories: 0.0));
  }
}
