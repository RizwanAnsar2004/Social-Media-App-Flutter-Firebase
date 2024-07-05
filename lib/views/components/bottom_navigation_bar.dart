import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:moneyup/constants/colors.dart';
import 'package:moneyup/constants/routes.dart';
import 'package:moneyup/views/chat_home_page.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  const CustomBottomNavigationBar({super.key});

  @override
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.backgroundColor,
        unselectedItemColor: const Color(0xFF5A5A5A),
        selectedItemColor: Colors.white,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        items: [
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/feed.svg',
              height: 24,
              color: _currentIndex == 0 ? Colors.white : Colors.grey,
            ),
            label: 'Feeds',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/group.svg',
              height: 24,
              color: _currentIndex == 1 ? Colors.white : Colors.grey,
            ),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/map.svg',
              height: 24,
              color: _currentIndex == 2 ? Colors.white : Colors.grey,
            ),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/alert.svg',
              height: 24,
              color: _currentIndex == 3 ? Colors.white : Colors.grey,
            ),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              'assets/profile.svg',
              height: 24,
              color: _currentIndex == 4 ? Colors.white : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            switch (index) {
              case 0:
                Navigator.of(context).pushReplacementNamed(homeRoute);
                break;
              case 1:
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
                break;
              case 2:
                Navigator.of(context).pushReplacementNamed(maproute);

                break;
              case 3:
                              Navigator.of(context).pushReplacementNamed(alertroute);

                break;
              case 4:
                Navigator.of(context).pushReplacementNamed(profileRoute);
                break;
            }
          });
        },
      ),
    );
  }
}
