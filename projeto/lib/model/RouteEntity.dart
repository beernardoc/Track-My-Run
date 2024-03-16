
class RouteEntity{
  int? id;
  String? title;
  double startLatitude;
  double startLongitude;
  double? endLatitude;
  double? endLongitude;

  RouteEntity({
    this.id,
    this.title,
    required this.startLatitude,
    required this.startLongitude,
    this.endLatitude,
    this.endLongitude,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start_latitude': startLatitude,
      'start_longitude': startLongitude,
      'end_latitude': endLatitude,
      'end_longitude': endLongitude,
    };
  }

  @override
  String toString() {
    return 'Route{id: $id, title: $title, startLatitude: $startLatitude, startLongitude: $startLongitude, endLatitude: $endLatitude, endLongitude: $endLongitude}';
  }
}