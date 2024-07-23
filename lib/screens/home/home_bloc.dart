import 'package:earnfit/configs/bloc.dart';
import 'package:earnfit/local_storage/config_storage.dart';
import 'package:earnfit/services/api_service.dart';
import 'package:earnfit/services/model/dashboard/step_data.dart';
import 'package:earnfit/services/model/dashboard/steps_info.dart';
import 'package:earnfit/utils/app_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeBloc extends Bloc {
  final APIService apiService = APIService.instance;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final stepCountProcessingFuture = BlocFuture<StepData, String>();
  final fetchStepsInfoFuture = BlocFuture<StepsInfo, String>();

  final stepsInformation = BlocState<StepsInfo?>(null);

  final stepsInRealTime = BlocState<StepData?>(null);

  HomeBloc() {
    registerStates();
    requestPermissions();
  }

  @override
  List<BlocState> registerStates() {
    return [
      stepsInformation,
      stepCountProcessingFuture,
      fetchStepsInfoFuture,
      stepsInRealTime,
    ];
  }


  Future<String?> fetchInvitationText() async {
    final invitationMsgText = await ConfigStorage.getInvitationMsgText();
    final appStoreLink = await ConfigStorage.getAppStoreLink();
    final playStoreLink = await ConfigStorage.getPlayStoreLink();

    if (invitationMsgText == null || (AppUtils.isAndroid && playStoreLink == null) || (!AppUtils.isAndroid && appStoreLink == null)) {
      return null; // or handle the error appropriately
    }

    final String invitationMessage;
    if (AppUtils.isAndroid) {
      invitationMessage = invitationMsgText.replaceAll('{APPLink}', playStoreLink!);
    } else {
      invitationMessage = invitationMsgText.replaceAll('{APPLink}', appStoreLink!);
    }

    return invitationMessage;
  }



  Future<void> fetchTodayStepsInfo() async {
    fetchStepsInfoFuture.addLoading();

    try {
      final userId = await _fetchUserIdFromStorage();
      if (userId == null) {
        fetchStepsInfoFuture.addFailure('User ID is null');
        return;
      }

      final response = await apiService.request(
        '/get-today-steps-info/$userId',
        DioMethod.get,
      );

      if (response.statusCode == 200) {
        final stepsInfo = StepsInfo.fromJson(response.data);
        stepsInformation.add(stepsInfo);
        fetchStepsInfoFuture.addSuccess(stepsInfo);
        _processStepCount(stepsInfo.data?.totalSteps ?? 0);
      } else {
        throw Exception(
            'Failed to fetch steps info. Status code: ${response.statusCode}');
      }
    } catch (e) {
      fetchStepsInfoFuture
          .addFailure('Failed to fetch steps info: ${e.toString()}');
    }
  }

  Future<int?> _fetchUserIdFromStorage() async {
    final userId = await secureStorage.read(key: 'id');
    if (userId != null) {
      return int.tryParse(userId);
    } else {
      throw Exception('User ID not found in storage');
    }
  }

  void requestPermissions() async {
    final statusActivityRecognition =
        await Permission.activityRecognition.status;

    if (statusActivityRecognition.isDenied ||
        statusActivityRecognition.isPermanentlyDenied) {
      final permissions = await Permission.activityRecognition.request();
      if (!permissions.isGranted) {
        throw Exception('Activity recognition permission not granted');
      }
    }
  }

  void listenToStepCountStream() {
    Stream<StepCount>? _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen(onStepCount).onError((error) {
      stepCountProcessingFuture.addFailure(error.toString());
    });
  }

  void onStepCount(StepCount event) {
    final steps = event.steps;
    _processStepCount(steps);
  }

  Future<void> _processStepCount(int steps) async {
    try {
      final caloriesPerStep = await ConfigStorage.getCaloriesPerStep();

      final distance = steps * 0.78 / 1000; // converting to kilometers
      final calories = steps * num.parse(caloriesPerStep!);

      final stepData = StepData(
        steps: steps,
        distance: distance.toString(),
        calories: calories.toInt(),
      );
      stepsInRealTime.add(stepData);
    } catch (error) {
      stepCountProcessingFuture.addFailure(error.toString());
    }
  }

  @override
  Future<void> close() async {
    stepCountProcessingFuture.close();
    fetchStepsInfoFuture.close();
    super.close();
  }
}
