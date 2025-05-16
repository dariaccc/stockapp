import 'package:flutter/material.dart';
import 'main.dart';
import 'radar.dart';
import 'home.dart';

class Navigation extends StatefulWidget {
  //const Navigation({Key? key}) : super(key: key);

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int screen_index = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: screen_index,
          children: [
            Home(),
            Radar(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index) {
            setState(() {
              screen_index = index;
            });
          },
          currentIndex: screen_index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.indigo,
          fixedColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Radar'),
            BottomNavigationBarItem(icon: Icon(Icons.upgrade), label: 'Pro'),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_circle),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
          ],
        ),
      ),
    );
  }
}
