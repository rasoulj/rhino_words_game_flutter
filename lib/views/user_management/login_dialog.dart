import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/utils/app_colors.dart';
import 'package:pishgaman/views/tiny_widgets.dart';

import '../../consts/t.dart';

Future<bool?> openLoginReg(SembastDb? db) async {
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
                        //Widgets goes here
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
