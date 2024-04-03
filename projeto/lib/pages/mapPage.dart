import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:projeto/model/DatabaseHelper.dart';
import 'package:projeto/model/RouteEntity.dart';
import 'dart:convert';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';





class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  
  LocationData? _currentLocation;
  final Location _location = Location();
  final List<LatLng> _routeCoordinates = [];
  bool _isRunning = false;
  late StreamSubscription<LocationData> _locationSubscription;

  int activeRouteID = 0;
  double activeRouteStartLatitude = 0;
  double activeRouteStartLongitude = 0;
  double activeRouteEndLatitude = 0;
  double activeRouteEndLongitude = 0;
  String activeRouteTitle = '';
  String? imagePath = '';

  late Timer _stopDetectionTimer;
  late Timer timer;
  bool _isStopped = false;
  LocationData? _previousLocation;
  double distanceCovered = 0.0;
  int lastKm = 0;
  int _elapsedTimeSeconds = 0;
  
  
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
                    label: Text(_isRunning ? 'Finish run' : 'Start run', style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRunning ? Colors.red : Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
         _isRunning
    ? SizedBox(
        height: 130, 
        child: Container(
          margin: const EdgeInsets.all(16.0),
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3), 
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Distance',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${distanceCovered.toStringAsFixed(2)} km',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Time',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    _formatElapsedTime(_elapsedTimeSeconds),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Pace',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    '${_calculatePace(distanceCovered, _elapsedTimeSeconds)} min/km',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16.0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      )
    : Container(),


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
    distanceCovered = 0.0;
    _elapsedTimeSeconds = 0;

    _previousLocation = await _location.getLocation();

    _stopDetectionTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
    if (!_isStopped) {
        _checkMovement();
      }
    });

    timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
    setState(() {
      _elapsedTimeSeconds++;
    });
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

        if (_routeCoordinates.length > 1) {
          double distanceInMeters = Geolocator.distanceBetween(
            _routeCoordinates[_routeCoordinates.length - 2].latitude,
            _routeCoordinates[_routeCoordinates.length - 2].longitude,
            _routeCoordinates.last.latitude,
            _routeCoordinates.last.longitude,
          );

          double distanceInKm = (distanceInMeters / 1000);
          distanceCovered += double.parse(distanceInKm.toStringAsFixed(2));
        }

        


      });
    });
  }

  

  Future<void> _pauseRun() async {
    _stopDetectionTimer.cancel();
    timer.cancel();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String title = '';
        bool isButtonEnabled = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Would you like to save this run?'),
              content: SingleChildScrollView(
                child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          title = value;
                          isButtonEnabled = title.isNotEmpty;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter a title for this run',
                        hintStyle: const TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  imagePath == null || imagePath!.isEmpty ?
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        imagePath = await _takePhotoAndAssociateWithRoute();
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.all(12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      icon: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      ),
                      label: const Text(
                        'Add Photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ) : Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: Stack(
                          children: [
                            Image.file(File(imagePath!)),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    imagePath = null; 
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                ],
              )
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
                            duration: _elapsedTimeSeconds,
                            imagePath: imagePath,
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
    setState(() {
      imagePath = '';
    });
  }


String _calculatePace(double distanceCovered, int elapsedTimeSeconds) {
  double elapsedTimeMinutes = elapsedTimeSeconds / 60;

  if (distanceCovered == 0) {
    return '0.00';
  }
  
  double pace = elapsedTimeMinutes / distanceCovered;
  String formattedPace = pace.toStringAsFixed(2); 

  return formattedPace;
}

String _formatElapsedTime(int elapsedTimeSeconds) {
  int hours = elapsedTimeSeconds ~/ 3600;
  int minutes = (elapsedTimeSeconds ~/ 60) % 60;
  int seconds = elapsedTimeSeconds % 60;

  String hoursStr = (hours < 10) ? '0$hours' : '$hours';
  String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
  String secondsStr = (seconds < 10) ? '0$seconds' : '$seconds';

  return '$hoursStr:$minutesStr:$secondsStr';
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
              _pauseRun();
            },
            child: const Text('Sim'),
          ),
        ],
      );
    },
  );
}

  void _checkMovement() async {
    
    LocationData currentLocation = await _location.getLocation();

    double distanceInMeters = Geolocator.distanceBetween(
      _previousLocation!.latitude!,
      _previousLocation!.longitude!,
      currentLocation.latitude!,
      currentLocation.longitude!,
    );

      if (distanceInMeters < 5) {
      _isStopped = true;
      _showStopConfirmationDialog();
    } else {
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

   

  Future<String> _takePhotoAndAssociateWithRoute() async {
  final picker = ImagePicker();
  final pickedFile = await picker.pickImage(source: ImageSource.camera);
  final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
  final String uniqueFileName = 'image_$timestamp.jpg';
  if (pickedFile != null) {
    final File imageFile = File(pickedFile.path);
    final Directory? appDirectory = await getExternalStorageDirectory();
    
    final String imagePath = '${appDirectory?.path}/$uniqueFileName';
    
    await imageFile.copy(imagePath);
    return imagePath;
    
  }
  return '';
}

    
}
