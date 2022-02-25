import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceModel {
  late String placeId;
  late String description;

  PlaceModel.fromJson(Map<String, dynamic> json) {
    placeId = json['place_id'];
    description = json['description'];
  }
}

/*_______________________________________________*/

class Place {
  late Result result;
  late String status;

  Place.fromJson(dynamic json) {
    result = Result.fromJson(json['result']);
    status = json['status'];
  }
}

class Result {
  late Geometry geometry;

  Result.fromJson(dynamic json) {
    geometry = Geometry.fromJson(json['geometry']);
  }
}

class Geometry {
  late Location location;

  Geometry.fromJson(dynamic json) {
    location = Location.fromJson(json['location']);
  }
}

class Location {
  late double lat;
  late double lng;

  Location.fromJson(dynamic json) {
    lat = json['lat'];
    lng = json['lng'];
  }
}

/*_______________________________________________*/

class PlaceDirections {
  late LatLngBounds bounds;
  late List<PointLatLng> polylinePoints;
  late String totalDistance;
  late String totalDuration;

  PlaceDirections({
    required this.bounds,
    required this.polylinePoints,
    required this.totalDistance,
    required this.totalDuration,
  });

  factory PlaceDirections.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['routes'][0]);
    final northeast = data['bounds']['northeast'];
    final southwest = data['bounds']['southwest'];
    final bounds = LatLngBounds(
      southwest: LatLng(southwest['lat'], southwest['lng']),
      northeast: LatLng(northeast['lat'], northeast['lng']),
    );
    late String distance;
    late String duration;
    if ((data['legs'] as List).isNotEmpty) {
      final leg = data['legs'][0];
      distance = leg['distance']['text'];
      duration = leg['duration']['text'];
    }
    return PlaceDirections(
      bounds: bounds,
      polylinePoints:
          PolylinePoints().decodePolyline(data['overview_polyline']['points']),
      totalDistance: distance,
      totalDuration: duration,
    );
  }
}
