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

    if (invitationMsgText == null ||
        (AppUtils.isAndroid && playStoreLink == null) ||
        (!AppUtils.isAndroid && appStoreLink == null)) {
      return null;
    }

    final String invitationMessage;
    if (AppUtils.isAndroid) {
      invitationMessage =
          invitationMsgText.replaceAll('{APPLink}', playStoreLink!);
    } else {
      invitationMessage =
          invitationMsgText.replaceAll('{APPLink}', appStoreLink!);
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
        try {
          final stepsInfo = StepsInfo.fromJson(response.data);
          stepsInformation.add(stepsInfo);
          fetchStepsInfoFuture.addSuccess(stepsInfo);
          await _processStepCount(stepsInfo.data?.totalSteps ?? 0);
          _scheduleDailyReset();
        } catch (e) {
          print(e);
        }
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
    print('stepssadsa');
    print(steps);
    _processStepCount(steps);
  }

  Future<void> _processStepCount(int steps) async {
    try {
      final initialStepCount = await _getInitialStepCount();
      final adjustedSteps = steps - initialStepCount;
      final caloriesPerStep = await ConfigStorage.getCaloriesPerStep();
      final distance = adjustedSteps * 0.78 / 1000; // converting to kilometers
      final calories =
          adjustedSteps * num.parse(caloriesPerStep ?? 0.04.toString());
      final stepData = StepData(
        steps: adjustedSteps,
        distance: distance.toString(),
        calories: calories.toInt(),
      );
      stepsInRealTime.add(stepData);
    } catch (error) {
      stepCountProcessingFuture.addFailure(error.toString());
    }
  }

  Future<int> _getInitialStepCount() async {
    final initialStepCount =
        await secureStorage.read(key: 'initial_step_count');
    return initialStepCount != null ? int.parse(initialStepCount) : 0;
  }

  Future<void> _setInitialStepCount(int steps) async {
    await secureStorage.write(
        key: 'initial_step_count', value: steps.toString());
  }

  Future<void> _resetStepCount() async {
    final stepCount = await Pedometer.stepCountStream.first;
    await _setInitialStepCount(stepCount.steps);
  }

  void _scheduleDailyReset() async {
    final lastResetTimeString =
        await secureStorage.read(key: 'last_reset_time');
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    if (lastResetTimeString == null) {
      // First-time setup, initialize last reset time
      await secureStorage.write(
          key: 'last_reset_time', value: currentTime.toString());
    } else {
      final lastResetTime = int.parse(lastResetTimeString);
      if (DateTime.now()
              .difference(DateTime.fromMillisecondsSinceEpoch(lastResetTime))
              .inDays >=
          1) {
        await _saveStepData();
        await _resetStepCount();
        await secureStorage.write(
            key: 'last_reset_time', value: currentTime.toString());
      }
    }
  }

  Future<void> _saveStepData() async {
    try {
      final steps = stepsInRealTime.state?.steps;
      final sponsorId =
          stepsInformation.state?.data?.advertisementsInfo?[0].sponsorId;
      if (sponsorId != null) {
        final body = {
          "step_count": steps,
          "distance_covered": stepsInRealTime.state?.distance,
          "sponsor_id": sponsorId
        };

        final response = await apiService.request(
          '/save-user-steps',
          DioMethod.post,
          param: body,
        );

        if (response.statusCode == 200) {
          print('Step data saved successfully');
        } else {
          throw Exception(
              'Failed to save step data. Status code: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Error saving step data: ${e.toString()}');
    }
  }

  @override
  Future<void> close() async {
    stepCountProcessingFuture.close();
    fetchStepsInfoFuture.close();
    super.close();
  }
}
