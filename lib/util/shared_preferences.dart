import 'package:shared_preferences/shared_preferences.dart';

import '../player.dart';

markAudiosAsLoaded(List<Audio> audios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(audios[0].url, true);
}

markAudiosAsDeleted(List<Audio> audios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(audios[0].url, false);
}

Future<bool> getAudiosLoadingState(List<Audio> audios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getBool(audios[0].url) ?? false);
}
