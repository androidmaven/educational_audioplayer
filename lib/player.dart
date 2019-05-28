import 'ui/audio_loader.dart';
import 'ui/bottom_player.dart';

class Player extends BottomPlayer {}

loadAudios({context, List<Audio> audios}) {
  showLoadingConfirmationDialog(context: context, audios: audios);
}

deleteAudios({context, List<Audio> audios}) {
  showDeletionConfirmationDialog(context: context, audios: audios);
}

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
