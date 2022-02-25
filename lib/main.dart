import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_maps/app_cubit/app_cubit.dart';
import 'package:flutter_maps/map_cubit/map_cubit.dart';
import 'package:flutter_maps/shared/cache_helper.dart';
import 'package:flutter_maps/shared/functions.dart';
import 'package:flutter_maps/phone_auth_cubit/phone_auth_cubit.dart';
import 'package:flutter_maps/screens/home_screen.dart';
import 'package:flutter_maps/screens/login_screen.dart';

Future<void> firebaseMessagingBackGroundHandler(RemoteMessage message) async {
  debugPrint('onBackgroundMessage ' + message.data.toString());
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  token = (await FirebaseMessaging.instance.getToken())!;

  FirebaseMessaging.onMessage.listen((event) {
    debugPrint('onMessage event.data ' + event.data.toString());
  });

  FirebaseMessaging.onMessageOpenedApp.listen((event) {
    debugPrint('onMessageOpenedApp  event.data ' + event.data.toString());
  });

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackGroundHandler);

  await CacheHelper.init();

  uId = CacheHelper.getData(key: 'uId');
  Widget? startWidget;

  if (uId != null) {
    startWidget = const HomeScreen();
  } else {
    //uId = null
    startWidget = LoginScreen();
  }

  runApp(MyApp(
    startWidget: startWidget,
  ));
}

class MyApp extends StatelessWidget {
  final Widget? startWidget;

  const MyApp({Key? key, this.startWidget}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => PhoneAuthCubit(),
        ),
        BlocProvider(
          create: (context) => AppCubit()
            ..getUserData()
            ..getAllUsers(),
        ),
        BlocProvider(
          create: (context) => MapCubit()
            ..getMyCurrentLocation()
            ..goToMyCurrentLocation(),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          primarySwatch: Colors.deepPurple,
        ),
        debugShowCheckedModeBanner: false,
        home: startWidget,
      ),
    );
  }
}
