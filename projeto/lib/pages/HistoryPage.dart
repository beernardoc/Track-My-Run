import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'package:projeto/model/DatabaseHelper.dart';
import 'package:projeto/model/RouteEntity.dart';
import 'package:projeto/model/UnitProvider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

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
    final unitProvider = Provider.of<UnitProvider>(context);
    return Scaffold(
      
      body: _buildRoutesList(unitProvider),
    );
  }

  Widget _buildRoutesList(UnitProvider unitProvider) {
    final unit = unitProvider.unit;
    if (_routes.isEmpty) {
      return const Center(
        child: Text(
          'You have no routes yet!',
          style: TextStyle(fontSize: 18),
        ),
      );
    } else {
      return ListView.builder(
        itemCount: _routes.length,
        itemBuilder: (context, index) {
          final route = _routes.reversed.toList()[index];
          double distance = route.distance;
          if (unit == 'miles') {
            distance *= 0.621371;
          }
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ExpansionTile(
                title: Text(
                  '${route.title}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                trailing: _buildPopupMenuButton(route),
                children: [
                  _buildRouteInfo(route, distance, unit),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildPopupMenuButton(RouteEntity route) {

      void showImageDialog(String imagePath) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.contain,
              ),
            ),
          );
        },
      );
    }


    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
            }
          },
        ),
        if (route.imagePath != null && route.imagePath!.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.image),
            onPressed: () {
              showImageDialog(route.imagePath!);
            },
          ),
          const Icon(Icons.expand_more), 
      ],
    );

  
  
  }

  Widget _buildRouteInfo(RouteEntity route, double distance, String unit) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 12),
      Text(
        'Distance: ${distance.toStringAsFixed(2)} $unit',
        style: const TextStyle(fontSize: 16),
      ),
      const SizedBox(height: 12),
      route.duration! < 60
          ? Text(
              'Duration: ${route.imagePath} seconds',
              style: const TextStyle(fontSize: 16),
            )
          : Text(
              'Duration: ${route.duration! ~/ 60} minutes',
              style: const TextStyle(fontSize: 16),
            ),
      const SizedBox(height: 12),
      _buildAddressInfo(route.startLatitude, route.startLongitude, 'Start'),
      const SizedBox(height: 12),
      _buildAddressInfo(route.endLatitude, route.endLongitude, 'End'),
      const SizedBox(height: 12),
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _buildRouteMap(route.pathfinal),
        ),
      ),
      
    ],
  );
}


  Widget _buildAddressInfo(double latitude, double longitude, String label) {
    return FutureBuilder<String>(
      future: getAddress(latitude, longitude),
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading address...');
        } else if (snapshot.hasError) {
          return Text(
            'Error getting address: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        } else {
          return Text(
            '$label: ${snapshot.data}',
            style: const TextStyle(fontSize: 16),
          );
        }
      },
    );
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
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
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
