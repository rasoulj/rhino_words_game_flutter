import 'package:audioplayers/audioplayers.dart';
import 'package:pishgaman/models/app_settings.dart';

enum SoundsEnum {
  yes, no, bgSound, correct,
}

class AppSounds {
  late final AudioPlayer _audioPlayer;
  late final AudioPlayer _restAudioPlayer;
  AppSounds() {
    _audioPlayer = AudioPlayer();
    _restAudioPlayer = AudioPlayer();
    _audioPlayer.onPlayerComplete.listen((event) => playBgSound());
  }

  void playBgSound() {
    _audioPlayer.play(AssetSource("audio/bgSound.mp3")); //, volume: 0.3
  }
  void pause() => _audioPlayer.pause();

  void play(AppSettings? settings, SoundsEnum sound) {
    if(settings?.effectSound ?? true) {
      _restAudioPlayer.play(AssetSource("audio/${sound.name}.mp3")); //, volume: 1
    }
  }


  static final AppSounds _i = AppSounds();
  static AppSounds get i => _i;
}