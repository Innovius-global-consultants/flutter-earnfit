import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onClose; // Callback function to handle close button press
  final int countdownSeconds;
  final VoidCallback onSkip;

  const VideoPlayerWidget({
    Key? key,
    required this.videoUrl,
    required this.onClose,
    required this.countdownSeconds,
    required this.onSkip,
  }) : super(key: key);

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _hasError = false;
  late ValueNotifier<int> _countdownSecondsNotifier;
  late Timer _countdownTimer;

  @override
  void initState() {
    super.initState();
    _countdownSecondsNotifier = ValueNotifier<int>(widget.countdownSeconds);
    _initializeVideoPlayer();
    _startCountdownTimer();
  }

  void _initializeVideoPlayer() async {
    try {
      _controller = VideoPlayerController.network(widget.videoUrl);

      await _controller.initialize();
      setState(() {
        _initialized = true;
      });

      _controller.play();
      _controller.setLooping(true); // Loop the video
    } catch (e) {
      print('Error initializing video player: $e');
      setState(() {
        _hasError = true;
      });
    }
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdownSecondsNotifier.value > 0) {
          _countdownSecondsNotifier.value--;
        } else {
          _countdownTimer.cancel();
        }
      });
    });
  }

  void _handleSkipVideo() {
    _controller.pause();
    widget.onClose(); // Call the onClose callback to close the video player
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the video controller properly
    _countdownTimer.cancel(); // Cancel the countdown timer
    _countdownSecondsNotifier.dispose(); // Dispose the countdown notifier
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _hasError
        ? Center(
            child: Text(
              'Error loading video',
              style: TextStyle(color: Colors.white),
            ),
          )
        : AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: Stack(
              children: [
                VideoPlayer(_controller),
                Positioned(
                  top: 20,
                  right: 20,
                  child: ValueListenableBuilder<int>(
                    valueListenable: _countdownSecondsNotifier,
                    builder: (context, countdownSeconds, child) {
                      return countdownSeconds > 0
                          ? Opacity(
                              opacity: 1.0,
                              child: Text(
                                'Skip in $countdownSeconds seconds',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                _handleSkipVideo();
                                _handleSkipVideo();
                              },
                              child: Text(
                                'Skip',
                                style: TextStyle(color: Colors.black),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                            );
                    },
                  ),
                ),
              ],
            ),
          );
  }
}
