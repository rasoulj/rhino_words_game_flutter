// To parse this JSON data, do
//
//     final loginResult = loginResultFromJson(jsonString);

import 'dart:convert';

import 'package:pishgaman/db/types.dart';

import '../consts/f.dart';

class LoginResult {
  LoginResult({
    this.update,
    this.user,
    this.authToken,
  });

  final Json? update;
  final Json? user;
  final String? authToken;

  factory LoginResult.fromRawJson(String str) =>
      LoginResult.fromJson(json.decode(str));

  // String toRawJson() => json.encode(toJson());

  factory LoginResult.fromJson(Map<String, dynamic> json) => LoginResult(
        update: Json.from(json[F.update] ?? {}),
        user: Json.from(json[F.user] ?? {}),
        authToken: json.getStringField(F.authToken),
      );

  // Map<String, dynamic> toJson() => {
  //       "update": update,
  //       "user": user,
  //       "authToken": authToken,
  //     };
}

// class Update {
//   Update({
//     this.wins = 0,
//     this.loses = 0,
//     this.winsScore = 5,
//     this.loseScore = 1,
//     this.total = 0,
//     this.score = 0,
//     this.ranks = const [],
//   });
//
//   final int wins;
//   final int loses;
//   final int winsScore;
//   final int loseScore;
//   final int total;
//   final int score;
//   final List<Rank> ranks;
//
//   factory Update.fromRawJson(String str) => Update.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory Update.fromJson(Map<String, dynamic> json) => Update(
//     wins: getIntField(json, "wins"),
//     loses: getIntField(json, "loses"),
//     winsScore: getIntField(json, "winsScore"),
//     loseScore: getIntField(json, "loseScore"),
//     total: getIntField(json, "total"),
//     score: getIntField(json, "score"),
//     ranks: List<Rank>.from(json["ranks"].map((x) => Rank.fromJson(x))),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "wins": wins,
//     "loses": loses,
//     "winsScore": winsScore,
//     "loseScore": loseScore,
//     "total": total,
//     "score": score,
//     "ranks": List<dynamic>.from(ranks.map((x) => x.toJson())),
//   };
// }


// class User {
//   User({
//     this.id,
//     this.wins = 0,
//     this.loses = 0,
//     this.index = 0,
//     this.guesses = const [],
//     this.bgSound = true,
//     this.effectSound = true,
//     this.correct = T.rhino,
//     this.userName = "NA",
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   final String? id;
//   final int wins;
//   final int loses;
//   final int index;
//   final List<String> guesses;
//   final bool bgSound;
//   final bool effectSound;
//   final String correct;
//   final String userName;
//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//
//   factory User.fromRawJson(String str) => User.fromJson(json.decode(str));
//
//   String toRawJson() => json.encode(toJson());
//
//   factory User.fromJson(Map<String, dynamic> json) => User(
//     id: json["_id"],
//     wins: getIntField(json, "wins"),
//     loses: getIntField(json, "loses"),
//     index: getIntField(json, "index"),
//     guesses: getStringList(json, "guesses", defValue: AppConfigs.initGuesses),
//     bgSound: getBoolField(json, "bgSound", defValue: true),
//     effectSound: getBoolField(json, "effectSound", defValue: true),
//     correct: getStringField(json, "correct", defValue: T.rhino) ?? T.rhino,
//     userName: json["userName"],
//     createdAt: DateTime.parse(json["createdAt"]),
//     updatedAt: DateTime.parse(json["updatedAt"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "_id": id,
//     "wins": wins,
//     "loses": loses,
//     "index": index,
//     "guesses": List<dynamic>.from(guesses.map((x) => x)),
//     "bgSound": bgSound,
//     "effectSound": effectSound,
//     "correct": correct,
//     "userName": userName,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//   };
// }
