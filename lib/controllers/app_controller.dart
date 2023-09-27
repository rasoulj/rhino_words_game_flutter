import 'package:get/get.dart';
import 'package:pishgaman/db/sembast_db.dart';

class AppController extends GetxController {
  final SembastDb? db;

  AppController(this.db);

  final Rx<bool> _loading = false.obs;
  bool get loading => _loading.value;
  set loading(bool value) => _loading.value = value;

  final Rx<bool> _loading2 = false.obs;
  bool get loading2 => _loading2.value;
  set loading2(bool value) => _loading2.value = value;

  final Rx<bool> _restarted = false.obs;
  bool get restarted => _restarted.value;
  set restarted(bool value) => _restarted.value = value;

  final Rx<bool> _adSeen = true.obs;
  bool get adSeen => _adSeen.value;
  set adSeen(bool value) => _adSeen.value = value;

  final Rx<String> _userName = "".obs;
  String get userName => _userName.value;
  set userName(String value) => _userName.value = value;

  final Rx<String> _password = "".obs;
  String get password => _password.value;
  set password(String value) => _password.value = value;

  @override
  void onInit() {
    super.onInit();
  }
}
