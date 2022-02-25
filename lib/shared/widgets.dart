import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/map_cubit/map_cubit.dart';
import 'package:flutter_maps/map_cubit/map_states.dart';
import 'package:flutter_maps/models/place_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

Widget buildMap(mapCubit) {
  return GoogleMap(
    compassEnabled: true,
    liteModeEnabled: false,
    initialCameraPosition: CameraPosition(
      target: LatLng(mapCubit.position!.latitude, mapCubit.position!.longitude),
      bearing: 0.0,
      tilt: 0.0,
      zoom: 17,
    ),
    mapType: MapType.normal,
    myLocationEnabled: true,
    zoomControlsEnabled: false,
    myLocationButtonEnabled: false,
    onMapCreated: (GoogleMapController googleMapController) {
      mapCubit.mapController.complete(googleMapController);
    },
    markers: mapCubit.markers,
    mapToolbarEnabled: false,
    polylines: mapCubit.placeDirections != null
        ? {
            Polyline(
                polylineId: const PolylineId('my_polyline'),
                color: Colors.black,
                width: 2,
                points: mapCubit.polylinePoints!),
          }
        : {},
  );
}

var searchController = TextEditingController();
Widget buildSearch(mapCubit) {
  return SingleChildScrollView(
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(15),
          child: TextFormField(
            decoration: InputDecoration(
              fillColor: Colors.deepPurple[50],
              filled: true,
              hintText: 'Find a Place ..',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.place, color: Colors.grey),
              prefixIcon: const Icon(Icons.menu, color: Colors.grey),
            ),
            controller: searchController,
            keyboardType: TextInputType.text,
            onChanged: (query) {
              final sessionToken = const Uuid().v4();
              mapCubit.getPlacesSuggestions(query.toString(), sessionToken);
            },
            onTap: () {
              mapCubit.distanceAndTimeVisibleUpdate();
            },
          ),
        ),
        ClipRRect(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              buildSuggestion(),
            ],
          ),
        )
      ],
    ),
  );
}

late PlaceModel placeSuggestion;

Widget buildSuggestion() {
  return BlocConsumer<MapCubit, MapStates>(
    listener: (context, state) {},
    builder: (context, state) {
      if (state is GetPlacesSuccess) {
        MapCubit.get(context).placesList = state.placesList;
        if (MapCubit.get(context).placesList.isNotEmpty) {
          return ListView.builder(
            itemBuilder: (ctx, index) {
              return InkWell(
                onTap: () async {
                  placeSuggestion = MapCubit.get(context).placesList[index];
                  MapCubit.get(context)
                      .getPlaceDetails(placeSuggestion.placeId);
                  searchController.clear();
                  FocusScope.of(context).unfocus();
                  if (MapCubit.get(context).polylinePoints != null) {
                    MapCubit.get(context).polylinePoints!.clear();
                  }
                  MapCubit.get(context).clearMarkerAndUpdate();
                },
                child: buildPlaceItems(
                    MapCubit.get(context).placesList[index], context),
              );
            },
            itemCount: MapCubit.get(context).placesList.length,
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
          );
        } else {
          return Container();
        }
      } else {
        return Container();
      }
    },
  );
}

Widget buildPlaceItems(suggestion, context) {
  var subTitle = suggestion.description
      .replaceAll(suggestion.description.split(',')[0], '');
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 10.0),
    child: Container(
        width: double.infinity,
        margin: const EdgeInsetsDirectional.all(8),
        padding: const EdgeInsetsDirectional.all(4),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(children: [
          ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple[200],
                ),
                child: const Icon(Icons.place),
              ),
              title: RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: '${suggestion.description.split(','[0])}\n',
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: subTitle.substring(2),
                    style: const TextStyle(color: Colors.black, fontSize: 15)),
              ])))
        ])),
  );
}

Widget showDistanceAndTime(mapCubit) {
  return Visibility(
    visible: mapCubit.isDistanceAndTimeVisible,
    child: Positioned(
      top: 0,
      bottom: 570,
      left: 0,
      right: 0,
      child: Row(
        children: [
          Flexible(
            flex: 1,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              color: Colors.white,
              child: ListTile(
                dense: true,
                horizontalTitleGap: 0,
                leading: const Icon(
                  Icons.access_time_filled,
                  size: 30,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  mapCubit.placeDirections!.totalDuration,
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),
          ),
          const SizedBox(width: 30),
          Flexible(
            flex: 1,
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              margin: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              color: Colors.white,
              child: ListTile(
                dense: true,
                horizontalTitleGap: 0,
                leading: const Icon(
                  Icons.directions_car_filled,
                  size: 30,
                  color: Colors.deepPurple,
                ),
                title: Text(
                  mapCubit.placeDirections!.totalDistance,
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
