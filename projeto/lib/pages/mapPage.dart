import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:projeto/model/DatabaseHelper.dart';
import 'package:projeto/model/RouteEntity.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';


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

  late Timer _stopDetectionTimer;
  bool _isStopped = false;
  LocationData? _previousLocation;
  

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

    _previousLocation = await _location.getLocation();

    _stopDetectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
    if (!_isStopped) {
        _checkMovement();
      }
    });
    
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
    _stopDetectionTimer.cancel();

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
                    decoration: const InputDecoration(hintText: 'Enter a title for this run'),
                  ),
                  ElevatedButton(
                    onPressed: _takePhotoAndAssociateWithRoute,
                    child: Text('Take Photo', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    DatabaseHelper.instance.deleteDatabaseFile();
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
                          var pathfinal = convertToString(_routeCoordinates);
                          var distance = await calculateDistance(_routeCoordinates);
                          RouteEntity route = RouteEntity(
                            title: activeRouteTitle,
                            startLatitude: activeRouteStartLatitude,
                            startLongitude: activeRouteStartLongitude,
                            endLatitude: activeRouteEndLatitude,
                            endLongitude: activeRouteEndLongitude,
                            pathfinal: pathfinal,
                            distance: distance,
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
 String convertToString(List<LatLng> routeCoordinates) {
  List<List<double>> coordinatesList = [];
  
  for (LatLng latLng in routeCoordinates) {
    List<double> coordinatePair = [latLng.latitude, latLng.longitude];
    coordinatesList.add(coordinatePair);
  }

  
  return jsonEncode(coordinatesList);
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
void _showStopConfirmationDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Want a pause ?'),
        content: const Text('Want to make a pause ? Dont forget to drink some water and rest a little bit!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Lidar com o caso em que o usuário confirmou que parou
            },
            child: const Text('Sim'),
          ),
        ],
      );
    },
  );
}

  void _checkMovement() async {
    // Obter a nova localização
    LocationData currentLocation = await _location.getLocation();

    // Calcular a distância entre a localização anterior e a nova localização
    double distanceInMeters = await Geolocator.distanceBetween(
      _previousLocation!.latitude!,
      _previousLocation!.longitude!,
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

      if (distanceInMeters < 5) {
      _isStopped = true;
      _showStopConfirmationDialog();
    } else {
      // Se houve movimento, atualize a localização anterior e reinicie o temporizador
      _previousLocation = currentLocation;
      _stopDetectionTimer.cancel();
      _stopDetectionTimer = Timer.periodic(const Duration(seconds: 15), (timer) {
        if (!_isStopped) {
          _checkMovement();
        }
      });
    }
  }

  Future<double> calculateDistance(List<LatLng> routeCoordinates) async {
    double distance = 0;
    for (int i = 0; i < routeCoordinates.length - 1; i++) {
      LatLng start = routeCoordinates[i];
      LatLng end = routeCoordinates[i + 1];
      distance += Geolocator.distanceBetween(start.latitude, start.longitude, end.latitude, end.longitude);
    }
    var distanceKm = distance / 1000;
    return distanceKm;
  }

}

Future<void> _takePhotoAndAssociateWithRoute() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  if (pickedFile != null) {
    // Salvar a imagem no banco de dados
    // Associar a imagem com a rota ativa
  }
}
