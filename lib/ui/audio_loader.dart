import 'dart:io';

import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

import '../player.dart';
import '../util/constants.dart';
import '../util/loader.dart';

num sizesSum(List<Audio> audios) {
  num sum = 0;
  for (int i = 0; i < audios.length; i++) {
    sum += audios[i].audioSize;
  }
  return sum;
}

void showLoadingConfirmationDialog({context, List<Audio> audios}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          loadingConfirmationTitle_1 +
              sizesSum(audios).toString() +
              loadingConfirmationTitle_2,
          textAlign: TextAlign.center,
        ),
        content: Text(
          loadingConfirmationInfo,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(closeDialogButtonText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(confirmLoadingButtonText),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoaderScreen(audios: audios)),
              );
            },
          ),
        ],
      );
    },
  );
}

void showDeletionConfirmationDialog({context, List<Audio> audios}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          deletionConfirmationTitle,
          textAlign: TextAlign.center,
        ),
        content: Text(
          deletionConfirmationInfo,
          textAlign: TextAlign.center,
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(closeDialogButtonText),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          FlatButton(
            child: Text(confirmDeletionButtonText),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => LoaderScreen(
                          audios: audios,
                          delete: true,
                        )),
              );
            },
          ),
        ],
      );
    },
  );
}

class LoaderScreen extends StatefulWidget {
  final List<Audio> audios;
  final bool delete;
  LoaderScreen({Key key, this.audios, this.delete: false}) : super(key: key);

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
    bool success = true;
    for (int i = 0; i < widget.audios.length; i++) {
      setState(() {
        _loadingText = '$i / ${widget.audios.length}';
      });
      String path = await getLocalPath(widget.audios[i].url);
      if (!(await File(path).exists())) {
        try {
          await loadFile(url: widget.audios[i].url, path: path);
        } on Exception {
          success = false;
          break;
        }
      }
    }
    Navigator.of(context).pop();
    if (!success) {
      showLoadingFailDialog(context);
    }
  }

  Future _deleteAudios() async {
    bool success = true;
    for (int i = 0; i < widget.audios.length; i++) {
      setState(() {
        _loadingText = '$i / ${widget.audios.length}';
      });
      File file = File(await getLocalPath(widget.audios[i].url));
      if (await file.exists()) {
        try {
          await file.delete();
        } on Exception {
          success = false;
        }
      }
    }
    Navigator.of(context).pop();
    if (!success) {
      showDeletionFailDialog(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.delete ? deleteAudiosTitle : downloadAudiosTitle),
        ),
        body: ProgressHUD(text: _loadingText));
  }
}

void showLoadingFailDialog(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title: Text(
            loadingFailedDialogTitle,
            textAlign: TextAlign.center,
          ),
          content: Text(
            loadingFailedDialogInfo,
            textAlign: TextAlign.center,
          ));
    },
  );
}

void showDeletionFailDialog(context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          content: Text(
        deletionFailedDialogInfo,
        textAlign: TextAlign.center,
      ));
    },
  );
}
