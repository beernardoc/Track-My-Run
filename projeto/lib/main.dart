import 'package:flutter/material.dart';
import 'package:projeto/pages/homePage.dart';
import 'package:provider/provider.dart';
import 'package:projeto/model/UnitProvider.dart';


Future<void> main() async {
  //await initDatabase();
  runApp(ChangeNotifierProvider(
      create: (context) => UnitProvider(), // Inicia o Provider
      child: const MyApp(),
    ),);

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }


  
}

