import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kakao_flutter_sdk/all.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Diary.dart';
import 'Profile.dart';
import 'Recommend.dart';
import 'TOFU.dart';
import 'alarm.dart';
import 'changenickname.dart';
import 'domesticPost.dart';
import 'kakaologin.dart';

const int maxFailedLoadAttempts = 3;


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseAnalytics analytics = FirebaseAnalytics();

class _HomePageState extends State<HomePage> {
  late FirebaseMessaging messaging;
  RewardedAd? _rewardedAd;
  int _numRewardedLoadAttempts = 0;
  InterstitialAd? _interstitialAd;
  int _numInterstitialLoadAttempts = 0;
  int _rewardPoints = 0;
  int flag = 0;
  InterstitialAd? _alarmAd;
  final dio = new Dio();
  var token;
  var username;
  var sharedPreferences;
  var userid;

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      username = sharedPreferences.getString("nickname");
      token = sharedPreferences.getString("token");
      userid = sharedPreferences.getInt("userID");
    }
  }

  Future logAppOpen() async {
    await analytics.logAppOpen();
  } //앱 켰을때 로그 남기기

  Future<void> _signInAnonymously() async {
    if (FirebaseAuth.instance.currentUser == null) {
      try {
        await FirebaseAuth.instance.signInAnonymously();
        await FirebaseFirestore.instance
            .collection(auth.currentUser!.uid)
            .doc('매매일지')
            .set({});
        await FirebaseFirestore.instance
            .collection(auth.currentUser!.uid)
            .doc('추천주 기록')
            .set({});
      } catch (e) {}
    }
    analytics.setUserProperty(name: 'name', value: auth.currentUser!.uid);
  }

  String msg = '.';
  bool _isKakaoTalkInstalled = false;

  _initKakaoTalkInstalled() async {
    final installed = await isKakaoTalkInstalled();

    setState(() {
      _isKakaoTalkInstalled = installed;
    });
  }

  _issueAccessToken(String authCode) async {
    try {
      var token = await AuthApi.instance.issueAccessToken(authCode);
      AccessTokenStore.instance.toStore(token);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LoginResult(),
          ));
    } catch (e) {
      print(e.toString());
    }
  }

  _loginWithKakao() async {

    try {
      var code = await AuthCodeClient.instance.request();
      await _issueAccessToken(code);

    } catch (e) {

    }
  }

  _loginWithTalk() async {

    try {
      var code = await AuthCodeClient.instance.requestWithTalk();
      await _issueAccessToken(code);
    } catch (e) {}
  }

  Future homelog() async {
    await analytics.setCurrentScreen(
      screenName: '홈',
      screenClassOverride: 'home',
    );
  } //앱

  Future recommendlog() async {
    await analytics.logEvent(
      name: '추천주 광고',
    );
  } //앱
  late BannerAd banner;
  final String iOSTestId = 'ca-app-pub-6925657557995580/2558727180';
  final String androidTestId = 'ca-app-pub-6925657557995580/7753030928';

  @override
  void initState() {
    super.initState();
    String kakaoAppKey = "fb748431210dc9c7f46b48631a08d670";
    _initKakaoTalkInstalled();
    KakaoContext.clientId = kakaoAppKey;
    _createInterstitialAd();
    checkLoginStatus();
    logAppOpen();
    _signInAnonymously();
    _initRewardedVideoAdListener();

    messaging = FirebaseMessaging.instance;

    if (Platform.isIOS) {
      messaging.requestPermission(sound: true,badge:true,alert:true);

    }
    messaging.getToken().then((value) async {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("pushtoken", value);


    });
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      sharedPreferences.setString('commentnoti', event.data['body']);
      AlertController.show(
        event.data['title'],
        event.data['body'],
        TypeAlert.success,
      );
    });

    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      AlertController.show(
        message.data['title'],
        message.data['body'],
        TypeAlert.success,
      );
    });
  }
  Widget CustomDrawer() {
    return Drawer(
      // 리스트뷰 추가
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          // 드로워해더 추가
          Container(
            height: 500,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(255, 210, 138, 1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (username == null)
                      Row(
                        children: [
                          Text(
                            '비회원',
                            style: TextStyle(
                                fontFamily: 'gyeongi',
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Container(
                            child: Text(
                              username,
                              style: TextStyle(
                                  fontFamily: 'gyeongi',
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          FutureBuilder(
                            builder: (context, snapshot) {
                              final restaurant = snapshot.data as Map;
                              if (snapshot.hasData) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ' | 게시물 ' + restaurant['post'].toString(),
                                      style: TextStyle(
                                          fontSize: 13, fontFamily: 'Strong'),
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      ' | 댓글 ' +
                                          restaurant['comment'].toString(),
                                      style: TextStyle(
                                          fontSize: 13, fontFamily: 'Strong'),
                                    )
                                  ],
                                );
                              } else {
                                return CircularProgressIndicator(
                                  color: Colors.red,
                                );
                              }
                            },
                            future: getProfile(),
                          ),
                        ],
                      ),

                    SizedBox(
                      height: 20,
                    ),
                    if (username == null)
                      TextButton(
                        child: Container(
                          padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            shape: BoxShape.rectangle,
                            border: Border.all(width: 1.0, color: Colors.white),
                            borderRadius:
                            BorderRadius.all(Radius.circular(30.0)),
                          ),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              "로그인",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                        onPressed: () {

                          if (_isKakaoTalkInstalled)
                            _loginWithTalk();
                          else
                            _loginWithKakao();
                        },
                      ),
                    if (username != null)
                      Column(
                        children: [
                          RaisedButton(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => MyProfile()));
                            },
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(80.0)),
                            padding: EdgeInsets.all(0.0),
                            child: Ink(
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xff374ABE),
                                      Color(0xff64B6FF)
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  borderRadius: BorderRadius.circular(30.0)),
                              child: Container(
                                constraints: BoxConstraints(
                                    maxWidth: 250.0, minHeight: 50.0),
                                alignment: Alignment.center,
                                child: Text(
                                  "내 프로필",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontFamily: 'Strong'),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 50,
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size(50, 30),
                                alignment: Alignment.centerLeft),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => ChangeNickname()));
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.rectangle,
                                border:
                                Border.all(width: 1.0, color: Colors.white),
                                borderRadius:
                                BorderRadius.all(Radius.circular(30.0)),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "닉네임 변경",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size(50, 30),
                              alignment: Alignment.centerLeft,
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return Dialog(
                                    child: Container(
                                      padding:
                                      EdgeInsets.fromLTRB(10, 20, 10, 20),
                                      child: new Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          new CircularProgressIndicator(),
                                          SizedBox(
                                            width: 20,
                                          ),
                                          new Text("로그아웃중"),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                              sharedPreferences.clear();
                              sharedPreferences.commit();
                              username = null;

                              new Future.delayed(new Duration(seconds: 1), () {
                                //pop dialog
                                setState(() {});
                                Navigator.pop(context);
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              margin: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                color: FlexColor.redLightPrimary,
                                shape: BoxShape.rectangle,
                                border:
                                Border.all(width: 1.0, color: Colors.white),
                                borderRadius:
                                BorderRadius.all(Radius.circular(20.0)),
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  "로그아웃",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    //프로필 가기
                  ],
                ),
              ),
            ),
          ),
          // 리스트타일 추가
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    TargetPlatform os = Theme.of(context).platform;
    if (flag == 1)
      return Scaffold(
        drawer: CustomDrawer(),
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black, size: 40),
          backgroundColor: Color.fromRGBO(240, 175, 142, 100),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Alarm(),
                    ),
                  );
                },
                icon: Image.asset("assets/images/bell.png"))
          ],
        ),
        body: Container(
          color: Color.fromRGBO(240, 175, 142, 100),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Title(),
              toron(),
              maemae(),
              recommend(),
              tofu(),
              info(),
            ],
          ),
        ),
      );
    else
      return Scaffold(
        backgroundColor: Color.fromRGBO(240, 175, 142, 100),
        body: Center(
          child: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 30),
                Text(
                  '로딩중입니다',
                ),
              ],
            ),
          ),
        ),
      );
  }

  Widget Title() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      child: Center(
        child: Container(
            height: 100,
            child:
            Image.asset('assets/images/title.png', fit: BoxFit.fitHeight)),
      ),
    );
  }

  Widget maemae() {
    return Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color.fromRGBO(255, 142, 122, 100),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Diary(),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.calendar_today,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '매매일지',
                    style: TextStyle(
                        fontFamily: 'Strong',
                        fontSize: 30,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget recommend() {
    return Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color.fromRGBO(255, 142, 122, 100),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Recommend(),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.stacked_line_chart,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '추천주 기록',
                    style: TextStyle(
                        fontFamily: 'Strong',
                        fontSize: 30,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget tofu() {
    return Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.black,
            child: InkWell(
              onTap: () {
                _showRewardedAd();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Tofu(),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      child: InkWell(
                        child: Image.asset(
                          "assets/images/unnamed.png",
                          scale: 4,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '두부개미 추천주',
                    style: TextStyle(
                        fontFamily: 'Strong', fontSize: 30, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget info() {
    return Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Colors.black,
            child: InkWell(
              onTap: () {
                _showInterstitialAd();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Info(category: 'd'),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        child: Icon(
                          Icons.info_rounded,
                          size: 30,
                          color: Colors.white,
                        )),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '주식 정보글',
                    style: TextStyle(
                        fontFamily: 'Strong', fontSize: 30, color: Colors.red),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget toron() {
    return Container(
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Card(
            color: Color.fromRGBO(255, 142, 122, 100),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Info(category: 'f'),
                  ),
                );
              },
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: InkWell(
                        child: Icon(
                          Icons.chat,
                          size: 40,
                          color: Colors.white,
                        )),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '주식 토론방',
                    style: TextStyle(
                        fontFamily: 'Strong',
                        fontSize: 30,
                        color: Colors.black),
                  ),
                ],
              ),
            ),
          ),
        ));
  }
  void _createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-6925657557995580/1082828139',
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
          },
          onAdFailedToLoad: (LoadAdError error) {
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts <= maxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  void _showInterstitialAd() {
    if (_interstitialAd == null) {
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }


  void _showRewardedAd() {
    if (_rewardedAd == null) {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Tofu(),
        ),
      );
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {
        Navigator.pop(context);
      },
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _initRewardedVideoAdListener();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        Navigator.pop(context);

        ad.dispose();
        _initRewardedVideoAdListener();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      setState(() {
        // Video ad should be finish to get the reward amount.
        _rewardPoints += reward.amount.toInt();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Tofu(),
          ),
        );
      });
    });
    _rewardedAd = null;

    //RewardedVideoAdEvent must be loaded to show video ad thus we check and show it via listener
    //Tip: You chould show a loading spinner while waiting it to be loaded.

    //TODO: replace it with your own Admob Rewarded ID
  }

  void _initRewardedVideoAdListener() {
    RewardedAd.load(
      adUnitId: 'ca-app-pub-6925657557995580/8769746460',
      request: AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _numRewardedLoadAttempts = 0;
          flag = 1;
          setState(() {});
        },
        onAdFailedToLoad: (LoadAdError error) {
          _rewardedAd = null;
          _numRewardedLoadAttempts += 1;
          flag = 1;
          print('flag'+ flag.toString());
          setState(() {});
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {

            _initRewardedVideoAdListener();
          }
        },
      ),
    );
  }
  Future<Map> getProfile() async {
    var profileurl =
        'http://13.125.62.90/api/v1/AuthUser/${userid.toString()}/';

    final responseall = await dio.get(profileurl,
        options: Options(headers: {"Authorization": "Token $token"}));

    Map profile = responseall.data;

    return profile;
  }

}
