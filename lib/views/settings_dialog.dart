import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/utils/app_colors.dart';
import 'package:pishgaman/utils/etc.dart';
import 'package:pishgaman/views/gen_button.dart';
import 'package:pishgaman/views/tiny_widgets.dart';
import 'package:pishgaman/views/user_management/login_reg.dart';

import '../consts/t.dart';

Future<bool?> openSettings(SembastDb? db) async {
  return await showCupertinoModalPopup<bool>(
      context: Get.context!,
      filter: ImageFilter.blur(),
      builder: (BuildContext context) {
        return Container(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<AppSettings>(
                stream: AppSettings.getStream(db),
                builder: (context, snapshot) {
                  AppSettings? settings = snapshot.data;
                  bool logged = settings?.logged ?? false;
                  return Material(
                    color: Colors.transparent,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Get.back(result: false),
                              icon: Icon(
                                Icons.close,
                                color: AppColors.accent,
                              ),
                            ),
                            const Text(
                              T.settings,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const ZeroWidget(),
                          ],
                        ),
                        SwitchListTile(
                          dense: true,
                          title: const Text(T.bgSound),
                          activeColor: AppColors.success,
                          onChanged: (bool value) {
                            AppSettings.saveSetting(db, settings?.authToken,
                                bgSound: value);
                          },
                          value: settings?.bgSound ?? true,
                        ),
                        SwitchListTile(
                          dense: true,
                          title: const Text(T.effectSound),
                          activeColor: AppColors.success,
                          onChanged: (bool value) {
                            AppSettings.saveSetting(db, settings?.authToken,
                                effectSound: value);
                          },
                          value: settings?.effectSound ?? true,
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        if (logged)
                          GenButton(
                            color: AppColors.accent.darken(),
                            onPressed: () async {
                              bool? res = await askQuestion(T.logoutConfirm);
                              if (res ?? false) {
                                await AppSettings.logout(db);
                                Get.back();
                              }
                            },
                            title: T.logout,
                          ),
                        if (!logged)
                          GenButton(
                            color: AppColors.success.darken(),
                            onPressed: () {
                              Get.back();
                              Get.to(() =>
                                  LoginRegPage(db: db, settings: settings));
                            },
                            title: T.loginFull,
                          ),
                      ],
                    ),
                  );
                }),
          ),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(35)),
            color: Colors.white.withAlpha(220),
          ),
          height: Get.height / 2,
          width: Get.width,
        );
      });
}
