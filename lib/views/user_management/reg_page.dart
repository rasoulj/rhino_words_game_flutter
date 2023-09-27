import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../consts/f.dart';
import '../../consts/t.dart';
import '../../db/sembast_db.dart';
import '../../models/app_settings.dart';
import '../../models/login_result.dart';
import '../../models/rest_response.dart';
import '../../utils/app_colors.dart';
import '../../utils/etc.dart';
import '../../utils/rest_api.dart';
import '../gen_button.dart';
import '../input_ex.dart';
import '../tiny_widgets.dart';

class RegPage extends StatefulWidget {
  final SembastDb? db;
  final AppSettings? settings;

  const RegPage({Key? key, required this.db, required this.settings}) : super(key: key);

  @override
  State<RegPage> createState() => _RegPageState();
}

class _RegPageState extends State<RegPage> {

  AppController? _c;
  @override
  void initState() {
    _c = AppController(this);
    userName = "";
    super.initState();
  }

  String get userName => _c?.getValue(F.userName) ?? "";
  set userName(String value) => _c?.setValue(F.userName, value);

  String get password => _c?.getValue(F.password) ?? "";
  set password(String value) => _c?.setValue(F.password, value);

  String get verifyPassword => _c?.getValue(F.verifyPassword) ?? "";
  set verifyPassword(String value) => _c?.setValue(F.verifyPassword, value);


  bool get loading => _c?.getValue(F.loading) ?? false;
  set loading(bool value) => _c?.setValue(F.loading, value);

  void doRegister() async {
    try {
      var errs = <String>[];
      if(userName.length < 5) errs.add(T.errorUserName);
      if(password.length < 5) {
        errs.add(T.errorPassword);
      } else if(password != verifyPassword) {
        errs.add(T.errorVerifyPassword);
      }

      if(errs.isNotEmpty) {
        showErrors(errs);
        return;
      }

      await AppSettings.clearSetting(widget.db);

      loading = true;
      ApiResponse<LoginResult> result = await RestApi.register(userName, password, widget.settings);
      loading = false;
      if(!result.ok) {
        showError(result.message);
        return;
      }

      await AppSettings.saveJsonSetting(widget.db, null, result.data?.update);
      await AppSettings.saveJsonSetting(widget.db, null, result.data?.user);
      await AppSettings.saveSetting(widget.db, null, authToken: result.data?.authToken);

      Get.back();
    } catch(e) {
      showError(e.toString());
    }
  }


  // final TextEditingController _userName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        children: [
          InputEx(
            hintText: T.userName,
            controller: _c,
            field: F.userName,
          ),
          InputEx(
            isPassword: true,
            hintText: T.password,
            controller: _c,
            field: F.password,
          ),
          InputEx(
            isPassword: true,
            hintText: T.verifyPassword,
            controller: _c,
            field: F.verifyPassword,
          ),
          const SizedBox(height: 40,),
          GenButton(
            loading: loading,
            icon: Icons.person_add,
            title: T.register,
            onPressed: doRegister,
          ),
          const SizedBox(height: 10,),
          AppBackButton(color: AppColors.accent.lighten(0.1),),
        ],
      ),
    );
  }
}
