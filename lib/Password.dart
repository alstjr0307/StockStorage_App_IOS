import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';

class InputPassword extends StatefulWidget {
  final String userID;

  const InputPassword({Key? key, required this.userID}) : super(key: key);

  @override
  _InputPasswordState createState() => _InputPasswordState();
}

class _InputPasswordState extends State<InputPassword> {
  TextEditingController passwordController = TextEditingController();

  var sharedPreferences;

  shared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  var _isloading = false;

  @override
  void initState() {
    super.initState();

    shared();
  }

  @override
  Widget build(BuildContext context) {
    if (_isloading ==true) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else
      return Scaffold(
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                child: Text('반갑습니다\n\n로그인을 위해 비밀번호를 입력해주세요', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)
              ),
            ),
            Center(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: TextField(
                  obscureText: true,
                  controller: passwordController,
                  decoration: InputDecoration(
                    hintText: '비밀번호',
                    border: OutlineInputBorder(),
                    labelText: '비밀번호',
                  ),
                ),
              ),
            ),
            Container(
              child: TextButton(
                child: Text('입력'),
                onPressed: () {

                  login();
                },
              ),
            ),
          ],
        ),
      );
  }

  login() async {
    setState(() {
      _isloading = true;
    });
    Map data = {"username": widget.userID, "password": passwordController.text};
    var responsee = await http
        .post(Uri.http("13.125.62.90", "api/v2/auth/token/login/"), body: data);
    print('로그인' + responsee.body);
    if (responsee.statusCode == 200) {
      var jsonDataa = json.decode(responsee.body);
      var tokenn = jsonDataa['auth_token'];
      var userresponse = await http.get(
          Uri.http("13.125.62.90", "api/v2/auth/users/me"),
          headers: {"Authorization": "Token ${tokenn}"});
      var user = jsonDecode(utf8.decode(userresponse.bodyBytes));
      print(user);

      setState(() {
        _isloading = false;
        sharedPreferences.setString("token", tokenn);
        sharedPreferences.setString("nickname", user['first_name'].toString());
        sharedPreferences.setInt('userID', user['id']);

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => HomePage()),
                (Route<dynamic> route) => false);
        AlertController.show("로그인 성공", "이제 댓글, 좋아요 기능을 사용할 수 있어요  ", TypeAlert.success, );
      });
    }
    else {
      setState(() {
        _isloading = false;
      });
      AlertController.show("비밀번호 틀림", "비밀번호를 확인해주세요!", TypeAlert.warning, );

    }
  }
}
