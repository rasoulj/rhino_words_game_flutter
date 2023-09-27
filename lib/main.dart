import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:pishgaman/consts/app_configs.dart';
import 'package:pishgaman/db/sembast_db.dart';
import 'package:pishgaman/models/app_settings.dart';
import 'package:pishgaman/utils/app_colors.dart';
import 'package:pishgaman/utils/app_sounds.dart';
import 'package:pishgaman/utils/debug.dart';
import 'package:pishgaman/utils/etc.dart';
import 'package:pishgaman/views/game_pallet.dart';
import 'package:tapsell_plus/tapsell_plus.dart';

Future<void> initSetup() async {
  SembastDb? db = await SembastDb.init();

  AppSettings.getStream(db)?.listen((AppSettings settings) {
    debug("AppSettings: ${settings.bgSound}");
    if (settings.bgSound) {
      AppSounds.i.playBgSound();
    } else {
      AppSounds.i.pause();
    }
  });
}

Future<void> initTapSell() async {
  try {
    await TapsellPlus.instance.initialize(TapsellIds.appId);
    await TapsellPlus.instance.setGDPRConsent(true);
  } catch (e) {
    showError(e.toString());
  }
}

void initEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = AppColors.accent.withOpacity(0.5)
    ..userInteractions = true
    ..errorWidget = Icon(
      Icons.error,
      color: AppColors.accent,
      size: 32,
    )
    ..dismissOnTap = false;
  // ..customAnimation = CustomAnimation();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initSetup();

  initEasyLoading();

  // await initTapSell();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      builder: EasyLoading.init(),
      localizationsDelegates: const [
        GlobalCupertinoLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale("fa", "IR"), // OR Locale('ar', 'AE') OR Other RTL locales
      ],
      locale: const Locale("fa", "IR"),
      title: '',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "iransans",
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: FutureBuilder(
        future: SembastDb.init(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var db = snapshot.data;
            return StreamBuilder<AppSettings>(
              initialData: const AppSettings(),
              stream: AppSettings.getStream(db),
              builder: (_, ss) {
                AppSettings? settings =
                    ss.hasData ? ss.data : const AppSettings();
                return GamePallet(
                  settings: settings,
                  db: snapshot.data,
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Icon(Icons.error_outline);
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
      onInit: () {
        
      },
    );
  }
}
