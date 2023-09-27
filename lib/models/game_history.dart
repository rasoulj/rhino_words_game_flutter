import 'dart:convert';

import 'package:pishgaman/consts/f.dart';
import 'package:pishgaman/db/types.dart';

class GameHistory {
  final String correct;
  final List<String> guesses;
  final DateTime playedAt;

  GameHistory({
    required this.correct,
    required this.guesses,
    required this.playedAt,
  });

  factory GameHistory.fromRawJson(String str) =>
      GameHistory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory GameHistory.fromJson(Json json) => GameHistory(
        correct: json[F.correct],
        guesses: List<String>.from(json[F.guesses].map((x) => x)),
        playedAt: DateTime.parse(json[F.playedAt]),
      );

  Map<String, dynamic> toJson() => {
        F.correct: correct,
        F.guesses: List<dynamic>.from(guesses.map((x) => x)),
        F.playedAt: playedAt.toIso8601String(),
      };

  static List<GameHistory> getList(Json? map, String key) {
    if (map == null) return [];
    List p = map[key] ?? [];
    List<GameHistory> q = p.map((e) => GameHistory.fromJson(e)).toList();
    return q;
  }
}
