import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:projeto/model/DatabaseHelper.dart';
import 'package:projeto/model/RouteEntity.dart';


class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  
  LocationData? _currentLocation;
  Location _location = Location();
  List<LatLng> _routeCoordinates = [];
  bool _isRunning = false;
  late StreamSubscription<LocationData> _locationSubscription;

  int activeRouteID = 0;
  double activeRouteStartLatitude = 0;
  double activeRouteStartLongitude = 0;
  double activeRouteEndLatitude = 0;
  double activeRouteEndLongitude = 0;
  String activeRouteTitle = '';
  

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(_currentLocation?.latitude ?? 0, _currentLocation?.longitude ?? 0),
              zoom: 11.0,
            ),
            markers: _buildMarkers(),
            polylines: _buildPolylines(),
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
                      setState(() {
                        _isRunning = !_isRunning;
                        if (_isRunning) {
                          _startRun();
                        } else {
                          _pauseRun();
                        }
                      });
                    },
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow, color: Colors.white),
                    label: Text(_isRunning ? 'Finish run' : 'Start run', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 19, 199, 49),
                    ),
                  ),
                  SizedBox(width: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('currentLocation'),
          position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines() {
    Set<Polyline> polylines = {};
    if (_routeCoordinates.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: _routeCoordinates,
        ),
      );
    }
    return polylines;
  }

  Future<void> _startRun() async {

    activeRouteStartLatitude = _currentLocation!.latitude!;
    activeRouteStartLongitude = _currentLocation!.longitude!;
    
    _locationSubscription = _location.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation = locationData;
        _routeCoordinates.add(LatLng(locationData.latitude!, locationData.longitude!));
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(locationData.latitude!, locationData.longitude!),
              zoom: 18,
            ),
          ),
        );
      });
    });
  }

 Future<void> _pauseRun() async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      String title = '';
      bool isButtonEnabled = false;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Would you like to save this run?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      title = value;
                      isButtonEnabled = title.isNotEmpty;
                    });
                  },
                  decoration: const InputDecoration( hintText: 'Enter a title for this run'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _clearLines();
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: isButtonEnabled 
                    ? () async {
                        activeRouteEndLatitude = _currentLocation!.latitude!;
                        activeRouteEndLongitude = _currentLocation!.longitude!;
                        activeRouteTitle = title;
                        RouteEntity route = RouteEntity(
                          title: activeRouteTitle,
                          startLatitude: activeRouteStartLatitude,
                          startLongitude: activeRouteStartLongitude,
                          endLatitude: activeRouteEndLatitude,
                          endLongitude: activeRouteEndLongitude,
                        );
                        await DatabaseHelper.instance.insertRoute(route);
                        _clearLines();
                        Navigator.of(context).pop();
                      }
                    : null, 
                child: const Text('Save'),
              ),
            ],
          );
        },
      );
    },
  );
  _locationSubscription.cancel();
}

  void _clearLines() {
    setState(() {
      _routeCoordinates.clear();
    });
  }

  Future<void> _getCurrentLocation() async {
  try {
    final LocationData locationData = await _location.getLocation();
    setState(() {
      _currentLocation = locationData;
    });

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(locationData.latitude!, locationData.longitude!),
          zoom: 18,
        ),
      ),
    );

  } catch (e) {
    print('Error getting location: $e');
  }
}
}
