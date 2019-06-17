import 'dart:async';
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../player.dart';
import '../util/constants.dart';
import '../util/loader.dart';

List<Audio> currentAudios = [Audio(url: '')];
int currentAudioIndex = 0;
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

class CommonPlayer extends StatefulWidget {
  @override
  CommonPlayerState createState() {
    return CommonPlayerState();
  }
}

class CommonPlayerState extends State<CommonPlayer> {
  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription audioPlayerStateSubscription;
  Duration duration;
  Duration position;
  Function setLastAudioMethod;

  AudioPlayerState playerState = AudioPlayerState.STOPPED;

  get isPlaying => playerState == AudioPlayerState.PLAYING;
  get isPaused => playerState == AudioPlayerState.PAUSED;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
    initNotifications();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    cancelNotification();
    super.dispose();
  }

  Future play(List<Audio> audios, int index,
      {Function setLastAudioMethodLocal}) async {
    currentAudios = audios;
    currentAudioIndex = index;

    if (setLastAudioMethodLocal is Function) {
      setLastAudioMethod = setLastAudioMethodLocal;
      setLastAudioMethod(audios[index].url);
    }
    _updateName(audios[index].authorName);
    showNotification();

    String path = await getLocalPath(audios[index].url);
    if ((await File(path).exists())) {
      _playLocal(path);
    } else {
      _playNetwork(audios[index].url);
    }
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = AudioPlayerState.PAUSED);
    cancelNotification();
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = AudioPlayerState.STOPPED;
      position = Duration();
    });
  }

  Future playNext() async {
    if (currentAudioIndex + 1 < currentAudios.length) {
      if (isPlaying) {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex++;
        play(currentAudios, currentAudioIndex);
      } else {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex++;
        await play(currentAudios, currentAudioIndex);
        await audioPlayer.stop();
      }
    }
  }

  Future playPrevious() async {
    if (currentAudioIndex - 1 > -1) {
      if (isPlaying) {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex--;
        play(currentAudios, currentAudioIndex);
      } else {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex--;
        await play(currentAudios, currentAudioIndex);
        await audioPlayer.stop();
      }
    }
  }

  addSecondsToPosition(double seconds) {
    setState(() {
      Duration newPosition =
          Duration(seconds: (position.inSeconds + seconds).toInt());
      if (newPosition.inSeconds < 0) {
        newPosition = Duration(seconds: 0);
      }
      if (newPosition <= duration) {
        audioPlayer.seek(newPosition.inSeconds.toDouble());
        position = newPosition;
      }
    });
  }

  setPosition(double value) {
    setState(() {
      Duration newPosition = Duration(milliseconds: value.toInt());
      if (newPosition <= duration) {
        audioPlayer.seek(newPosition.inSeconds.toDouble());
        position = Duration(milliseconds: value.toInt());
      }
    });
  }

  _updateName(String name) {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  _initAudioPlayer() {
    audioPlayer = AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.COMPLETED) {
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        _onComplete();
      } else if (s == AudioPlayerState.STOPPED) {
        _onStop();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = AudioPlayerState.STOPPED;
        duration = Duration(seconds: 0);
        position = Duration(seconds: 0);
      });
    });
  }

  Future _playNetwork(String url) async {
    try {
      await audioPlayer.play(url);
      setState(() {
        playerState = AudioPlayerState.PLAYING;
      });
    } on Exception {
      _showPlayFailDialog(context);
    }
  }

  Future _playLocal(String path) async {
    try {
      await audioPlayer.play(path, isLocal: true);
      setState(() => playerState = AudioPlayerState.PLAYING);
    } on Exception {
      _showPlayFailDialog(context);
    }
  }

  _onStop() {
    setState(() => playerState = AudioPlayerState.STOPPED);
  }

  _onComplete() {
    if (currentAudioIndex + 1 < currentAudios.length) {
      currentAudioIndex++;
      play(currentAudios, currentAudioIndex);
    } else {
      _onStop();
    }
  }

  void _showPlayFailDialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            title: Text(
              playFailedDialogTitle,
              textAlign: TextAlign.center,
            ),
            content: Text(
              playFailedDialogInfo,
              textAlign: TextAlign.center,
            ));
      },
    );
  }

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
    pause();
  }

  Future<void> showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        notificationChannelId,
        notificationChannelName,
        notificationChannelDescription,
        playSound: false,
        enableVibration: false,
        ongoing: true,
        styleInformation: DefaultStyleInformation(true, true));
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(presentSound: false);
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0, notificationTitle, notificationBody, platformChannelSpecifics);
  }

  Future<void> cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancel(0);
  }
}
