import 'package:educational_audioplayer/ui/bottom_player.dart';
import 'package:flutter/material.dart';

class AudioScreen extends StatefulWidget {
  final List<String> audios;
  final List<String> audioNames;
  AudioScreen(this.audios, this.audioNames);

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
      title: Text(widget.audioNames[index]),
      onTap: () {
        bottomPlayer.show();
        bottomPlayer.play(
            urls: widget.audios,
            index: index,
            names: widget.audioNames,
            lecturerName: 'Арсен абу Яхья (Шарх шейха аль-Усеймина)',
            chapterName:
                'Глава 2. О достоинстве таухида, и о том, что он искупает грехи');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            appBar: AppBar(title: Text('educational_audio')),
            body: ListView.builder(
              itemBuilder: _buildAudioItem,
              itemCount: widget.audios.length,
            ),
            bottomNavigationBar: bottomPlayer,
          );
  }
}
