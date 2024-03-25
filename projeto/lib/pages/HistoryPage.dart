import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:projeto/model/DatabaseHelper.dart';
import 'package:projeto/model/RouteEntity.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<RouteEntity> _routes = [];
  
  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  Future<void> _loadRoutes() async {
    List<RouteEntity> routes = await DatabaseHelper.instance.getAllRoutes();
    setState(() {
      _routes = routes;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildRoutesList(),
    );
  }

  Widget _buildRoutesList() {
  if (_routes.isEmpty) {
    return const Center(child: Text('You have no routes yet!'));
  } else {
    return ListView.builder(
      itemCount: _routes.length,
      itemBuilder: (context, index) {
        final route = _routes.reversed.toList()[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ExpansionTile(
              title: Text('${route.title}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PopupMenuButton<String>(
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'other_option',
                        child: ListTile(
                          leading: Icon(Icons.more_horiz),
                          title: Text('...'),
                        ),
                      ),
                      const PopupMenuItem<String>(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete, color: Colors.red),
                          title: Text('Delete'),
                        ),
                      ),
                    ],
                    onSelected: (String value) async {
                      if (value == 'delete') {
                        _showDeleteDialog(route);
                      } else if (value == 'other_option') {
                        // ...
                      }
                    },
                  ),
                  Icon(Icons.expand_more), // Ícone de seta de expansão
                ],
              ),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    FutureBuilder<String>(
                      future: getAddress(route.startLatitude, route.startLongitude),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Carregando endereço...');
                        } else if (snapshot.hasError) {
                          return Text('Erro ao obter endereço: ${snapshot.error}');
                        } else {
                          return Text('Start: ${snapshot.data}');
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder<String>(
                      future: getAddress(route.endLatitude, route.endLongitude),
                      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Text('Carregando endereço...');
                        } else if (snapshot.hasError) {
                          return Text('Erro ao obter endereço: ${snapshot.error}');
                        } else {
                          return Text('End: ${snapshot.data}');
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text('Distance: ${route.distance.toStringAsFixed(2)} km'),
                    const SizedBox(height: 10),
                    _buildRouteMap(route.pathfinal),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

  Widget _buildRouteMap(String path) {
    List<dynamic> coordinatesList = jsonDecode(path);
    List<LatLng> points = [];
    for (var pair in coordinatesList) {
      points.add(LatLng(pair[0], pair[1]));
    }
    return SizedBox(
      height: 200,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: points.isNotEmpty ? points.first : LatLng(0, 0),
          zoom: 15,
        ),
        markers: _buildMarkers(points),
        polylines: _buildPolylines(points),
      ),
    );
  }

  Set<Marker> _buildMarkers(List<LatLng> points) {
    Set<Marker> markers = {};
    if (points.isNotEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('startPoint'),
          position: points.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('endPoint'),
          position: points.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }
    return markers;
  }

  Set<Polyline> _buildPolylines(List<LatLng> points) {
    Set<Polyline> polylines = {};
    if (points.isNotEmpty) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: points,
        ),
      );
    }
    return polylines;
  }

  Future<void> _showDeleteDialog(RouteEntity route) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Route?'),
          content: const Text('Are you sure you want to delete this route?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await DatabaseHelper.instance.deleteRoute(route.id);
                _loadRoutes();
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),

            ),
          ],
        );
      },
    );
  }


  Future<String> getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks[0];
    return "${place.street}, ${place.locality}, ${place.country}";
  }
}
