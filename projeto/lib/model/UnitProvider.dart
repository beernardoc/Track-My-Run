import 'package:flutter/material.dart';

class UnitProvider extends ChangeNotifier {
  String _unit = 'km'; 

  String get unit => _unit;

  void setUnit(String newUnit) {
    _unit = newUnit;
    notifyListeners(); 
  }
}
