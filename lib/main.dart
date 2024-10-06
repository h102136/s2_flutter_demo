import 'package:flutter/material.dart';
import 'package:s2_flutter_demo/latlng.dart';
import 'package:s2_flutter_demo/key.dart';
import 'package:s2_flutter_demo/id.dart';
import 'package:s2_flutter_demo/stepping.dart';

void main() {
  runApp(const S2GeometryDemo());
}

/// Main app
class S2GeometryDemo extends StatelessWidget {
  const S2GeometryDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'S2Geometry Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const S2HomePage(),
    );
  }
}

/// Home page
class S2HomePage extends StatefulWidget {
  const S2HomePage({super.key});

  @override
  _S2HomePageState createState() => _S2HomePageState();
}

class _S2HomePageState extends State<S2HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const S2ConverterLatlngScreen(), // First feature page
    const S2ConverterKeyScreen(),    // Second feature page
    const S2ConverterIdScreen(),     // Third feature page
    const S2ConverterStepScreen(),   // Fourth feature page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('S2Geometry Converter'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/back.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        // use IndexedStack to keep the state of each page
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),

      /// Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Lat/Lng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_play_list),
            label: 'Key',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_video),
            label: 'S2CellID',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.featured_play_list_outlined),
            label: 'Stepping',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

