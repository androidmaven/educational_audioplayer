import 'package:flutter/material.dart';

import '../util/constants.dart';
import '../util/player.dart';

_BottomSheetPlayerState _playerState;

class BottomPlayer extends Player {
  play({List<String> urls, int index, List<String> names}) {
    if (currentAudioUrls.length > 0 &&
        urls[index] != currentAudioUrls[currentAudioIndex]) {
      _playerState.stop();
    }
    _playerState.play(urls: urls, index: index, names: names);
  }

  hide() {
    _playerState.hide();
  }

  show() {
    _playerState.show();
  }

  @override
  _BottomSheetPlayerState createState() {
    _playerState = _BottomSheetPlayerState();
    return _playerState;
  }
}

class _BottomSheetPlayerState extends PlayerState {
  bool isHidden = true;

  hide() {
    setState(() {
      isHidden = true;
    });
  }

  show() {
    setState(() {
      isHidden = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: !isHidden,
      maintainState: true,
      child: Container(
          padding: EdgeInsets.all(15.0),
          child: Wrap(children: [
            Column(
              children: <Widget>[
                Text(
                  audioName,
                  style: TextStyle(fontSize: audioNameSize),
                ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  (duration == null)
                      ? Container()
                      : Column(
                          children: <Widget>[
                            Slider(
                                value:
                                    position?.inMilliseconds?.toDouble() ?? 0.0,
                                onChanged: (double value) => audioPlayer
                                    .seek((value / 1000).roundToDouble()),
                                min: 0.0,
                                max: duration.inMilliseconds.toDouble()),
                            Text(
                                "${position != null ? positionText : ''}    /    $durationText",
                                style: TextStyle(fontSize: timeSize)),
                          ],
                        ),
                  IconButton(
                      onPressed: () {
                        isPlaying
                            ? pause()
                            : play(
                                urls: currentAudioUrls,
                                index: currentAudioIndex,
                                names: currentAudioNames);
                      },
                      iconSize: iconSize,
                      icon: isPlaying
                          ? Icon(Icons.pause)
                          : Icon(Icons.play_arrow),
                      color: buttonColor)
                ]),
                Row(
                  children: <Widget>[
                    IconButton(
                        onPressed: () {
                          playPrevious();
                        },
                        iconSize: iconSize,
                        icon: Icon(Icons.skip_previous),
                        color: buttonColor),
                    IconButton(
                        onPressed: () {
                          playNext();
                        },
                        iconSize: iconSize,
                        icon: Icon(Icons.skip_next),
                        color: buttonColor)
                  ],
                )
              ],
            ),
          ])),
    );
  }
}
