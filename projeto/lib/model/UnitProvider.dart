import 'package:flutter/material.dart';

class UnitProvider extends ChangeNotifier {
  String _unit = 'km'; // Unidade padrão

  String get unit => _unit;

  void setUnit(String newUnit) {
    _unit = newUnit;
    notifyListeners(); // Notifique os ouvintes sobre a alteração na unidade
  }
}
