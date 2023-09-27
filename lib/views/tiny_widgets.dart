import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';

import '../consts/t.dart';
import '../db/types.dart';
import '../utils/app_colors.dart';
import 'gen_button.dart';

class ZeroWidget extends StatelessWidget {
  const ZeroWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

Future<bool?> askQuestion(String question, {String title = T.question}) async {
  await EasyLoading.dismiss(animation: true);
  return showCupertinoDialog<bool>(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text(question),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  T.yes,
                  style: TextStyle(
                      color: AppColors.success, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Get.back(result: true);
                },
              ),
              TextButton(
                child: Text(
                  T.no,
                  style: TextStyle(
                      color: AppColors.accent, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Get.back(result: false);
                },
              ),
            ],
          ));
}

class ButtonProgress extends StatelessWidget {
  final bool dark;
  const ButtonProgress({Key? key, this.dark = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 25,
      height: 25,
      child: CircularProgressIndicator(
        valueColor:
            AlwaysStoppedAnimation<Color>(dark ? Colors.white : Colors.black),
        strokeWidth: 2,
      ),
    );
  }
}

class AppController {
  final Json _data = {};
  final State? state;

  AppController(this.state, {Json init = const {}});

  T? getValue<T>(String key, {T? defValue}) =>
      _data.containsKey(key) ? _data[key] as T : defValue;
  void setValue<T>(String key, T value) {
    if (!state!.mounted) return;
    // ignore: invalid_use_of_protected_member
    state?.setState(() {
      _data[key] = value;
    });
  }
}

class GrayBox extends StatelessWidget {
  final double? width;
  final double? height;
  final double? borderRadius;
  final Color? color;
  const GrayBox(
      {Key? key, this.width, this.height, this.borderRadius, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? 200,
      height: height ?? 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? 16),
        color: (color ?? AppColors.grey2).withAlpha(70),
      ),
    );
  }
}

class AppBackButton extends StatelessWidget {
  final Color? color;
  const AppBackButton({Key? key, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GenButton(
      rightIcon: true,
      icon: Icons.chevron_right,
      color: color ?? AppColors.grey2,
      title: T.back,
      onPressed: Get.back,
    );
  }
}
