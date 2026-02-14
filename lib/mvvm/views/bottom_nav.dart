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
    final surfaceColor = Theme.of(context).colorScheme.surface;
    return Scaffold(
      body: _pages[_page],
      bottomNavigationBar: CurvedNavigationBar(
        index: _page,
        height: 70,
        backgroundColor: Colors.transparent,
        color: AppColors.primary,
        buttonBackgroundColor: surfaceColor,
        animationDuration: const Duration(milliseconds: 300),
        items: [
          CurvedNavigationBarItem(
            child: Icon(
              Icons.home,
              color: _page == 0 ? AppColors.primary : surfaceColor,
              size: 28,
            ),
            label: 'Home',
            labelStyle: TextStyle(
              color: _page == 0 ? AppColors.primary : surfaceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.add,
              color: _page == 1 ? AppColors.primary : surfaceColor,
              size: 28,
            ),
            label: 'Add',
            labelStyle: TextStyle(
              color: _page == 1 ? AppColors.primary : surfaceColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          CurvedNavigationBarItem(
            child: Icon(
              Icons.person,
              color: _page == 2 ? AppColors.primary : surfaceColor,
              size: 28,
            ),
            label: 'Profile',
            labelStyle: TextStyle(
              color: _page == 2 ? AppColors.primary : surfaceColor,
              fontWeight: FontWeight.bold,
            ),
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
