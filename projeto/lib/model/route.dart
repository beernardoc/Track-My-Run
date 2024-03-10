import 'package:latlong2/latlong.dart';

class route{
  int? id;
  String? title;
  LatLng start;
  LatLng? end;


  route({this.id, this.title, required this.start, this.end});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'start': start.toString(),
      'end': end.toString(),
    };
  }

  @override
  String toString() {
    return 'Route{id: $id, title: $title, start: $start, end: $end}';
  }
}