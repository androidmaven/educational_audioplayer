import 'package:shared_preferences/shared_preferences.dart';

import '../player.dart';
import 'constants.dart';

List<String> allDownloadedAudios = [];

markAudiosAsLoaded(List<Audio> audios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(audios[0].url, true);

  allDownloadedAudios = (prefs.getStringList(resourceAllDownloadedAudio) ?? []);
  allDownloadedAudios.add(audios[0].url);
  prefs.setStringList(resourceAllDownloadedAudio, allDownloadedAudios);
}

markAudiosAsDeleted(List<Audio> audios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setBool(audios[0].url, false);

  allDownloadedAudios = (prefs.getStringList(resourceAllDownloadedAudio) ?? []);
  allDownloadedAudios.removeWhere((item) => item == audios[0].url);
  prefs.setStringList(resourceAllDownloadedAudio, allDownloadedAudios);
}

markAllAudiosAsDeleted() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  allDownloadedAudios = (prefs.getStringList(resourceAllDownloadedAudio) ?? []);
  for (int i = 0; i < allDownloadedAudios.length; i++) {
    prefs.setBool(allDownloadedAudios[i], false);
  }
  prefs.setStringList(resourceAllDownloadedAudio, []);
}

Future<bool> getAudiosLoadingState(List<Audio> audios) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return (prefs.getBool(audios[0].url) ?? false);
}
