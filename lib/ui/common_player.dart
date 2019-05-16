import 'dart:async';
import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';

import '../util/constants.dart';
import '../util/loader.dart';
import 'audio_loader.dart';
import "audio_service_player.dart";

List<String> currentAudioUrls = [];
List<String> currentAudioNames = [];
int currentAudioIndex;
String currentChapterName = '';
String currentLecturerName = '';

class CommonPlayer extends StatefulWidget {
  @override
  CommonPlayerState createState() {
    return CommonPlayerState();
  }
}

class CommonPlayerState extends State<CommonPlayer>
    with WidgetsBindingObserver {
  PlaybackState _state;
  StreamSubscription _playbackStateSubscription;

  AudioServicePlayer player;
  StreamSubscription positionSubscription;
  StreamSubscription audioPlayerStateSubscription;
  Duration duration;
  Duration position;
  String audioName = '';

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
    WidgetsBinding.instance.addObserver(this);
    connect();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    audioPlayerStateSubscription.cancel();
    AudioService.stop();
    disconnect();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        connect();
        break;
      case AppLifecycleState.paused:
        disconnect();
        break;
      default:
        break;
    }
  }

  void connect() async {
    await AudioService.connect();
    if (_playbackStateSubscription == null) {
      _playbackStateSubscription = AudioService.playbackStateStream
          .listen((PlaybackState playbackState) {
        setState(() {
          _state = playbackState;
        });
      });
    }
  }

  void disconnect() {
    if (_playbackStateSubscription != null) {
      _playbackStateSubscription.cancel();
      _playbackStateSubscription = null;
    }
    AudioService.disconnect();
  }

  Future start(
      {List<String> urls,
      int index,
      List<String> names,
      String lecturerName,
      String chapterName}) async {
    if (lecturerName == null) {
      lecturerName = currentLecturerName;
    }
    if (chapterName == null) {
      chapterName = currentChapterName;
    }

    currentAudioUrls = urls;
    currentAudioNames = names;
    currentAudioIndex = index;
    currentChapterName = chapterName;
    currentLecturerName = lecturerName;

    _updateName(names[index]);

    String path = await getLocalPath(urls[index]);
    if ((await File(path).exists())) {
      _startLocal(path);
    } else {
      _startNetwork(urls[index]);
      _loadAudio(url: urls[index], path: path);
    }
  }

  Future play() async {
    String path = await getLocalPath(currentAudioUrls[currentAudioIndex]);
    if ((await File(path).exists())) {
      _playLocal(path);
    } else {
      _playNetwork(currentAudioUrls[currentAudioIndex]);
    }
  }

  Future pause() async {
    await AudioService.pause();
    setState(() => playerState = AudioPlayerState.PAUSED);
  }

  Future stop() async {
    await AudioService.stop();
    setState(() {
      playerState = AudioPlayerState.STOPPED;
      position = Duration();
    });
  }

  Future playNext() async {
    if (currentAudioIndex + 1 < currentAudioUrls.length) {
      if (isPlaying) {
        await AudioService.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex++;
        start(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
      } else {
        await AudioService.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex++;
        await start(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
        await AudioService.stop();
      }
    }
  }

  Future playPrevious() async {
    if (currentAudioIndex - 1 > -1) {
      if (isPlaying) {
        await AudioService.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex--;
        start(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
      } else {
        await AudioService.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex--;
        await start(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
        await AudioService.stop();
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
        AudioService.seekTo(newPosition.inSeconds);
        position = newPosition;
      }
    });
  }

  setPosition(double value) {
    setState(() {
      Duration newPosition = Duration(milliseconds: value.toInt());
      if (newPosition <= duration) {
        AudioService.seekTo(newPosition.inSeconds);
        position = Duration(milliseconds: value.toInt());
      }
    });
  }

  _updateName(String name) {
    setState(() {
      audioName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  _initAudioPlayer() {
    player = AudioServicePlayer();
    positionSubscription = player.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    audioPlayerStateSubscription = player.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = player.duration);
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

  Future _loadAudio({String url, String path}) async {
    try {
      await loadFile(url: url, path: path);
    } on Exception {
      showLoadingFailDialog(context);
    }
  }

  Future _playNetwork(String url) async {
    try {
      updateAudioServiceStream(url);

      await AudioService.play();
      setState(() {
        playerState = AudioPlayerState.PLAYING;
      });
    } on Exception {
      _showPlayFailDialog(context);
    }
  }

  Future _playLocal(String path) async {
    try {
      updateAudioServiceStream(path, isLocal: true);

      await AudioService.play();
      setState(() => playerState = AudioPlayerState.PLAYING);
    } on Exception {
      _showPlayFailDialog(context);
    }
  }

  Future _startNetwork(String url) async {
    try {
      updateAudioServiceStream(url);

      await AudioService.start(
        backgroundTask: backgroundAudioPlayerTask,
        resumeOnClick: true,
        androidNotificationChannelName: 'Audio Service qqqqqq',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
      setState(() {
        playerState = AudioPlayerState.PLAYING;
      });
    } on Exception {
      _showPlayFailDialog(context);
    }
  }

  Future _startLocal(String path) async {
    try {
      updateAudioServiceStream(path, isLocal: true);

      await AudioService.start(
        backgroundTask: backgroundAudioPlayerTask,
        resumeOnClick: true,
        androidNotificationChannelName: 'Audio Service qqqqqq',
        notificationColor: 0xFF2196f3,
        androidNotificationIcon: 'mipmap/ic_launcher',
      );
      setState(() => playerState = AudioPlayerState.PLAYING);
    } on Exception {
      _showPlayFailDialog(context);
    }
  }

  _onStop() {
    setState(() => playerState = AudioPlayerState.STOPPED);
  }

  _onComplete() {
    if (currentAudioIndex + 1 < currentAudioUrls.length) {
      currentAudioIndex++;
      start(
          urls: currentAudioUrls,
          index: currentAudioIndex,
          names: currentAudioNames);
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
}
