import 'package:flutter/material.dart';

class BottomBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomBarItem({super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.5),
          ),
          if (isSelected)
            Container(
              height: 2,
              width: double.infinity,
              color: Colors.blue,
            ),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.blue : Colors.blue.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}


