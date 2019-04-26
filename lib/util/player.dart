import 'dart:async';
import 'dart:io';

import 'package:audioplayer/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'loader.dart';

List<String> currentAudioUrls = [];
List<String> currentAudioNames = [];
int currentAudioIndex;

class Player extends StatefulWidget {
  @override
  PlayerState createState() {
    return PlayerState();
  }
}

class PlayerState extends State<Player> {
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

  Future<String> getLocalPath(String url) async {
    final dir = await getApplicationDocumentsDirectory();
    String fileName = url.replaceAll('/', '_').replaceAll(':', '_');
    return '${dir.path}/$fileName';
  }

  Future loadAudio({String url, String path}) async {
    try {
      setState(() {
        isLoading = true;
        print('loading started');
      });
      await loadFile(url: url, path: path);
      setState(() {
        print('loading ended');
        isLoading = false;
      });
    } on Exception {
      print('failed to download audio');
    }
  }

  Future play({List<String> urls, int index, List<String> names}) async {
    currentAudioUrls = urls;
    currentAudioNames = names;
    currentAudioIndex = index;

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
      position = new Duration();
    });
  }

  Future playNext() async {
    if (currentAudioIndex + 1 < currentAudioUrls.length) {
      await audioPlayer.stop();
      setState(() {
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
      currentAudioIndex++;
      play(
          urls: currentAudioUrls,
          index: currentAudioIndex,
          names: currentAudioNames);
    }
  }

  Future playPrevious() async {
    if (currentAudioIndex - 1 > -1) {
      await audioPlayer.stop();
      setState(() {
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
      currentAudioIndex--;
      play(
          urls: currentAudioUrls,
          index: currentAudioIndex,
          names: currentAudioNames);
    }
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
    audioPlayer = new AudioPlayer();
    positionSubscription = audioPlayer.onAudioPositionChanged
        .listen((p) => setState(() => position = p));
    audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.COMPLETED) {
        setState(() {
          duration = new Duration(seconds: 0);
          position = new Duration(seconds: 0);
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
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
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
