import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audioplayer/audioplayer.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

String streamUri =
    'http://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3';
bool isStreamLocal = false;

updateAudioServiceStream(String uri, {bool isLocal: false}) {
  streamUri =
      'http://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3';
  isStreamLocal = isLocal;
}

class AudioServicePlayer {
  static const streamUri =
      'http://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3';
  AudioPlayer _audioPlayer = new AudioPlayer();
  Completer _completer = Completer();

  Future<void> run() async {
    MediaItem mediaItem = MediaItem(
        id: 'audio_1',
        album: 'Sample Album',
        title: 'Sample Title',
        artist: 'Sample Artist');

    AudioServiceBackground.setMediaItem(mediaItem);

    var playerStateSubscription = _audioPlayer.onPlayerStateChanged
        .where((state) => state == AudioPlayerState.COMPLETED)
        .listen((state) {
      stop();
    });
    play();
    await _completer.future;
    playerStateSubscription.cancel();
  }

  void playPause() {
    if (AudioServiceBackground.state.basicState == BasicPlaybackState.playing)
      pause();
    else
      play();
  }

  void play() {
    _audioPlayer.play(streamUri, isLocal: isStreamLocal);
    AudioServiceBackground.setState(
      controls: [pauseControl, stopControl],
      basicState: BasicPlaybackState.playing,
    );
  }

  void pause() {
    _audioPlayer.pause();
    AudioServiceBackground.setState(
      controls: [playControl, stopControl],
      basicState: BasicPlaybackState.paused,
    );
  }

  void stop() {
    _audioPlayer.stop();
    AudioServiceBackground.setState(
      controls: [],
      basicState: BasicPlaybackState.stopped,
    );
    _completer.complete();
  }

//  Future<void> seek(double seconds) async => await _audioPlayer.seek(seconds);

  void seek(int seconds) {
    _audioPlayer.seek(seconds.toDouble());
  }

  Stream<Duration> get onAudioPositionChanged =>
      _audioPlayer.onAudioPositionChanged;

  Stream<AudioPlayerState> get onPlayerStateChanged =>
      _audioPlayer.onPlayerStateChanged;

  Duration get duration => _audioPlayer.duration;
}

void backgroundAudioPlayerTask(String uri, {bool isLocal: false}) async {
  streamUri = uri;
  isStreamLocal = isLocal;
  AudioServicePlayer player = AudioServicePlayer();
  AudioServiceBackground.run(
      onStart: player.run,
      onPlay: player.play,
      onPause: player.pause,
      onStop: player.stop,
      onClick: (MediaButton button) => player.playPause(),
      onSeekTo: player.seek);
}
