import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../util/constants.dart';

FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
bool isNotificationShown = false;

mixin Notifications<T extends StatefulWidget> on State<T> {
  initNotifications() {
    // initialise notification plugin
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  Future<void> onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {}

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
  }

  Future<void> showNotification() async {
    if (!isNotificationShown) {
      var androidPlatformChannelSpecifics = AndroidNotificationDetails(
          'silent channel id',
          'silent channel name',
          'silent channel description',
          playSound: false,
          styleInformation: DefaultStyleInformation(true, true));
      var iOSPlatformChannelSpecifics =
          IOSNotificationDetails(presentSound: false);
      var platformChannelSpecifics = NotificationDetails(
          androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
      await flutterLocalNotificationsPlugin.show(
          0, pressToOpenAudio, '', platformChannelSpecifics);

      isNotificationShown = true;
    }
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
    isNotificationShown = false;
  }
}
