import 'package:flutter/material.dart';
import 'package:projeto/misc/tile_providers.dart';
import 'package:location/location.dart';
import 'package:projeto/model/route.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late GoogleMapController mapController;
  
  LocationData? _currentLocation;
  Location _location = Location();
  

  final LatLng _center = const LatLng(45.521563, -122.677433);
  Set<Marker> _markers = {}; // Define um Set para armazenar os marcadores

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
            markers: _markers, // Use o Set de marcadores aqui
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
                          // Atualiza o Set de marcadores com o novo marcador
                          setState(() {
                            _markers.add(
                              Marker(
                                markerId: MarkerId('currentLocation'),
                                position: LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
                                icon: BitmapDescriptor.defaultMarker,
                              ),
                            );
                          });
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
       mapController.animateCamera(
         CameraUpdate.newCameraPosition(
           CameraPosition(
             target: LatLng(latitude, longitude),
             zoom: 15,
           ),
         ),
       );
     }
   } catch (e) {
     print('Error getting location: $e');
   }
 }
}