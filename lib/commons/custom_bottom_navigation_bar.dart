import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final List<IconData> icons;
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onItemSelected;

  const CustomBottomNavigationBar({
    Key? key,
    required this.icons,
    required this.labels,
    required this.selectedIndex,
    this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          icons.length,
              (index) => _buildBarItem(context, index), // Pass context here
        ),
      ),
    );
  }

  Widget _buildBarItem(BuildContext context, int index) {
    return InkWell(
      onTap: () {
        if (onItemSelected != null) {
          onItemSelected!(index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icons[index],
            color: selectedIndex == index
                ? Theme.of(context).primaryColor
                : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            labels[index],
            style: TextStyle(
              color: selectedIndex == index
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
              fontWeight: selectedIndex == index ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (selectedIndex == index)
            Container(
              width: 50,
              height: 2,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
