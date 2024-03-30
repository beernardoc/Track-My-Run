import 'package:flutter/material.dart';
import 'package:projeto/pages/HistoryPage.dart';
import 'package:projeto/pages/WeatherPage.dart';
import 'package:projeto/pages/mapPage.dart';
import 'package:projeto/pages/SettingsPage.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: const Color(0xFF13C731), // Cor primária (verde)
        hintColor: const Color(0xFF27AE60), // Cor de destaque (verde mais escura)
        scaffoldBackgroundColor: const Color(0xFFF9F9F9), // Cor de fundo do Scaffold
      ),
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              "TrackMyRun",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          bottomNavigationBar: menu(),
          body: const TabBarView(
            children: [
              MapPage(),
              HistoryPage(),
              WeatherPage(),
              SettingsPage(),
            ],
          ),
        ),
      ),
    );
  }

  Widget menu() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Material(
        color: Theme.of(context).primaryColor, // Usando a cor primária como cor de fundo
        child: TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorSize: TabBarIndicatorSize.tab,
          indicatorPadding: const EdgeInsets.all(5.0),
          indicatorColor: Colors.white,
          tabs: [
            Tab(
              icon: Icon(
                Icons.home,
                size: 28,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.assignment,
                size: 28,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.cloud,
                size: 28,
              ),
            ),
            Tab(
              icon: Icon(
                Icons.settings,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
