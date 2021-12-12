
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/dropdown_alert.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:kakao_flutter_sdk/all.dart';

import 'Homepage.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}
const Map<String, String> UNIT_ID = kReleaseMode
    ? {
  'ios': 'ca-app-pub-6925657557995580/7108082955',
  'android': 'ca-app-pub-6925657557995580/7753030928',
}
    : {
  'ios': 'ca-app-pub-3940256099942544/2934735716',
  'android': 'ca-app-pub-3940256099942544/6300978111',
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  KakaoContext.clientId = "96a3a0f35c7663fd62bf9870fd20e434";
  KakaoContext.javascriptClientId = "60a803fedcf53b21f91dcd17a7cc39f9";
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  ThemeMode themeMode = ThemeMode.light;
  static FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

  var paddingBottom = 50.0;

  @override
  Widget build(BuildContext context) {
    TargetPlatform os = Theme.of(context).platform;
    const FlexScheme usedFlexScheme = FlexScheme.barossa;
    return MaterialApp(

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        // if it's a RTL language
      ],
      supportedLocales: [
        const Locale('ko', 'KR'),
        // include country code too
      ],
      title: 'Flutter Demo',
      theme:FlexColorScheme.light(

          scheme: usedFlexScheme,
          visualDensity: FlexColorScheme.comfortablePlatformDensity,
          fontFamily: 'Nanum'
      ).toTheme,
      themeMode:  themeMode,
      debugShowCheckedModeBanner: false,
      navigatorObservers: <NavigatorObserver>[observer],
      home: HomePage(),
      builder: (context, child) => Stack(
        children: [

          child!,
          DropdownAlert(position: AlertPosition.BOTTOM,)
        ],
      ),
    );
  }
}