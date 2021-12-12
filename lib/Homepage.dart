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
import 'package:the_apple_sign_in/apple_sign_in_button.dart' as ABT;
import 'package:the_apple_sign_in/the_apple_sign_in.dart';
import 'package:url_launcher/url_launcher.dart';
import 'BlockedUser.dart';
import 'Diary.dart';
import 'Profile.dart';
import 'Recommend.dart';
import 'TOFU.dart';
import 'Tagpost.dart';
import 'alarm.dart';
import 'allDetail.dart';
import 'applelogin.dart';
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
    print(sharedPreferences.getString("token"));
    if (sharedPreferences.getStringList("blockid") == null) {
      sharedPreferences.setStringList("blockid", [""]);
    }
    if (sharedPreferences.getString("token") != null) {
      username = sharedPreferences.getString("nickname");
      token = sharedPreferences.getString("token");
      userid = sharedPreferences.getInt("userID");
    }
  }

  void customLaunch(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    } else {
      print(' could not launch $command');
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
          CupertinoPageRoute(
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
    } catch (e) {}
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
      messaging.requestPermission(sound: true, badge: true, alert: true);
    }
    messaging.getToken().then((value) async {
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setString("pushtoken", value);
      print(value);
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
      child: Column(
        children: <Widget>[
          // 드로워해더 추가
          Expanded(
            flex: 6,
            child: Container(
              child: DrawerHeader(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(72, 149, 73, 0.6),
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

                                if (snapshot.hasData) {

                                  final restaurant = snapshot.data as Map;
                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ' | 게시물 ' +
                                            restaurant['post'].toString(),
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
                        Column(
                          children: [
                            TextButton(
                              child: Container(
                                padding: EdgeInsets.fromLTRB(3, 5, 3, 5),
                                decoration: BoxDecoration(
                                  color: Colors.yellow,
                                  shape: BoxShape.rectangle,
                                  border: Border.all(
                                      width: 1.0, color: Colors.white),
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Text(
                                    "카카오 로그인",
                                    style: TextStyle(
                                      color: Colors.black,
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
                            ABT.AppleSignInButton(
                              style: ABT.ButtonStyle.black,
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => AppleLogin()));
                              },
                            ),
                          ],
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
                                        Color.fromRGBO(0, 82, 33, 1),
                                        Color.fromRGBO(185, 204, 179, 1)
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
                                    "프로필 더보기",
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
                                  border: Border.all(
                                      width: 1.0, color: Colors.white),
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

                                new Future.delayed(new Duration(seconds: 1),
                                    () {
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
                                  border: Border.all(
                                      width: 1.0, color: Colors.white),
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
          ),
          Expanded(
            flex: 4,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => BlockedUser()));
                  },
                  child: Container(
                    padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                      color: FlexColor.redLightPrimary,
                      shape: BoxShape.rectangle,
                      border: Border.all(width: 1.0, color: Colors.white),
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                    ),
                    child: Container(
                      height: 20,
                      width: 250,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.block, color: Colors.red),
                          Text(
                            "차단한 사용자 보러가기",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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

    Widget menu() {
      return Card(
        elevation: 10,
        child: Container(
          child: GridView.count(
            crossAxisCount: 3,
            childAspectRatio: 1,
            controller: new ScrollController(keepScrollOffset: false),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            children: [
              RawMaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Info(category: 'f'),
                    ),
                  );
                },
                shape: CircleBorder(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        child: Icon(
                          Icons.chat,
                          size: 40,
                          color: Colors.white,
                        ),
                        height: 50.0,
                        width: 50.0,
                        color: Color.fromRGBO(166, 218, 149, 1),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '토론방',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Diary(),
                    ),
                  );
                },
                shape: CircleBorder(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Image.asset(
                            'assets/images/post.png',
                            color: Colors.white,
                          ),
                        ),
                        height: 50.0,
                        width: 50.0,
                        color: Color.fromRGBO(166, 218, 149, 1),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '매매일지',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Recommend(),
                    ),
                  );
                },
                shape: CircleBorder(),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        child: Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                          size: 50,
                        ),
                        height: 50.0,
                        width: 50.0,
                        color: Color.fromRGBO(166, 218, 149, 1),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '추천주 기록',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  if (flag == 1) {
                    _showRewardedAd();
                  } else {
                    AlertController.show(
                      '로딩중입니다',
                      '잠시만 기다려주십시오',
                      TypeAlert.success,
                    );
                  }
                },
                shape: CircleBorder(),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        child: Icon(
                          Icons.star,
                          color: Colors.yellow,
                          size: 50,
                        ),
                        height: 50.0,
                        width: 50.0,
                        color: Color.fromRGBO(166, 218, 149, 1),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '두부개미\n추천주',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  if (flag == 1) {
                    _showInterstitialAd();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Info(category: 'd'),
                      ),
                    );
                  } else {
                    AlertController.show(
                      '로딩중입니다',
                      '잠시만 기다려주세요',
                      TypeAlert.success,
                    );
                  }
                },
                shape: CircleBorder(),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        child: Image.asset(
                          'assets/images/news.png',
                          color: Colors.white,
                        ),
                        height: 50.0,
                        width: 50.0,
                        color: Color.fromRGBO(166, 218, 149, 1),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '주식\n정보글',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              ),
              RawMaterialButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Storage(),
                    ),
                  );
                },
                shape: CircleBorder(),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5.0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.label,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        height: 50.0,
                        width: 50.0,
                        color: Colors.red,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '종목별로\n모아보기',
                      style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 11),
                      textAlign: TextAlign.center,
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 40),
        backgroundColor: Color.fromRGBO(122, 154, 130, 1),
        title: Text(
          '주식 기록장',
          style: TextStyle(
            fontFamily: 'NanumGothic',
          ),
        ),
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
            icon: Image.asset(
              "assets/images/bell.png",
              color: Colors.white,
            ),
          ),
          IconButton(
            icon: Icon(Icons.report),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('신고 및 문의사항'),
                  content: Text('신고 및 문의사항이 있으실 경우 alswp26@gmail.com로 연락 주시면  빠르게 해결하도록 하겠습니다'),
                  actions: [
                    FlatButton(
                      onPressed: () async {

                        Navigator.pop(context);
                      },
                      child: Text('확'),
                    ),

                  ],
                );
              },
            );
          })
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                  width: MediaQuery.of(context).size.width,
                  height: 100,
                  color: Color.fromRGBO(122, 154, 130, 1)),
            ],
          ),
          Container(
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: menu(),
                ),
                FutureBuilder(
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return PostAll(
                          forList, context, '해외주식', Info(category: 'f'));
                    } else {
                      return Center(
                        child: CircularProgressIndicator(
                          color: Colors.red,
                        ),
                      );
                    }
                  },
                  future: getPostAll(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
      return;
    }
    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (RewardedAd ad) {},
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _initRewardedVideoAdListener();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _initRewardedVideoAdListener();
      },
    );

    _rewardedAd!.show(onUserEarnedReward: (RewardedAd ad, RewardItem reward) {
      setState(() {
        // Video ad should be finish to get the reward amount.

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
          setState(() {});
          if (_numRewardedLoadAttempts <= maxFailedLoadAttempts) {
            _initRewardedVideoAdListener();
          }
        },
      ),
    );
  }

  var popularTag = [];
  var forList = [];

  Future<List> getPostAll() async {
    popularTag = [];

    var urlFor = "http://13.125.62.90/api/v1/BlogPostsList/?category=F";

    var tag = "http://13.125.62.90/api/v1/TaggitTaggedItem/";

    final responsetag = await dio.get(tag,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ));

    final responsefor = await dio.get(urlFor,
        options: Options(
          followRedirects: false,
          validateStatus: (status) {
            return status! < 500;
          },
        ));

    for (var i = 0; i < 10; i++) {
      popularTag.add(responsetag.data[i]['name']);
    }

    final map = <String, int>{};
    for (final letter in popularTag) {
      map[letter] = map.containsKey(letter) ? map[letter]! + 1 : 1;
    }

    forList = responsefor.data['results'];

    if (responsefor.statusCode == 200)
      return forList;
    else {
      return Future.error(responsefor.statusCode.toString());
    }
  }

  Widget PostAll(
      List posts, BuildContext context, String title, Widget postlist) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '새로 올라온 글',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontFamily: 'NanumGothic'),
                ),
                TextButton(
                    child: Row(
                      children: [
                        Text(
                          '더보기',
                          style: TextStyle(color: Colors.grey),
                        ),
                        Icon(
                          Icons.arrow_right,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => postlist));
                    })
              ],
            ),
            padding: EdgeInsets.only(left: 10),
          ),
          Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border:
                          Border.all(color: Colors.lightGreenAccent, width: 2)),
                  child: Column(
                    children: [
                      for (var i = 0; i < 6; i++)
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(width: 1.0, color: Colors.grey),
                            ),
                          ),
                          child: ListTile(
                            title: Text(posts[i]['title'],
                                style: TextStyle(fontSize: 13)),
                            subtitle: Text(
                              posts[i]['writer'],
                              style: TextStyle(fontSize: 10),
                            ),
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => allDetail(
                                            index: posts[i]['id'],
                                          )));
                            },
                            dense: true,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(),
        ],
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
