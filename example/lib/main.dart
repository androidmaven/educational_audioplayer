import 'package:flutter/material.dart';

import 'audio_screen.dart';
import 'audio_template.dart';

void main() {
  runApp(MaterialApp(
    title: 'Audio Sample App',
    home: Home(),
  ));
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('educational_audio_initial_screen')),
        body: Center(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text('1'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AudioScreen(audios1)),
                  );
                },
              ),
              ListTile(
                title: Text('2'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AudioScreen(audios2)),
                  );
                },
              )
            ],
          ),
        ));
  }
}
