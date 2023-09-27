import 'package:flutter/material.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/utils/app_colors.dart';
import 'package:tab_container/tab_container.dart';

import '../../consts/t.dart';
import 'log_page.dart';
import 'reg_page.dart';

class LoginRegPage extends StatelessWidget {
  final SembastDb? db;
  final AppSettings? settings;

  const LoginRegPage({Key? key, required this.db, required this.settings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Scaffold(
        body: TabContainer(
          colors: [
            AppColors.success.withOpacity(0.7),
            AppColors.accent.withOpacity(0.8),
          ],
          // color: AppColors.accent,
          children: [
            LogPage(
              db: db,
              settings: settings,
            ),
            RegPage(
              db: db,
              settings: settings,
            ),
          ],
          tabs: const [
            T.logUser,
            T.regUser,
            // 'Tab 3',
          ],
        ),
      ),
    );
  }
}
