import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pishgaman/consts/app_configs.dart';

enum MatchEnum {
  none,
  exist,
  perfect,
  empty,
}

Iterable<MatchEnum> listMatchEnum(String str) sync* {
  for (var c in str.characters) {
    if (c == "E") {
      yield MatchEnum.exist;
    } else if (c == "N") {
      yield MatchEnum.none;
    } else if (c == "P") {
      yield MatchEnum.perfect;
    } else {
      yield MatchEnum.empty;
    }
  }
}

extension MatchEnumEx on MatchEnum {
  Color get color {
    switch (this) {
      case MatchEnum.none:
        return Colors.redAccent;
      case MatchEnum.exist:
        return CupertinoColors.activeOrange;
      case MatchEnum.perfect:
        return CupertinoColors.activeGreen;
      case MatchEnum.empty:
        return Colors.grey[300]!;
    }
  }
}

List<MatchEnum> match(String correct, String suggest) {
  int len = correct.length;

  if (len != suggest.length) {
    return List.generate(len, (index) => MatchEnum.empty);
  }

  List<MatchEnum> m = List.generate(len, (index) => MatchEnum.none);

  List<String> cor2 = List.generate(len, (index) => correct[index]).toList();

  String cor3 = cor2.join();

  for (int i = 0; i < len; i++) {
    if (i < correct.length) {
      if (correct[i] == suggest[i]) {
        m[i] = MatchEnum.perfect;
        cor2[i] = "|";
      }
    }
  }

  for (int i = 0; i < len; i++) {
    if (m[i] == MatchEnum.none) {
      int fi = cor2.indexOf(suggest[i]);
      if (fi >= 0) {
        m[i] = MatchEnum.exist;
        cor2[fi] = "|";
      }
    }
    cor3 = cor2.join();
  }

  return m;
}

MatchEnum overallStatus(List<String> guesses, String correct, int index) {
  for (String suggest in guesses) {
    var m = match(correct, suggest);
    var solved = m.where((e) => e != MatchEnum.perfect).isEmpty;
    if (solved) return MatchEnum.perfect;
  }
//Configs.maxTry
  return index < AppConfigs.maxTry ? MatchEnum.empty : MatchEnum.none;
}
