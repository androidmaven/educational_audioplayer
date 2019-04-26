import 'package:educational_audioplayer/ui/bottom_player.dart';
import 'package:flutter/material.dart';

import 'audio_template.dart';

class AudioScreen extends StatefulWidget {
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
      title: Text(audioNames[index]),
      onTap: () {
        bottomPlayer.show();
        bottomPlayer.play(
            urls: audios,
            index: index,
            names: audioNames,
            lecturerName: 'Арсен абу Яхья (Шарх шейха аль-Усеймина)',
            chapterName:
                'О достоинстве таухида, и о том, что он искупает грехи');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('educational_audio')),
      body: ListView.builder(
        itemBuilder: _buildAudioItem,
        itemCount: audios.length,
      ),
      bottomNavigationBar: bottomPlayer,
    );
  }
}
