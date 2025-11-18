import 'package:flutter/material.dart';
import 'package:maps_app/pages/home_page.dart';
import 'package:maps_app/pages/map_page.dart';
import 'package:maps_app/pages/profile_page.dart';

class NavPage extends StatefulWidget {
  const NavPage({super.key});

  @override
  State<NavPage> createState() => _NavPageState();
}

class _NavPageState extends State<NavPage> {
  int _selectedIndex = 0;
  final pages = [
    HomePage(),
    MapPage(),
    ProfilePage(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        toolbarHeight: 80,
        title: Text('Maps.J',
        style: TextStyle(
          fontWeight: FontWeight.bold
        ),),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
    body: pages[_selectedIndex],
    bottomNavigationBar: NavigationBar(
      destinations: [
      NavigationDestination(
        icon: Icon(Icons.home),
        label: 'Home',
        selectedIcon: Icon(Icons.home),
      ),
      NavigationDestination(
        icon: Icon(Icons.map),
        label: 'Maps',
        selectedIcon: Icon(Icons.map),
      ),
      NavigationDestination(
        icon: Icon(Icons.person),
        label: 'Profile',
        selectedIcon: Icon(Icons.person),
      ),
      
    ],
    selectedIndex: _selectedIndex,
    onDestinationSelected: (index) {
      setState(() {
        _selectedIndex = index;
      });
    },
    ),
    
    );
    
  }

}
