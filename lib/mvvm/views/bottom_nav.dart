import 'package:flutter/material.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:propertyrent/core/app_color/app_colors.dart';
import 'package:propertyrent/mvvm/views/add/add_view.dart';
import 'package:propertyrent/mvvm/views/home/home_view.dart';
import 'package:propertyrent/mvvm/views/profile/profile_view.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _page = 0;

  void _navigateToProfile() {
    setState(() {
      _page = 2;
    });
  }

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeView(onProfileTap: () => _navigateToProfile()),
      const AddView(),
      const ProfileView(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_page],
      bottomNavigationBar: CurvedNavigationBar(
        index: _page,
        height: 60,
        backgroundColor: Colors.transparent,
        color: AppColors.primary,
        animationDuration: const Duration(milliseconds: 300),
        items: const [
          CurvedNavigationBarItem(
            child: Icon(Icons.home, color: Colors.white),
            label: 'Home',
            labelStyle: TextStyle(color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.add, color: Colors.white),
            label: 'Add',
            labelStyle: TextStyle(color: Colors.white),
          ),
          CurvedNavigationBarItem(
            child: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
            labelStyle: TextStyle(color: Colors.white),
          ),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
    );
  }
}
