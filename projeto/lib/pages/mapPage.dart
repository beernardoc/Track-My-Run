import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

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

  final LatLng _center = const LatLng(45.521563, -122.677433);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: _center,
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
                    label: Text(_isRunning ? 'Pause run' : 'Start run', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(width: 20), // Espaçamento entre botões
                  ElevatedButton.icon(
                    onPressed: _clearLines,
                    icon: Icon(Icons.cleaning_services, color: Colors.white),
                    label: Text('Clean lines', style: TextStyle(color: Colors.white)),
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

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
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
          polylineId: PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: _routeCoordinates,
        ),
      );
    }
    return polylines;
  }

  void _startRun() {
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

  void _pauseRun() {
    _locationSubscription.cancel();
  }

  void _clearLines() {
    setState(() {
      _routeCoordinates.clear();
    });
  }
}
