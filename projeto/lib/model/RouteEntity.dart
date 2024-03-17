
class RouteEntity{
  int? id;
  String? title;
  double startLatitude;
  double startLongitude;
  double? endLatitude;
  double? endLongitude;
  String? pathfinal;

  RouteEntity({
    this.id,
    this.title,
    required this.startLatitude,
    required this.startLongitude,
    this.endLatitude,
    this.endLongitude,
    this.pathfinal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
      'pathfinal': pathfinal,
    };
  }

  @override
  String toString() {
    return 'Route{id: $id, title: $title, startLatitude: $startLatitude, startLongitude: $startLongitude, endLatitude: $endLatitude, endLongitude: $endLongitude}';
  }
}