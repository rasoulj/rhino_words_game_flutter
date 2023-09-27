import 'package:get/get.dart';
import 'package:pishgaman/controllers/game_controller.dart';
import 'package:pishgaman/models/app_settings.dart';

class GameBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => const AppSettings());
    Get.lazyPut(() => GameController());
  }
}
