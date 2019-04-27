import 'package:dynamic_theme/dynamic_theme.dart';
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
    return DynamicTheme(
        defaultBrightness: Brightness.light,
        data: (brightness) => ThemeData(
            canvasColor: brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            primarySwatch: Colors.indigo,
            brightness: brightness,
            accentColor: Colors.indigo,
            unselectedWidgetColor: Colors.blueGrey[600]),
        themedWidgetBuilder: (context, theme) {
          return Scaffold(
            appBar: AppBar(title: Text('educational_audio'), actions: <Widget>[IconButton(
              icon: Icon(Icons.brightness_6),
              onPressed: () {
//      It is possible to change whole theme https://github.com/Norbert515/dynamic_theme
                DynamicTheme.of(context).setBrightness(
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark);
              },
            )],),
            body: ListView.builder(
              itemBuilder: _buildAudioItem,
              itemCount: audios.length,
            ),
            bottomNavigationBar: bottomPlayer,
          );
        });
  }
}
