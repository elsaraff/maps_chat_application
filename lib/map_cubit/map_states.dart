import 'package:flutter_maps/models/place_model.dart';

abstract class MapStates {}

class MapInitial extends MapStates {}

class GetMyCurrentLocationSuccess extends MapStates {}

class GetMyCurrentLocationError extends MapStates {
  final String error;

  GetMyCurrentLocationError(this.error);
}

class GoToMyCurrentLocationSuccess extends MapStates {}

class GoToMyCurrentLocationError extends MapStates {
  final String error;

  GoToMyCurrentLocationError(this.error);
}

class GetPlacesSuccess extends MapStates {
  final List<PlaceModel> placesList;

  GetPlacesSuccess(this.placesList);
}

class GetPlacesError extends MapStates {
  final String error;

  GetPlacesError(this.error);
}

class GetPlacesDetailsSuccess extends MapStates {}

class GetPlacesDetailsError extends MapStates {
  final String error;

  GetPlacesDetailsError(this.error);
}

class GetPlaceDirectionSuccess extends MapStates {}

class GetPlaceDirectionError extends MapStates {
  final String error;

  GetPlaceDirectionError(this.error);
}

class MarkerClicked extends MapStates {}

class AddMarkerAndUpdate extends MapStates {}

class ClearMarkerAndUpdate extends MapStates {}

class DistanceAndTimeVisibleUpdate extends MapStates {}
