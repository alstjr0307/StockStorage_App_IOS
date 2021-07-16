
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

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
  await MobileAds.instance.initialize();
  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(MyApp());
}
class MyApp extends StatelessWidget {

  // This widget is the root of your application.
  ThemeMode themeMode = ThemeMode.light;

  var paddingBottom = 50.0;

  @override
  Widget build(BuildContext context) {
    TargetPlatform os = Theme.of(context).platform;

    BannerAd banner = BannerAd(
      listener: BannerAdListener(
        onAdFailedToLoad: (Ad ad, LoadAdError error) {},
        onAdLoaded: (_) {},
      ),
      size: AdSize.banner,
      adUnitId: UNIT_ID[ os== TargetPlatform.iOS ? 'ios' : 'android']!,
      request: AdRequest(),
    )..load();
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
          fontFamily: 'Hanma'
      ).toTheme,
      themeMode:  themeMode,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      builder: (context, widget) {

        final mediaQuery = MediaQuery.of(context);
        return new Padding(
          child: widget,
          padding: new EdgeInsets.only(bottom: paddingBottom),
        );
      },
    );
  }
}