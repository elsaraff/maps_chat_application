import 'package:dio/dio.dart';

var postUrl = "https://fcm.googleapis.com/fcm/send";

final headers = {
  'Content-Type': 'application/json',
  'Authorization':
      'key=AAAA5E-ezcg:APA91bGWRhVco7lEhTtXKT5bAO3Duq6rtli1cyXhQP9_EUjw_lEuJZd2QOTLfHwqa2s-EJurRtiCFu7QeJw1YZlSJYJLTK_yGdvewWP1UP118o96N1PZZ9vjeBanp3FnbLU9kTygK3eJ',
};

Future<void> messageNotification({
  receiverToken,
  sender,
  message,
}) async {
  var dio = Dio(BaseOptions(receiveDataWhenStatusError: true));
  await dio
      .post(
    postUrl,
    data: {
      "to": receiverToken,
      "notification": {"title": sender, "body": message},
      "android": {
        "priority": "HIGH",
        "notification": {
          "notification_priority": "PRIORITY_MAX",
          "sound": "default",
          "default_sound": true,
          "default_vibrate_timings": true,
          "default_light_settings": true
        }
      },
      "data": {
        "id": "1",
        "name": "mohamed",
        "click_action": "FLUTTER_NOTIFICATION_CLICK"
      }
    },
    options: Options(headers: headers),
  )
      .then((value) {
    // debugPrint(receiverToken);
    //debugPrint(sender);
    // debugPrint(message);

    //debugPrint('value ' + value.data.toString());
  });
}
