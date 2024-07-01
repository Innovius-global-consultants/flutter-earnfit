import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../auth/auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() {
    // Simulate some initialization process
    Future.delayed(const Duration(seconds: 3), () {
      // Check if the user is already authenticated
      Auth.isAuthenticated().then((isAuthenticated) async {
        if (isAuthenticated) {
          final locationStatus = await Permission.location.status;
          // If authenticated, proceed to permission handling
          if(!locationStatus.isGranted || locationStatus.isDenied || locationStatus.isPermanentlyDenied){
            _showPermissionRationaleDialog();
          }else{
            context.go('/dashboard');
          }
        } else {
          // If not authenticated, navigate to the login screen
          context.go('/login');
        }
      });
    });
  }

  void _showPermissionRationaleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal by tapping outside
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text('We need your location to track your activities. Please grant location permission.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: Text('Continue'),
          ),
        ],
      ),
    );
  }

  Future<void> _requestPermissions() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      // Permission granted, navigate to dashboard
      context.go('/dashboard');
    } else {
      // Permission denied, show a message
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dialog dismissal by tapping outside
      builder: (context) => AlertDialog(
        title: Text('Location Permission Denied'),
        content: Text('You need to enable location permissions to use the features of this app.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _requestPermissions();
            },
            child: Text('Grant Permission'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/login'); // Navigate to login if they choose not to grant permission
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background color to white
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/icons/bird.png', // Load splash screen image
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            // Add some spacing between the image and the CircularProgressIndicator
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
