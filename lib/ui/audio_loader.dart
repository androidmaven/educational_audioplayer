import 'dart:io';

import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

import '../util/constants.dart';
import '../util/loader.dart';

loadAudios({context, List<String> urls}) {
  _showLoadingConfirmationDialog(context: context, urls: urls);
}

deleteAudios({context, List<String> urls}) {
  _showDeletionConfirmationDialog(context: context, urls: urls);
}

void _showLoadingConfirmationDialog({context, List<String> urls}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(
          loadingConfirmationTitle,
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
                    builder: (context) => LoaderScreen(urls: urls)),
              );
            },
          ),
        ],
      );
    },
  );
}

void _showDeletionConfirmationDialog({context, List<String> urls}) {
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
                          urls: urls,
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
    bool success = true;
    for (int i = 0; i < widget.urls.length; i++) {
      setState(() {
        _loadingText = '$i / ${widget.urls.length}';
      });
      String path = await getLocalPath(widget.urls[i]);
      if (!(await File(path).exists())) {
        try {
          await loadFile(url: widget.urls[i], path: path);
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
    for (int i = 0; i < widget.urls.length; i++) {
      setState(() {
        _loadingText = '$i / ${widget.urls.length}';
      });
      File file = File(await getLocalPath(widget.urls[i]));
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
