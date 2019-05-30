import 'ui/bottom_player.dart';

class Player extends BottomPlayer {}

class Audio {
  final String url;
  final String audioName;
  final String audioDescription;
  final num audioSize;
  final String chapterName;
  final String authorName;

  Audio(
      {this.url,
      this.audioName: '',
      this.audioDescription: '',
      this.audioSize: 0,
      this.chapterName: '',
      this.authorName: ''});
}
