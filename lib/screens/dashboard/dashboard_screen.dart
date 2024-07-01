import 'package:earnfit/screens/activity/activity_screen.dart';
import 'package:earnfit/screens/friends/friends_screen.dart';
import 'package:earnfit/screens/profile/profile_screen.dart';
import 'package:flutter/material.dart';

import '../../commons/custom_bottom_navigation_bar.dart';
import '../../configs/app_colors.dart';
import '../../configs/app_text_styles.dart';
import '../home/home_screen.dart';


class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  String _appBarTitle = 'EARNFIT'; // Initial app bar title

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _updateAppBarTitle(
          index); // Update the app bar title based on the selected index
    });
  }

  void _updateAppBarTitle(int index) {
    setState(() {
      switch (index) {
        case 0:
          _appBarTitle = 'EARNFIT';
          break;
        case 1:
          _appBarTitle = 'Activity';
          break;
        case 2:
          _appBarTitle = 'Friends';
          break;
        case 3:
          _appBarTitle = 'Profile';
          break;
        default:
          _appBarTitle = 'Earnfit';
      }
    });
  }

  static final List<Widget> _pages = <Widget>[
    const HomeScreen(),
    ActivityScreen(),
    FriendsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _appBarTitle == 'EARNFIT'
                ? const Icon(Icons.directions_run, color: Colors.blue)
                : const SizedBox.shrink(),
            _appBarTitle == 'EARNFIT'
                ? const SizedBox(width: 8)
                : const SizedBox.shrink(),
            // Add some space between the icon and the title
            Text(_appBarTitle,style:AppTextStyles.openSans.copyWith(
              color: AppColors.black,
            ),),
          ],
        ),
        actions: <Widget>[
          _appBarTitle == 'EARNFIT'
              ? IconButton(
            icon: SizedBox(
              width: 24, // Adjust the width as needed
              height: 24, // Adjust the height as needed
              child: Image.asset(
                'assets/icons/wallet.png',
                color: AppColors.buttonColor,
                // Optionally, set other properties of the Image.asset widget
              ),
            ),
            onPressed: () {
              // Add functionality here
            },
          )
              : const SizedBox.shrink(),
        ],
      ),
      body: Stack(
        children: [
          _pages[_selectedIndex],
          if (_selectedIndex ==
              0) // Show the waves image only for Home and Activity screens
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                width: double.infinity,
                child: Image.asset(
                  'assets/icons/waves.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        icons: [
          Icons.home,
          Icons.directions_walk,
          Icons.people,
          Icons.person,
        ],
        labels: ['Home', 'Activity', 'Friends', 'Profile'],
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: [
        _buildBottomNavigationItem(Icons.home, 'Home', 0),
        _buildBottomNavigationItem(Icons.directions_walk, 'Activity', 1),
        _buildBottomNavigationItem(Icons.people, 'Friends', 2),
        _buildBottomNavigationItem(Icons.person, 'Profile', 3),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.blue.withOpacity(0.5),
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
          _onItemTapped(index); // Call _onItemTapped method with the index
        });
      },
    );
  }

  BottomNavigationBarItem _buildBottomNavigationItem(
      IconData icon, String label, int index) {
    return BottomNavigationBarItem(
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index
                ? Colors.blue
                : Colors.blue.withOpacity(0.5),
          ),
          const SizedBox(height: 2),
          // Adjust the spacing between icon and text
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index
                  ? Colors.blue
                  : Colors.blue.withOpacity(0.5),
            ),
          ),
          if (_selectedIndex == index)
            Container(
              height: 2, // Height of the underline
              width: 50, // Width of the underline, adjust according to icon size
              color: Colors.blue, // Color of the underline
            ),
        ],
      ),
      label: '', // Empty label to avoid the default label space
    );
  }
}
