import 'package:flutter/material.dart';

import '../configs/app_text_styles.dart';

class InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final String iconAsset; // Asset path for the icon

  const InfoCard({
    Key? key,
    required this.title,
    required this.value,
    required this.iconAsset,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image.asset(
            iconAsset,
            height: 30, // Adjust the height as needed
            width: 30,
            color: Colors.blue,
          ),
          Text(
            value,
            style: AppTextStyles.openSans.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          Text(
            title,
            style: AppTextStyles.openSans.copyWith(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}