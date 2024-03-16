import 'package:flutter/material.dart';
import 'package:projeto/model/DatabaseHelper.dart';
import 'package:projeto/model/RouteEntity.dart';

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
        final route = _routes[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                'Title: ${route.title}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text('Start: ${route.startLatitude}, ${route.startLongitude}'),
                  const SizedBox(height: 4),
                  Text('End: ${route.endLatitude ?? ''}, ${route.endLongitude ?? ''}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text('Delete'),
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'other_option',
                    child: ListTile(
                      leading: Icon(Icons.more_horiz),
                      title: Text('...'),
                    ),
                  ),
                ],
                onSelected: (String value) async {
                  if (value == 'delete') {
                    await DatabaseHelper.instance.deleteRoute(route.id);
                    _loadRoutes();
                  } else if (value == 'other_option') {
                  }
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

}
