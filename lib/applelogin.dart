import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:http/http.dart' as http;
import 'package:stockmemo/setID.dart';

import 'Homepage.dart';
import 'Password.dart';
class AppleLogin extends StatefulWidget {
  const AppleLogin({Key? key}) : super(key: key);

  @override
  _AppleLoginState createState() => _AppleLoginState();
}

class _AppleLoginState extends State<AppleLogin> {
  var sharedPreferences;
  var _isloading = true;
  var _accountEmail;
  var _userid;
  Future<void> signInWithApple() async {

    sharedPreferences = await SharedPreferences.getInstance();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,



      ],
    );
    print(appleCredential.userIdentifier.toString().substring(0,6) + appleCredential.userIdentifier.toString().substring(7,10));
    setState(() {
      _accountEmail = appleCredential.userIdentifier.toString().substring(0,6) + appleCredential.userIdentifier.toString().substring(7,10);
      _userid = appleCredential.givenName;
    });

    checkAccount(_accountEmail);

  }
  checkAccount(String username) async {


    var response = await http.get(
      Uri.http(
          "13.125.62.90", "api/v1/AuthUser/", {"username": "$_accountEmail"}),
    );
    print(response.body);
    if (response.body == '[]') {
     register();

    } else {
      login();
    }


  }
  @override
  void initState() {
    super.initState();
    signInWithApple();



  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(122, 154, 130, 1),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        title:Text('애플 로그인'),
      ),
      body: Center(child: CircularProgressIndicator())
    );
  }

  register() async {
    Map body = {
      "username": _accountEmail,
      "password": 'alstjr0307',
      "first_name": _userid,
    };
    var responsee =
    await http.post(Uri.http("13.125.62.90", "api/v2/auth/users/"), body: body);
    var jsonRegist = json.decode((utf8.decode(responsee.bodyBytes)));
    if (responsee.statusCode == 201) {
      //계정 생성 성공


      var userr = jsonRegist['id'];

      var responselogin = await http
          .post(Uri.http("13.125.62.90", "api/v2/auth/token/login/"), body: {
        "username": _accountEmail,
        "password": 'alstjr0307'
      });
      var jsonLogin = json.decode(responselogin.body);

      var token = jsonLogin['auth_token'];
      print(jsonLogin);
      setState(() {
        sharedPreferences.setString("token", token);
        sharedPreferences.setInt('userID', userr);
        sharedPreferences.setString("nickname",_userid);
      });
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(),
          ));
    }
    else{
      setState(() {
        _isloading=false;
      });
      var errorcode = jsonRegist.keys.toList();
      print(errorcode);
      var errorcode2 = jsonRegist[errorcode[0]].toString();
      AlertController.show(
          "가입 오류", errorcode2,
          TypeAlert.warning);
    }
  }
  login() async {
    setState(() {
      _isloading = true;
    });
    Map data = {"username": _accountEmail, "password": 'alstjr0307'};
    var responsee = await http
        .post(Uri.http("13.125.62.90", "api/v2/auth/token/login/"), body: data);
    if (responsee.statusCode == 200) {
      var jsonDataa = json.decode(responsee.body);
      var tokenn = jsonDataa['auth_token'];
      var userresponse = await http.get(
          Uri.http("13.125.62.90", "api/v2/auth/users/me"),
          headers: {"Authorization": "Token ${tokenn}"});
      var user = jsonDecode(utf8.decode(userresponse.bodyBytes));


      setState(() {
        _isloading = false;
        sharedPreferences.setString("token", tokenn);
        sharedPreferences.setString("nickname", user['first_name'].toString());
        sharedPreferences.setInt('userID', user['id']);
        Navigator.pop(context);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
                (Route<dynamic> route) => false);
        AlertController.show("로그인 성공", "이제 댓글, 좋아요 기능을 사용할 수 있어요  ", TypeAlert.success, );
      });
    }

  }
}
