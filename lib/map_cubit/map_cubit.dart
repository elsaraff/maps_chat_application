import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/map_cubit/map_states.dart';
import 'package:flutter_maps/models/place_model.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/shared/location_helper.dart';
import 'package:flutter_maps/shared/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

class MapCubit extends Cubit<MapStates> {
  MapCubit() : super(MapInitial());

  static MapCubit get(context) => BlocProvider.of(context);

  Position? position;

  Future<void> getMyCurrentLocation() async {
    position = await LocationHelper.getCurrentLocation().whenComplete(() {
      emit(GetMyCurrentLocationSuccess());
    }).catchError((error) {
      emit(GetMyCurrentLocationError(error));
    });
  }

  final Completer<GoogleMapController> mapController = Completer();

  Future<void> goToMyCurrentLocation() async {
    final GoogleMapController controller = await mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(position!.latitude, position!.longitude),
      bearing: 0.0,
      tilt: 0.0,
      zoom: 17,
    )))
        .then((value) {
      emit(GoToMyCurrentLocationSuccess());
    }).catchError((error) {
      emit(GoToMyCurrentLocationError(error.toString()));
    });
  }

  /*___________________________________________*/

  Dio dioPlaces = Dio(BaseOptions(receiveDataWhenStatusError: true));

  List<PlaceModel> placesList = [];

  Future<void> getPlacesSuggestions(String query, String sessionToken) async {
    await dioPlaces.get(placesUrl, queryParameters: {
      'input': query,
      'sessiontoken': sessionToken,
      'key': googleMapsApiKey,
      'types': ['establishment', 'geocode', 'address'],
      'components': 'country:eg',
    }).then((value) {
      dynamic response = [];
      placesList = [];

      for (var e in value.data['predictions']) {
        response.add(PlaceModel.fromJson(e));
        placesList = [];

        for (var e in response) {
          placesList.add(e);
        }
      }
      emit(GetPlacesSuccess(placesList));
    }).catchError((error) {
      emit(GetPlacesError(error.toString()));
    });
  }
  /*___________________________________________*/

  void getPlaceDetails(String placeId) async {
    var sessionToken = const Uuid().v4();

    await dioPlaces.get(placeDetailsUrl, queryParameters: {
      'place_id': placeId,
      'sessiontoken': sessionToken,
      'key': googleMapsApiKey,
      'fields': 'geometry',
    }).then((value) {
      selectedPlace = Place.fromJson(value.data);
      emit(GetPlacesDetailsSuccess());
    }).catchError((error) {
      emit(GetPlacesDetailsError(error.toString()));
    });
  }

  /*___________________________________________*/
  PlaceDirections? placeDirections;

  //origin = current
  void getPlaceDirection(LatLng origin, LatLng destination) async {
    await dioPlaces.get(placeDirectionUrl, queryParameters: {
      'origin': '${origin.latitude} , ${origin.longitude}',
      'destination': '${destination.latitude} , ${destination.longitude}',
      'key': googleMapsApiKey,
    }).then((value) {
      placeDirections = PlaceDirections.fromJson(value.data);

      emit(GetPlaceDirectionSuccess());
    }).catchError((error) {
      emit(GetPlaceDirectionError(error.toString()));
    });
  }

  /*___________________________________________*/

  late CameraPosition gotoSearchedForPlace;
  late Place selectedPlace;

  Future<void> goToMySearchedForLocation() async {
    gotoSearchedForPlace = CameraPosition(
      target: LatLng(
        selectedPlace.result.geometry.location.lat,
        selectedPlace.result.geometry.location.lng,
      ),
      bearing: 0.0,
      tilt: 0.0,
      zoom: 15,
    );

    final GoogleMapController controller = await mapController.future;
    controller
        .animateCamera(CameraUpdate.newCameraPosition(gotoSearchedForPlace));
    buildSearchedPlaceMarker();
  }

  void getPlaceDirectionNow() {
    getPlaceDirection(
      LatLng(position!.latitude, position!.longitude),
      LatLng(selectedPlace.result.geometry.location.lat,
          selectedPlace.result.geometry.location.lng),
    );
  }

  late Marker searchedPlaceMarker;

  void buildSearchedPlaceMarker() {
    searchedPlaceMarker = Marker(
      markerId: const MarkerId('searchedPlaceMarker'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      position: gotoSearchedForPlace.target,
      infoWindow: InfoWindow(
        title: placeSuggestion.description,
      ),
      onTap: () {
        getPlaceDirectionNow();
        buildCurrentLocationMarker();
      },
    );
    addMarkerAndUpdate(searchedPlaceMarker);
  }

  var isSearchPlaceMarkerClicked = false;
  var isDistanceAndTimeVisible = false;

  void markerClicked() {
    isSearchPlaceMarkerClicked = true;
    isDistanceAndTimeVisible = true;
    emit(MarkerClicked());
  }

  void distanceAndTimeVisibleUpdate() {
    debugPrint(
        'distanceAndTimeVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleVisibleUpdate');
    isDistanceAndTimeVisible = false;
    emit(DistanceAndTimeVisibleUpdate());
  }

  late Marker currentPlaceMarker;

  void buildCurrentLocationMarker() {
    currentPlaceMarker = Marker(
      markerId: const MarkerId('currentPlaceMarker'),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      position: LatLng(position!.latitude, position!.longitude),
      infoWindow: const InfoWindow(
        title: 'Your current location',
      ),
      onTap: () {},
    );
    addMarkerAndUpdate(currentPlaceMarker);
  }

  Set<Marker> markers = {};

  void addMarkerAndUpdate(Marker marker) {
    markers.add(marker);
    emit(AddMarkerAndUpdate());
  }

  void clearMarkerAndUpdate() {
    debugPrint(
        'clearMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerMarkerAndUpdate');

    markers.clear();
    emit(ClearMarkerAndUpdate());
  }

  List<LatLng>? polylinePoints;

  void getPolylinePoints() {
    polylinePoints = placeDirections!.polylinePoints
        .map((e) => LatLng(e.latitude, e.longitude))
        .toList();
  }
}
