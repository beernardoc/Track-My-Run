import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:projeto/misc/tile_providers.dart';
import 'package:location/location.dart';
import 'package:projeto/model/route.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  int _counter = 0;
  final mapController = MapController();
  LocationData? _currentLocation;
  Location _location = Location();

  
  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
  

  

  @override
  Widget build(BuildContext context) {



    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: const MapOptions(
              initialCenter: LatLng(40.631113, -8.656152),
              initialZoom: 5,
              
            ),
            children: [
              openStreetMapTileLayer,
              MarkerLayer(markers: 
              _currentLocation != null ? [ // if _currentLocation is not null, show the marker
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                  child: const Icon(
                    Icons.location_on,
                    size: 50,
                    color: Colors.green,
                  ),
                ),
              ] : []               
              )
            ],
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      _getCurrentLocation().then((_) {
                        if (_currentLocation != null) {
                           route newRoute = route(start: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));
                          

                        }
                      });
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text('start tracking', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


Future<void> _getCurrentLocation() async {
  try {
    final LocationData locationData = await _location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });

    if (_currentLocation != null) {
      final double latitude = _currentLocation!.latitude!;
      final double longitude = _currentLocation!.longitude!;
      mapController.move(LatLng(latitude, longitude), 15.0);
    }
  } catch (e) {
    print('Error getting location: $e');
  }
}
}
