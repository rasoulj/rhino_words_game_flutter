import 'package:flutter/material.dart';
import 'package:pishgaman/models/match_enum.dart';
import 'package:pishgaman/utils/etc.dart';

abstract class AppColors {
  static final Color accent = MatchEnum.none.color;
  static final Color success = MatchEnum.perfect.color;
  static final Color empty = MatchEnum.empty.color.darken(0.3);

  static const Color white = Color(0xffffffff);
  static const Color black = Color(0xff2b2b2b);
  static const Color black2 = Color(0x80181818);
  static const Color black3 = Color(0xff1f1f1f);
  static const Color grey1 = Color(0xffc2c2c2);
  static const Color grey2 = Color(0xffb2b2b2);

  static bool isDark(Color c) {
    var grayScale = (0.299 * c.red) + (0.587 * c.green) + (0.114 * c.blue);
    return grayScale < 128;
  }
}
