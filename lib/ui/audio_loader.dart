import 'dart:io';

import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

import '../util/constants.dart';
import '../util/loader.dart';

loadAudios({context, List<String> urls}) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => LoaderScreen(urls: urls)),
  );
}

deleteAudios({context, List<String> urls}) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => LoaderScreen(
              urls: urls,
              delete: true,
            )),
  );
}

class LoaderScreen extends StatefulWidget {
  final List<String> urls;
  final bool delete;
  LoaderScreen({Key key, this.urls, this.delete: false}) : super(key: key);

  @override
  _LoaderScreenState createState() => _LoaderScreenState();
}

class _LoaderScreenState extends State<LoaderScreen> {
  String _loadingText = '';

  @override
  void initState() {
    super.initState();
    widget.delete ? _deleteAudios() : _loadAudios();
  }

  Future _loadAudios() async {
    for (int i = 0; i < widget.urls.length; i++) {
      setState(() {
        _loadingText = '$i / ${widget.urls.length}';
      });
      String path = await getLocalPath(widget.urls[i]);
      if (!(await File(path).exists())) {
        try {
          await loadFile(url: widget.urls[i], path: path);
        } on Exception {
          print('failed to download audios');
          break;
        }
      }
    }
    Navigator.of(context).pop();
  }

  Future _deleteAudios() async {
    for (int i = 0; i < widget.urls.length; i++) {
      setState(() {
        _loadingText = '$i / ${widget.urls.length}';
      });
      File file = File(await getLocalPath(widget.urls[i]));
      if (await file.exists()) {
        try {
          await file.delete();
        } on Exception {
          print('failed to delete audios');
          break;
        }
      }
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
              widget.delete ? resourceDeleteAudios : resourceDownloadAudios),
        ),
        body: ProgressHUD(text: _loadingText));
  }
}
