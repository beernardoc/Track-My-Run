import 'package:flutter/material.dart';
import 'package:projeto/pages/homePage.dart';
import 'package:provider/provider.dart';
import 'package:projeto/model/UnitProvider.dart';


Future<void> main() async {
  
  runApp(ChangeNotifierProvider(
      create: (context) => UnitProvider(), 
      child: const MyApp(),
    ),);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }


  
}

