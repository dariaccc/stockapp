import 'package:flutter/material.dart';
import '/radar.dart';

void main() {
  runApp(Home());
}

class Home extends StatefulWidget {
  @override
  State<Home> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<Home> {
  int screen_index = 0;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Home screen"), centerTitle: true),
        bottomNavigationBar: BottomNavigationBar(
          onTap: (index){
            setState(() {
              screen_index = index;
              /**Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => Screen1()),
              );**/
            });
          },
          currentIndex: screen_index,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.indigo,
          fixedColor: Colors.white,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home', ),
            BottomNavigationBarItem(icon: Icon(Icons.radar), label: 'Radar'),
            BottomNavigationBarItem(icon: Icon(Icons.upgrade), label: 'Pro'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu')
          ],
        ),
      ),
    );
  }
}
