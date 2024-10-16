import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'family_screen.dart';
import 'tasks_screen.dart';
import 'overview_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    FamilyScreen(),
    TasksScreen(),
    // OverviewScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'Familie',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Aufgaben',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Übersicht',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue, // Passe die Farbe nach Bedarf an
        onTap: _onItemTapped,
      ),
    );
  }
}
