import 'dart:async';
import 'dart:developer';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import 'package:pishgaman/consts/app_configs.dart';
import 'package:pishgaman/consts/t.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/models/match_enum.dart';
import 'package:pishgaman/models/rest_response.dart';
import 'package:pishgaman/utils/app_colors.dart';
import 'package:pishgaman/utils/app_sounds.dart';
import 'package:pishgaman/utils/etc.dart';
import 'package:pishgaman/utils/persian_tools.dart';
import 'package:pishgaman/utils/rest_api.dart';
import 'package:pishgaman/views/user_management/login_reg.dart';
import 'package:pishgaman/views/score_board.dart';
import 'package:pishgaman/views/suggest_view.dart';
import 'package:pishgaman/views/tiny_widgets.dart';
import 'package:tapsell_plus/tapsell_plus.dart';
import 'drawer/view.dart';
import 'ranks/ranks_view.dart';
import 'settings_dialog.dart';

class GamePallet extends StatefulWidget {
  final SembastDb? db;
  final AppSettings? settings;

  const GamePallet({
    Key? key,
    required this.db,
    required this.settings,
  }) : super(key: key);

  @override
  _GamePalletState createState() => _GamePalletState();
}

class _GamePalletState extends State<GamePallet>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  MatchEnum get _state => overallStatus(guesses, correct, index);

  bool _loading = false;
  bool get loading => _loading;
  set loading(bool value) => setState(() {
        _loading = value;
      });

  bool _loading2 = false;
  bool get loading2 => _loading2;
  set loading2(bool value) => setState(() => _loading2 = value);

  bool _restarted = false;
  bool get restarted => _restarted;
  set restarted(bool value) => setState(() {
        _restarted = value;
      });

  bool _adSeen = true;
  bool get adSeen => _adSeen;
  set adSeen(bool value) => setState(() => _adSeen = value);

  void playAnim(bool start) async {
    if (start) {
      _animController.repeat(
        min: 0,
        max: 1,
        reverse: true,
        period: 1.seconds,
      );
    } else {
      _animController.stop();
    }
  }

  @override
  void initState() {
    _animController = AnimationController(
      duration: 5.seconds,
      reverseDuration: 5.seconds,
      vsync: this,
    );

    AppSettings.getStream(widget.db)?.listen((AppSettings settings) {
      playAnim(settings.bgSound);
    });

    playAnim(widget.settings?.bgSound ?? true);

    super.initState();
  }

  @override
  void dispose() {
    //_controller.removeListener(_resumeAnimate);
    _controller.dispose();
    super.dispose();
  }

  PinTheme get defaultPinTheme {
    double fw = fieldWidth;
    var status = _state;
    Color color =
        (status == MatchEnum.empty ? MatchEnum.perfect : _state).color;

    return PinTheme(
      width: fw,
      height: fw,
      textStyle: TextStyle(
        fontSize: fw / 2,
        color: color,
      ),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(fw / 3),
        border: Border.all(color: color),
      ),
    );
  }

  PinTheme get focusedPinTheme {
    double fw = fieldWidth;
    Color color = MatchEnum.perfect.color;

    return defaultPinTheme.copyWith(
      textStyle: TextStyle(
        fontSize: fw / 2,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(fw / 3),
        border: Border.all(color: color.darken(0.3)),
      ),
    );
  }

  void reportWord() async {
    // showInfo("Oops!: Not implemented");
    await openSettings(widget.db);
  }

  void showHelp() async {
    showInfo(T.helpText);

    return;
    // await openLoginReg(widget.db);
    // await Get.to(() => LoginRegPage(db: widget.db, settings: widget.settings,));

    String id = await TapsellPlus.instance
        .requestRewardedVideoAd(TapsellIds.rewardBased);

    // TapsellPlus.instance.showRewardedVideoAd(id).then((value) {
    //   showError("ssen: $value");
    //
    // });

    TapsellPlus.instance.showRewardedVideoAd(id, onError: (m) {
      showError("onError");
    }, onRewarded: (m) {
      showError("onRewarded");
    }, onClosed: (m) {});

    // TapsellPlus.instance.displayStandardBanner();
    //
  }

  void toggleSound() async {
    await AppSettings.saveSetting(widget.db, widget.settings?.authToken,
        bgSound: !(widget.settings?.bgSound ?? true));
  }

  // PinTheme get

  String get userName => widget.settings?.userName ?? "NA";
  List<String> get guesses =>
      widget.settings?.guesses ?? AppConfigs.initGuesses;
  int get index => widget.settings?.index ?? 0;
  int get wins => widget.settings?.wins ?? 0;
  int get score => widget.settings?.computedScore ?? 0;

  int get totalRank => (widget.settings?.rank?.rank ?? -2) + 1;
  int get total => widget.settings?.total ?? -1;
  int get loses => widget.settings?.loses ?? 0;
  String get correct => widget.settings?.safeCorrect ?? T.rhino;

  Widget get logoImage => GestureDetector(
        onTap: toggleSound,
        child: Container(
          width: Get.width / 3,
          height: Get.width / 3,
          decoration: BoxDecoration(
            image: DecorationImage(
                image: Image.asset("assets/launcher/logo-lili.png").image),
          ),
        ),
      );

  Widget get loginWidget {
    bool logged = widget.settings?.logged ?? false;
    if (logged) {
      return TextButton(
          onPressed: () {
            Get.to(() => RanksView(
                  settings: widget.settings,
                  db: widget.db,
                ));
          },
          child: Text(
            widget.settings?.userName ?? "--",
          ));
    } else {
      return TextButton(
          onPressed: () {
            Get.to(
                () => LoginRegPage(db: widget.db, settings: widget.settings));
          },
          child: Text(T.login + " ...",
              style: TextStyle(color: AppColors.success)));
    }
  }

  Widget get animatedLogo => RotationTransition(
        turns: Tween(begin: -0.04, end: 0.04).animate(CurvedAnimation(
            parent: _animController, curve: Curves.elasticInOut)),
        child: logoImage,
      );

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

  Widget get progress => loading
      ? Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: LinearProgressIndicator(
            color: _state.color,
            backgroundColor: _state.color.lighten(),
          ),
        )
      : const SizedBox(
          height: 12,
        );

  Widget get header => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: reportWord,
                  icon: Icon(
                    Icons.menu,
                    size: 48,
                    color: AppColors.empty,
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  child: const Text(
                    T.help,
                  ),
                  onPressed: showHelp,
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: badges.Badge(
                showBadge: !(widget.settings?.bgSound ?? true),
                badgeColor: AppColors.accent,
                position: badges.BadgePosition.topStart(),
                badgeContent: GestureDetector(
                  child: const Icon(Icons.volume_mute_outlined,
                      color: Colors.white),
                  onTap: toggleSound,
                ),
                child: animatedLogo,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                loginWidget,
                ScoreBoard(
                  title: T.score,
                  tooltip: scoreTT,
                  score: score,
                  state: MatchEnum.perfect,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: SizedBox(
                    height: 5,
                    width: 90,
                    child: loading2
                        ? Center(
                            child: LinearProgressIndicator(
                              backgroundColor: _state.color.darken(0.2),
                              color: _state.color,
                            ),
                          )
                        : const ZeroWidget(),
                  ),
                ),
                ScoreBoard(
                  title: T.rank,
                  tooltip: totalTT,
                  score: totalRank,
                  state: MatchEnum.none,
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        ],
      );

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

    final history = widget.settings?.history ?? [];
    final oldGame = widget.settings?.gameHistory;
    if (oldGame != null) {
      history.add(oldGame);
      if (history.length > AppConfigs.maxHistory) {
        history.removeAt(0);
      }
    }

    AppSettings.saveSetting(
      widget.db,
      widget.settings?.authToken,
      correct: response.data,
      guesses: AppConfigs.initGuesses,
      index: 0,
      history: history,
    );

    restarted = true;
  }

  String get reportText =>
      T.format0(T.reportWord, widget.settings?.correct ?? "NA");
  void reportIt() async {
    String word = widget.settings?.correct ?? "NA";
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

  Widget get reportButton {
    var state = _state;
    if (state == MatchEnum.empty) return const ZeroWidget();
    return Padding(
      padding: const EdgeInsets.only(top: 18.0),
      child: TextButton(
        onPressed: reportIt,
        child: Text(
          T.format0(T.reportWord, widget.settings?.correct ?? "NA"),
          style: TextStyle(
            color: _state.color,
          ),
        ),
      ),
    );
  }

  Widget get button {
    var state = _state;
    if (state == MatchEnum.empty) return const ZeroWidget();

    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: state.color,
          elevation: 17,
          shadowColor: state.color,
        ),
        onPressed: restartGate,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            state == MatchEnum.perfect ? T.wellDone : T.failDone,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }

  Color get bgColor {
    return _state.color.lighten();
    if ([MatchEnum.none, MatchEnum.perfect].contains(_state)) {
      return _state.color.lighten();
    } else {
      if (widget.settings?.bgImage ?? false) {
        return Colors.amberAccent.lighten();
      } else {
        return _state.color.lighten();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log(correct);
    return GestureDetector(
      onTap: hideKeyboard,
      child: Scaffold(
        drawer: const AppDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        backgroundColor: bgColor,
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width / 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  header,
                  progress,
                  pinPicker,
                  ...guesses.map(
                    (e) => SuggestView(
                      onTap: focusNode.requestFocus,
                      correct: correct,
                      suggest: e,
                    ),
                  ),
                  if (_state == MatchEnum.none)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        T.format0(T.correctAnswer, correct),
                        style: TextStyle(color: MatchEnum.none.color),
                      ),
                    ),
                  button,
                  reportButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void verifyGame(String v) async {
    _controller.clear();

    if (guesses.contains(v)) {
      showError(T.format0(T.alreadyTested, v));
      focusNode.requestFocus();
      return;
    }

    loading = true;
    var exists = await RestApi.verifyWord(v);
    loading = false;

    log("verifyWord.ok ${exists.ok} ${exists.status}");

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
      AppSounds.i.play(widget.settings, SoundsEnum.yes);
      loading2 = true;
      await AppSettings.saveSetting(
        widget.db,
        widget.settings?.authToken,
        guesses: pp,
        index: index + 1,
        wins: wins + 1,
        loses: loses,
      );
      loading2 = false;
    } else if (state == MatchEnum.none) {
      AppSounds.i.play(widget.settings, SoundsEnum.no);
      loading2 = true;
      await AppSettings.saveSetting(
        widget.db,
        widget.settings?.authToken,
        guesses: pp,
        index: index + 1,
        loses: loses + 1,
        wins: wins,
      );
      loading2 = false;
    } else {
      AppSounds.i.play(widget.settings, SoundsEnum.correct);
      AppSettings.saveSetting(
        widget.db,
        widget.settings?.authToken,
        guesses: pp,
        index: index + 1,
      );
    }
  }

  int get wordLength => correct.length;
  double get fieldWidth => 0.8 * Get.width / wordLength - 1;

  final TextEditingController _controller = TextEditingController();
  final focusNode = FocusNode();

  Widget get pinPicker => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Pinput(
          onChanged: (String str) {
            var per = removeNonPersians(str);
            _controller.setText(per);
            log(per);
            //_controller.text = per;
          },
          focusNode: focusNode,
          readOnly: _state != MatchEnum.empty,
          controller: _controller,
          keyboardType: TextInputType.text,
          onCompleted: verifyGame,
          length: 5,
          defaultPinTheme: defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
        ),
      );
}
