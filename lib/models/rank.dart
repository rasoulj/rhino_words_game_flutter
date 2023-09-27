import 'dart:convert';

import '../db/types.dart';
import '../consts/f.dart';

class Rank {
  Rank({
    this.id,
    this.wins = 0,
    this.loses = 0,
    this.userName = "NA",
    this.score = 0,
    this.rank = 0,
  });

  final String? id;
  final int wins;
  final int loses;
  final String userName;
  final int score;
  final int rank;

  factory Rank.fromRawJson(String str) => Rank.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Rank.fromJson(Map<String, dynamic> json) => Rank(
        id: json.getStringField(F.id),
        wins: json.getIntField(F.wins),
        loses: json.getIntField(F.loses),
        userName: json.getStringField(F.userName) ?? "NA",
        score: json.getIntField(F.score),
        rank: json.getIntField(F.rank),
      );

  Map<String, dynamic> toJson() => {
        F.id: id,
        F.wins: wins,
        F.loses: loses,
        F.userName: userName,
        F.score: score,
        F.rank: rank,
      };
}
