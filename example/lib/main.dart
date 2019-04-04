import 'package:flutter/material.dart';

import 'audio_screen.dart';

void main() {
  runApp(new MaterialApp(
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
        child: Text('Press button to open audio screen'),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon((Icons.audiotrack)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AudioScreen()),
            );
          }),
    );
  }
}
