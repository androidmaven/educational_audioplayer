import 'dart:io';

import 'package:flutter/material.dart';
import 'package:progress_hud/progress_hud.dart';

import '../player.dart';
import '../util/constants.dart';
import '../util/loader.dart';
import '../util/shared_preferences.dart';

loadAudios({context, List<Audio> audios, Function setParentWidgetState}) {
  showLoadingConfirmationDialog(
      context: context,
      audios: audios,
      setParentWidgetState: setParentWidgetState);
}

deleteAudios({context, List<Audio> audios, Function setParentWidgetState}) {
  showDeletionConfirmationDialog(
      context: context,
      audios: audios,
      setParentWidgetState: setParentWidgetState);
}

num sizesSum(List<Audio> audios) {
  num sum = 0;
  for (int i = 0; i < audios.length; i++) {
    sum += audios[i].audioSize;
  }
  return sum;
}

void showLoadingConfirmationDialog(
    {context, List<Audio> audios, Function setParentWidgetState}) {
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
                    builder: (context) => LoaderScreen(
                        audios: audios,
                        setParentWidgetState: setParentWidgetState)),
              );
            },
          ),
        ],
      );
    },
  );
}

void showDeletionConfirmationDialog(
    {context, List<Audio> audios, Function setParentWidgetState}) {
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
                        setParentWidgetState: setParentWidgetState)),
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
  final Function setParentWidgetState;
  LoaderScreen(
      {Key key, this.audios, this.delete: false, this.setParentWidgetState})
      : super(key: key);

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
    if (success) {
      markAudiosAsLoaded(widget.audios);
      if (widget.setParentWidgetState is Function) {
        widget.setParentWidgetState();
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
    if (success) {
      markAudiosAsDeleted(widget.audios);
      if (widget.setParentWidgetState is Function) {
        widget.setParentWidgetState();
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

class LoadButton extends StatelessWidget {
  final BuildContext context;
  final List<Audio> audios;
  final Function setParentWidgetState;
  LoadButton({this.context, this.audios, this.setParentWidgetState});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.cloud_download),
        color: Theme.of(context).accentColor,
        onPressed: () {
          loadAudios(
              context: context,
              audios: audios,
              setParentWidgetState: setParentWidgetState);
        });
  }
}

class DeleteButton extends StatelessWidget {
  final BuildContext context;
  final List<Audio> audios;
  final Function setParentWidgetState;
  DeleteButton({this.context, this.audios, this.setParentWidgetState});

  @override
  Widget build(BuildContext context) {
    return IconButton(
        icon: Icon(Icons.delete, color: Theme.of(context).accentColor),
        onPressed: () {
          deleteAudios(
              context: context,
              audios: audios,
              setParentWidgetState: setParentWidgetState);
        });
  }
}

void showAllFilesDeletionConfirmationDialog(
    {context, Function deletionFunction, Function markAllAudiosAsDeleted}) {
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
              deletionFunction();
              markAllAudiosAsDeleted();
            },
          ),
        ],
      );
    },
  );
}
