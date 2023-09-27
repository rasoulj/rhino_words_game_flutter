import 'dart:developer';

import 'package:get/get.dart';
import 'package:pishgaman/consts/app_configs.dart';
import 'package:pishgaman/consts/t.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/db/types.dart';
import 'package:pishgaman/models/game_history.dart';
import 'package:pishgaman/utils/debug.dart';

import '../consts/f.dart';
import '../utils/rest_api.dart';
import 'rank.dart';
import 'rest_response.dart';

const String singleDocsCollection = "singleDocsCollection";

class AppSettings {
  static const String _docId = "AppSettings";

  const AppSettings({
    this.winsScore = 5,
    this.loseScore = 1,
    this.total = 0,
    this.score = 0,
    this.ranks = const [],
    this.id,
    this.userName,
    this.createdAt,
    this.updatedAt,
    this.correct = T.rhino,
    this.wins = 0,
    this.loses = 0,
    this.index = 0,
    this.guesses = const [
      "",
      "",
      "",
      "",
      "",
      "",
      "",
    ],
    this.history = const [],
    this.bgImage = true,
    this.bgSound = true,
    this.effectSound = true,
    this.authToken,
  });

  GameHistory get gameHistory => GameHistory(
        correct: correct,
        guesses: guesses,
        playedAt: DateTime.now(),
      );

  static Stream<AppSettings>? getStream(SembastDb? db) {
    Stream<Json?>? res = db?.docStream(singleDocsCollection, _docId);
    return res?.map((json) => AppSettings.fromJson(json));
  }

  static Future<void> logout(SembastDb? db) async {
    await db?.setData(
      singleDocsCollection,
      const AppSettings().userSettings,
      id: _docId,
      merge: false,
    );
  }

  static Future<void> saveLocalJson(SembastDb? db, Json? doc) async {
    debug("message = saveLocalJson: $doc");
    await db?.setData(
      singleDocsCollection,
      doc ?? {},
      id: _docId,
      merge: true,
    );
  }

  static Future<void> saveJsonSetting(
    SembastDb? db,
    String? token,
    Json? doc,
  ) async {
    if (doc?.isEmpty ?? true) {
      return;
    }

    try {
      await db?.setData(
        singleDocsCollection,
        doc ?? {},
        id: _docId,
        merge: true,
      );

      debug("message = saveJsonSetting: $doc");
      if (token == null) {
        return;
      }
      ApiResponse<Json?> resp = await RestApi.update(doc, token);

      if (!resp.ok || (resp.data ?? {}).isEmpty) {
        return;
      }

      await db?.setData(
        singleDocsCollection,
        resp.data ?? {},
        id: _docId,
        merge: true,
      );

      debug((resp.data ?? {}).toString());
    } catch (e) {
      debug(e.toString());
    }
  }

  static Future<void> clearSetting(SembastDb? db) {
    return saveSetting(
      db,
      null,
      index: 0,
      wins: 0,
      loses: 0,
      guesses: AppConfigs.initGuesses,
      history: [],
      correct: T.rhino,
      bgSound: true,
      bgImage: true,
      effectSound: true,
      authToken: null,
    );
  }

  static Future<void> saveSetting(
    SembastDb? db,
    String? token, {
    int? index,
    int? wins,
    int? loses,
    List<String>? guesses,
    String? correct,
    bool? bgSound,
    bool? bgImage,
    bool? effectSound,
    String? authToken,
    List<GameHistory>? history,
  }) async {
    Json doc = {
      if (index != null) F.index: index,
      if (wins != null) F.wins: wins,
      if (loses != null) F.loses: loses,
      if (correct != null) F.correct: correct,
      if ((guesses ?? []).length == AppConfigs.maxTry) F.guesses: guesses,
      if (bgSound != null) F.bgSound: bgSound,
      if (bgImage != null) F.bgImage: bgImage,
      if (effectSound != null) F.effectSound: effectSound,
      if (authToken != null) F.authToken: authToken,
      if (history != null) F.history: history.map((e) => e.toJson()),
    };

    return saveJsonSetting(db, token, doc);
  }

  final String? authToken;
  final String? id;
  final String? userName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final int winsScore;
  final int loseScore;
  final int total;
  final int score;
  final List<Rank> ranks;

  final int wins;
  final int loses;
  final int index;
  final String correct;
  final List<String> guesses;
  final List<GameHistory> history;
  final bool bgImage;
  final bool bgSound;
  final bool effectSound;

  String get safeCorrect =>
      correct.length != T.rhino.length ? T.rhino : correct;
      
  bool get logged => (authToken ?? "") != "";

  int get computedScore => wins * winsScore + loses * loseScore;

  factory AppSettings.fromJson(Json? json) => json == null
      ? const AppSettings()
      : AppSettings(
          winsScore: json.getIntField(F.winsScore, defValue: 5),
          loseScore: json.getIntField(F.loseScore, defValue: 1),
          total: json.getIntField(F.total),
          score: json.getIntField(F.score),
          ranks: List<Rank>.from(
            json.getMapList(F.ranks).map((x) => Rank.fromJson(x)),
          ),
          index: json.getIntField(F.index),
          wins: json.getIntField(F.wins),
          loses: json.getIntField(F.loses),
          correct: json.getStringField(F.correct) ?? T.rhino,
          guesses: json.getStringList(
            F.guesses,
            defValue: AppConfigs.initGuesses,
          ),
          history: GameHistory.getList(json, F.history),
          bgImage: json.getBoolField(F.bgImage, defValue: true),
          bgSound: json.getBoolField(F.bgSound, defValue: true),
          effectSound: json.getBoolField(F.effectSound, defValue: true),
          id: json.getStringField(F.id),
          userName: json.getStringField(F.userName),
          createdAt: json.getDateTimeField(F.createdAt),
          updatedAt: json.getDateTimeField(F.updatedAt),
          authToken: json.getStringField(F.authToken),
        );

  Json get userSettings => {
        F.index: index,
        F.wins: wins,
        F.loses: loses,
        F.correct: correct,
        F.guesses: guesses,
        F.history: history,
        F.bgImage: bgImage,
        F.bgSound: bgSound,
        F.effectSound: effectSound,
      };

  Rank? get rank => ranks.firstWhereOrNull((e) => e.id == id);
}
