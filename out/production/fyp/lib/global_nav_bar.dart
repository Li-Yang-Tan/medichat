import 'package:flutter/material.dart';
import 'package:medichat/Chat/Chat.dart';
import 'package:medichat/Diary/Diary.dart';
import 'package:medichat/More/More.dart';
import 'package:medichat/Profile/Profile.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

class GlobalNavBar extends StatefulWidget {
  final int initialIndex;  // Add a field to accept the initial tab index

  GlobalNavBar({this.initialIndex = 0});  // Constructor to pass the initial index

  @override
  State<GlobalNavBar> createState() => _GlobalNavBarState();
}

class _GlobalNavBarState extends State<GlobalNavBar> {
  int selectedIndex = 0;

  final List<Widget> _pages = [
    DiaryScreen(),
    ChatScreen(),
    MoreScreen(),
    ProfileScreen()
  ];

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;  // Set the initial tab index from the widget constructor
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[selectedIndex],
      bottomNavigationBar: GNav(
        backgroundColor: Color.fromARGB(255, 133, 169, 143),
        color: Colors.white,
        activeColor: Colors.white,
        tabBackgroundColor: Color.fromARGB(255, 90, 108, 87),
        gap: 8,
        padding: EdgeInsets.all(15),
        iconSize: 30,
        selectedIndex: selectedIndex,  // Pass the selectedIndex to the GNav widget
        onTabChange: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        tabs: [
          GButton(
            icon: Icons.home,
            text: 'Home',
            textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          GButton(
            icon: Icons.chat,
            text: 'Chat',
            textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          GButton(
            icon: Icons.more_horiz_rounded,
            text: 'More',
            textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          GButton(
            icon: Icons.account_circle,
            text: 'Profile',
            textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
