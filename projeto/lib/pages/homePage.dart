import 'package:flutter/material.dart';
import 'package:projeto/pages/mapPage.dart';


class HomePage extends StatefulWidget {
  
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
    Widget build(BuildContext context) {
      return MaterialApp(
        home: DefaultTabController(
          length: 4,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFF3F5AA6),
              title: Text("Title text"),
            ),
            bottomNavigationBar: menu(),
            body: TabBarView(
              children: [
                const MapPage(),
                Container(child: const Text("Transactions")),
                Container(child: const Text("Transactions")),
                Container(child: const Text("teste")),
              ],
            ),
          ),
        ),
      );
    }

     Widget menu() {
      return Container(
        color: const Color(0xFF3F5AA6),
        child: const TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: EdgeInsets.all(5.0),
          indicatorColor: Colors.blue,
          tabs: [
            Tab(
              text: "Home",
              icon: Icon(Icons.home),
            ),
            Tab(
              text: "History",
              icon: Icon(Icons.assignment),
            ),  
            Tab(
              text: "Weather",
              icon: Icon(Icons.cloud),
            ),
            Tab(
              text: "Settings",
              icon: Icon(Icons.settings),
            ),
          ],
        ),
      );
      }
}
