import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:pishgaman/consts/t.dart';

void hideKeyboard() {
  Get.focusScope?.unfocus();
}

void showInfo(String text) => EasyLoading.showInfo(text,
    maskType: EasyLoadingMaskType.black, dismissOnTap: true);
void showError(String? text) => EasyLoading.showError(text ?? T.unknownError,
    maskType: EasyLoadingMaskType.black, dismissOnTap: true);

void showLoading([String status = T.loading]) =>
    EasyLoading.show(status: status, maskType: EasyLoadingMaskType.custom);
void hideLoading() => EasyLoading.dismiss();

void showErrors(List<String> errors) {
  if (errors.isEmpty) return;
  if (errors.length == 1) {
    EasyLoading.showError(errors.first,
        duration: 13.seconds,
        dismissOnTap: true,
        maskType: EasyLoadingMaskType.custom);
  } else {
    String msg = "";
    for (int i = 0; i < errors.length; i++) {
      msg += "[${i + 1}] ${errors[i]}\n";
    }
    EasyLoading.showError(msg,
        duration: 13.seconds,
        dismissOnTap: true,
        maskType: EasyLoadingMaskType.custom);
  }
}

extension ColorEx on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .25]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight =
        hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}
