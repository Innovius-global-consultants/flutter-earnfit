import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:location/location.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  LocationData? _currentLocation;

  factory LocationService() {
    return _instance;
  }

  LocationService._internal() {
    _initializeLocation();
  }

  // Method to initialize location tracking
  void _initializeLocation() async {
    Location location = Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    // Check if location services are enabled
    _serviceEnabled = await location.serviceEnabled();
    print('Location service enabled: $_serviceEnabled');
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      print('Requested location service: $_serviceEnabled');
      if (!_serviceEnabled) {
        return; // Location services are not enabled
      }
    }

    // Check for location permissions
    _permissionGranted = await location.hasPermission();
    print('Location permission: $_permissionGranted');
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      print('Requested location permission: $_permissionGranted');
      if (_permissionGranted != PermissionStatus.granted) {
        return; // Permissions are denied
      }
    }

    // Get the initial location
    _currentLocation = await location.getLocation();
    print('Initial location data: $_currentLocation');

    // Store initial location data in secure storage
    if (_currentLocation != null) {
      await _storeLocation(_currentLocation!);
    }

    // Listen for location changes and update stored location
    location.onLocationChanged.listen((LocationData currentLocation) async {
      _currentLocation = currentLocation;
      await _storeLocation(currentLocation);
      print('Updated location data: $currentLocation');
    });
  }

  // Method to store location data in secure storage
  Future<void> _storeLocation(LocationData locationData) async {
    await secureStorage.write(
      key: 'current_location',
      value: '${locationData.latitude},${locationData.longitude}',
    );
  }

  // Method to get the current location
  Future<LocationData?> getCurrentLocation() async {
    if (_currentLocation == null) {
      // Fetch location if not already available
      _currentLocation = await _fetchLocation();
    }
    final  currentLocation = _currentLocation;
    if(currentLocation!=null){
      await _storeLocation(currentLocation);
    }
    return _currentLocation;
  }

  // Internal method to fetch current location
  Future<LocationData?> _fetchLocation() async {
    Location location = Location();
    return await location.getLocation();
  }
}
