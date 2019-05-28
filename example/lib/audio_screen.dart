import 'package:educational_audioplayer/player.dart';
import 'package:educational_audioplayer/ui/bottom_player.dart';
import 'package:flutter/material.dart';

class AudioScreen extends StatefulWidget {
  final List<Audio> audios;
  AudioScreen(this.audios);

  @override
  _AudioScreenState createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  BottomPlayer bottomPlayer;

  @override
  void initState() {
    super.initState();
    bottomPlayer = BottomPlayer();
  }

  Widget _buildAudioItem(BuildContext context, int index) {
    return ListTile(
      title: Text(widget.audios[index].audioName),
      onTap: () {
        bottomPlayer.show();
        bottomPlayer.play(widget.audios, index);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('educational_audio'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteAudios(context: context, audios: widget.audios);
              }),
          IconButton(
              icon: Icon(Icons.cloud_download),
              onPressed: () {
                loadAudios(context: context, audios: widget.audios);
              })
        ],
      ),
      body: ListView.builder(
        itemBuilder: _buildAudioItem,
        itemCount: widget.audios.length,
      ),
      bottomNavigationBar: bottomPlayer,
    );
  }

  setLastPlayedAudio(url) {}
}
