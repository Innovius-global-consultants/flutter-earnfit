import 'package:flutter/material.dart';

class AnimatedCardWidget extends StatelessWidget {
  final VoidCallback onStartActivity;

  const AnimatedCardWidget({Key? key, required this.onStartActivity})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onStartActivity,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow,
              color: Colors.white,
            ),
            SizedBox(width: 10),
            Text(
              'Start your activity, click here',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
