import 'package:flutter/material.dart';

import 'player.dart';
import 'ui/audio_loader.dart';
import 'util/shared_preferences.dart';

class LoadDeleteButton extends StatefulWidget {
  final BuildContext context;
  final List<Audio> audios;
  LoadDeleteButton({this.context, this.audios});

  @override
  _LoadDeleteButtonState createState() => _LoadDeleteButtonState();
}

class _LoadDeleteButtonState extends State<LoadDeleteButton> {
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    getLoadingState();
  }

  getLoadingState() async {
    isLoaded = await getAudiosLoadingState(widget.audios);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return isLoaded
        ? DeleteButton(
            context: context,
            audios: widget.audios,
            setParentWidgetState: getLoadingState)
        : LoadButton(
            context: context,
            audios: widget.audios,
            setParentWidgetState: getLoadingState);
  }
}
