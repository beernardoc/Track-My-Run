import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projeto/model/UnitProvider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'Unit of Measurement',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<UnitProvider>(context, listen: false).setUnit('km');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Provider.of<UnitProvider>(context).unit == 'km'
                          ? Colors.grey  
                          : Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Kilometers',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Provider.of<UnitProvider>(context, listen: false).setUnit('miles');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Provider.of<UnitProvider>(context).unit == 'miles'
                          ? Colors.grey 
                          : Colors.white, 
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    child: const Text(
                      'Miles',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
          ],
        ),
      ),
    );
  }
}
