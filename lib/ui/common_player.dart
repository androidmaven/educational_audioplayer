import 'dart:async';
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';

import '../util/loader.dart';

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

class CommonPlayerState extends State<CommonPlayer> {
  AudioPlayer audioPlayer;
  StreamSubscription positionSubscription;
  StreamSubscription audioPlayerStateSubscription;
  Duration duration;
  Duration position;
  bool isLoading = false;
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
    initAudioPlayer();
  }

  @override
  void dispose() {
    positionSubscription.cancel();
    audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  Future loadAudio({String url, String path}) async {
    try {
      setState(() {
        print('audio loading started');
      });
      await loadFile(url: url, path: path);
      setState(() {
        print('audio loading ended');
      });
    } on Exception {
      print('failed to download audio');
    }
  }

  Future play(
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

    updateName(names[index]);

    String path = await getLocalPath(urls[index]);
    if ((await File(path).exists())) {
      _playLocal(path);
    } else {
      _playNetwork(urls[index]);
      if (!isLoading) {
        loadAudio(url: urls[index], path: path);
      }
    }
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = AudioPlayerState.PAUSED);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = AudioPlayerState.STOPPED;
      position = Duration();
    });
  }

  Future playNext() async {
    if (currentAudioIndex + 1 < currentAudioUrls.length) {
      if (isPlaying) {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex++;
        play(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
      } else {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex++;
        await play(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
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
        play(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
      } else {
        await audioPlayer.stop();
        setState(() {
          duration = Duration(seconds: 0);
          position = Duration(seconds: 0);
        });
        currentAudioIndex--;
        await play(
            urls: currentAudioUrls,
            index: currentAudioIndex,
            names: currentAudioNames);
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

  updateName(String name) {
    setState(() {
      audioName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  initAudioPlayer() {
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
    await audioPlayer.play(url);
    setState(() {
      playerState = AudioPlayerState.PLAYING;
    });
  }

  Future _playLocal(String path) async {
    await audioPlayer.play(path, isLocal: true);
    setState(() => playerState = AudioPlayerState.PLAYING);
  }

  _onStop() {
    setState(() => playerState = AudioPlayerState.STOPPED);
  }

  _onComplete() {
    if (currentAudioIndex + 1 < currentAudioUrls.length) {
      currentAudioIndex++;
      play(
          urls: currentAudioUrls,
          index: currentAudioIndex,
          names: currentAudioNames);
    } else {
      _onStop();
    }
  }
}
