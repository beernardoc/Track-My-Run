import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/model/UnitProvider.dart';

class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 20.0),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text('Unit of Measurement', style: TextStyle(fontSize: 18)),
                ToggleButtons(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Kilometers'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('Miles'),
                    ),
                  ],
                  onPressed: (int index) {
                    if (index == 0) {
                      Provider.of<UnitProvider>(context, listen: false).setUnit('km');
                    } else {
                      Provider.of<UnitProvider>(context, listen: false).setUnit('miles');
                    }
                  },
                  isSelected: [
                    Provider.of<UnitProvider>(context).unit == 'km',
                    Provider.of<UnitProvider>(context).unit == 'miles',
                  ],
                ),
              ],
            ),
          ),
          Divider(),
          // Outras configurações aqui...
        ],
      ),
    );
  }
}
