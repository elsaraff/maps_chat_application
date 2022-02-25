import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

const String googleMapsApiKey = 'googleMapsApiKey Here';

const placesUrl =
    'https://maps.googleapis.com/maps/api/place/autocomplete/json';

const placeDetailsUrl =
    'https://maps.googleapis.com/maps/api/place/details/json';

const placeDirectionUrl =
    'https://maps.googleapis.com/maps/api/directions/json';

String? finalPhoneNumber = '';
String? uId = '';
String? token = '';
File? profileImage;

var now = DateFormat.yMEd().add_jm().format(DateTime.now());

navigateTo(context, widget) {
  return Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => widget),
  );
}

navigateAndFinish(context, widget) {
  return Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => widget),
    (route) => false,
  );
}

showProgressIndicator(BuildContext context) {
  AlertDialog alertDialog = const AlertDialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    content: Center(
        child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple))),
  );
  showDialog(
    context: context,
    builder: (context) => alertDialog,
    barrierColor: Colors.white.withOpacity(0),
    barrierDismissible: false,
  );
}
