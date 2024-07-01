import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

class PermissionBloc {
  final StreamController<bool> _permissionController = StreamController<bool>();

  Stream<bool> get permissionStream => _permissionController.stream;

  Future<void> requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (status.isDenied) {
      if (await Permission.activityRecognition.request().isGranted) {
        _permissionController.sink.add(true);
      } else {
        _permissionController.sink.add(false);
      }
    } else {
      _permissionController.sink.add(true);
    }
  }

  void dispose() {
    _permissionController.close();
  }
}
