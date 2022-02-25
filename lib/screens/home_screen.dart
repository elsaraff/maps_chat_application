import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_cubit.dart';
import 'package:flutter_maps/app_cubit/app_states.dart';
import 'package:flutter_maps/map_cubit/map_cubit.dart';
import 'package:flutter_maps/map_cubit/map_states.dart';
import 'package:flutter_maps/screens/my_drawer.dart';
import 'package:flutter_maps/shared/widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapStates>(
      listener: (context, state) {
        var mapCubit = MapCubit.get(context);

        if (state is GetPlacesDetailsSuccess) {
          mapCubit.goToMySearchedForLocation();
        }

        if (state is GetPlaceDirectionSuccess) {
          mapCubit.getPolylinePoints();
          mapCubit.markerClicked();
        }
      },
      builder: (context, state) {
        var mapCubit = MapCubit.get(context);

        return Scaffold(
            drawer: const MyDrawer(),
            appBar: AppBar(
              title: BlocConsumer<AppCubit, AppStates>(
                listener: (context, state) {},
                builder: (context, state) {
                  return const Text('Maps');
                },
              ),
            ),
            floatingActionButton: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 8, 30),
              child: FloatingActionButton(
                onPressed: mapCubit.goToMyCurrentLocation,
                child: const Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
              ),
            ),
            body: ConditionalBuilder(
                condition: mapCubit.position != null,
                builder: (context) => Stack(
                      children: [
                        buildMap(mapCubit),
                        buildSearch(mapCubit),
                        mapCubit.isSearchPlaceMarkerClicked &&
                                mapCubit.polylinePoints != null
                            ? showDistanceAndTime(mapCubit)
                            : Container()
                      ],
                    ),
                fallback: (context) =>
                    const Center(child: CircularProgressIndicator())));
      },
    );
  }
}
