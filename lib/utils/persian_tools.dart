//RegExp _persianExp = RegExp(r"[پچجحخهعغفقثصضشسیبلاتنمکگوئدذرزطظژؤإأءًٌٍَُِّ]+");
import 'package:flutter/material.dart';

const String persianChars = "آپچجحخهعغفقثصضشسیبلاتنمکگوئدذرزطظژؤإأءًٌٍَُِّ";

String removeNonPersians(String str) {
  if(str.isEmpty) return "";
  String last = str.characters.last;

  return persianChars.contains(last) ? str : str.substring(0, str.length-1);
}
