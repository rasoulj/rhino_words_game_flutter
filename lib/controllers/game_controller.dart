import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:pishgaman/consts/app_configs.dart';
import 'package:pishgaman/consts/t.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/models/match_enum.dart';
import 'package:pishgaman/models/rest_response.dart';
import 'package:pishgaman/utils/app_sounds.dart';
import 'package:pishgaman/utils/debug.dart';
import 'package:pishgaman/utils/etc.dart';
import 'package:pishgaman/utils/persian_tools.dart';
import 'package:pishgaman/utils/rest_api.dart';
import 'package:pishgaman/views/settings_dialog.dart';
import 'package:pishgaman/views/tiny_widgets.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

class GameController extends GetxController with GetTickerProviderStateMixin {
  //final SembastDb? db;

  GameController();

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

  AppSettings settings = const AppSettings();

  String get userName => settings.userName ?? "NA";
  List<String> get guesses => settings.guesses;
  int get index => settings.index;
  int get wins => settings.wins;
  int get score => settings.computedScore;

  int get totalRank => (settings.rank?.rank ?? -2) + 1;
  int get total => settings.total;
  int get loses => settings.loses;
  String get correct => settings.safeCorrect;

  String get scoreTT => <String>[
        T.format0(T.wins0, wins.toString()),
        T.format0(T.loses0, loses.toString()),
        T.format0(T.total0, score.toString()),
      ].join("\n");

  String get totalTT {
    int tr = totalRank;
    if (tr < 0) return T.errorRank;
    return <String>[
      T.format0(T.rank0, totalRank.toString()),
      T.format0(T.totalRank0, total.toString()),
    ].join("\n");
  }

  late AnimationController animController;
  final TextEditingController textController = TextEditingController();
  final focusNode = FocusNode();

  @override
  void onInit() {
    animController = AnimationController(
      duration: 5.seconds,
      reverseDuration: 5.seconds,
      vsync: this,
    );

    //TODO:
    /*
    AppSettings.getStream(widget.db)?.listen((AppSettings settings) {
      playAnim(settings.bgSound);
    });

    playAnim(widget.settings?.bgSound ?? true);
    */

    super.onInit();
  }

  void pinputChanged(String str) {
    var per = removeNonPersians(str);
    textController.setText(per);
    debug(per);
  }

  @override
  void onClose() {
    textController.dispose();
    animController.dispose();
    super.onClose();
  }

  void playAnim(bool start) async {
    if (start) {
      animController.repeat(
        min: 0,
        max: 1,
        reverse: true,
        period: 1.seconds,
      );
    } else {
      animController.stop();
    }
  }

  void reportWord() async {
    // showInfo("Oops!: Not implemented");
    await openSettings(db);
  }

  void showHelp() async {
    showInfo(T.helpText);

    return;
    // // await openLoginReg(widget.db);
    // // await Get.to(() => LoginRegPage(db: widget.db, settings: widget.settings,));

    // String id = await TapsellPlus.instance
    //     .requestRewardedVideoAd(TapsellIds.rewardBased);

    // // TapsellPlus.instance.showRewardedVideoAd(id).then((value) {
    // //   showError("ssen: $value");
    // //
    // // });

    // TapsellPlus.instance.showRewardedVideoAd(id, onError: (m) {
    //   showError("onError");
    // }, onRewarded: (m) {
    //   showError("onRewarded");
    // }, onClosed: (m) {});

    // TapsellPlus.instance.displayStandardBanner();
    //
  }

  void toggleSound() async {
    await AppSettings.saveSetting(
      db,
      settings.authToken,
      bgSound: !(settings.bgSound),
    );
  }

  MatchEnum get state => overallStatus(guesses, correct, index);

  void restartGate() async {
    try {
      startGate();
    } catch (e) {
      showError(e.toString());
    }
  }

  void restartGateWithAd() async {
    try {
      if ((wins + loses) % 3 != 0) {
        startGate();
        return;
      }

      String id = await TapsellPlus.instance
          .requestRewardedVideoAd(TapsellIds.rewardBased);

      if (id.isEmpty) {
        startGate();
        return;
      }

      adSeen = false;
      TapsellPlus.instance.showRewardedVideoAd(id, onError: (m) {
        startGate();
      }, onRewarded: (m) {
        startGate();
      }, onClosed: (m) {
        Timer(300.milliseconds, () {
          if (!adSeen) showError(T.adError);
        });
      });
    } catch (e) {
      showError(e.toString());
    }
  }

  void startGate() async {
    adSeen = true;

    loading = true;
    ApiResponse<String> response = await RestApi.fetchWord();
    loading = false;

    if (!response.ok) {
      showError(response.message);
      return;
    }

    final history = settings.history;
    // final oldGame = settings.gameHistory;
    // if (oldGame != null) {
    //   history.add(oldGame);
    //   if (history.length > AppConfigs.maxHistory) {
    //     history.removeAt(0);
    //   }
    // }

    AppSettings.saveSetting(
      db,
      settings.authToken,
      correct: response.data,
      guesses: AppConfigs.initGuesses,
      index: 0,
      history: history,
    );

    restarted = true;
  }

  String get reportText => T.format0(
        T.reportWord,
        settings.correct,
      );

  void reportIt() async {
    String word = settings.correct;
    bool? q = await askQuestion(T.format0(T.reportWordQ, word));
    if (q == false) return;
    loading = true;
    var res = await RestApi.reportWord(word);
    loading = false;

    if (res.ok) {
      showInfo(T.format0(T.reportWordS, word));
    } else {
      showError(res.message);
    }
  }

  void verifyGame(String v) async {
    textController.clear();

    if (guesses.contains(v)) {
      showError(T.format0(T.alreadyTested, v));
      focusNode.requestFocus();
      return;
    }

    loading = true;
    var exists = await RestApi.verifyWord(v);
    loading = false;

    debug("verifyWord.ok ${exists.ok} ${exists.status}");

    if (!exists.ok) {
      showError(exists.message);
      return;
    }

    if (!(exists.data ?? false)) {
      showError(T.format0(T.wordNotExist, v));
      return;
    }

    var pp = [...guesses];
    pp[index] = v;

    var state = overallStatus(pp, correct, index + 1);

    if (state == MatchEnum.perfect) {
      AppSounds.i.play(settings, SoundsEnum.yes);
      loading2 = true;
      await AppSettings.saveSetting(
        db,
        settings.authToken,
        guesses: pp,
        index: index + 1,
        wins: wins + 1,
        loses: loses,
      );
      loading2 = false;
    } else if (state == MatchEnum.none) {
      AppSounds.i.play(settings, SoundsEnum.no);
      loading2 = true;
      await AppSettings.saveSetting(
        db,
        settings.authToken,
        guesses: pp,
        index: index + 1,
        loses: loses + 1,
        wins: wins,
      );
      loading2 = false;
    } else {
      AppSounds.i.play(settings, SoundsEnum.correct);
      AppSettings.saveSetting(
        db,
        settings.authToken,
        guesses: pp,
        index: index + 1,
      );
    }
  }

  int get wordLength => correct.length;
  double get fieldWidth => 0.8 * Get.width / wordLength - 1;
}
