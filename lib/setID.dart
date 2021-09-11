import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dropdown_alert/alert_controller.dart';
import 'package:flutter_dropdown_alert/model/data_alert.dart';

import 'package:http/http.dart' as http;
import 'package:flutter_dropdown_alert/dropdown_alert.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';

class SetID extends StatefulWidget {
  final String userID;

  const SetID({Key? key, required this.userID}) : super(key: key);

  @override
  _SetIDState createState() => _SetIDState();
}

class _SetIDState extends State<SetID> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController passwordConfirmController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  var sharedPreferences;
  var _isloading = false;

  getShared() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    getShared();
  }

  @override
  Widget build(BuildContext context) {
    if (_isloading == true) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else
      return Scaffold(
        appBar: AppBar(
          title: Text('회원가입'),
        ),
        body: SafeArea(
          child: Center(
            child: ListView(
              children: [
                SizedBox(height: 80),
                Center(
                  child: Text(
                    '카카오계정으로 가입중입니다',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 50),
                Center(child: Text('아래 입력란을 완성해주세요')),
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    maxLength: 7,
                    inputFormatters: [
                      new FilteringTextInputFormatter.allow(
                          RegExp('[a-zA-Z0-9ㄱ-ㅎ가-힣ㆍᆢ]')),
                    ],
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: '(한글 영어 숫자 가능, 7자 이내)',
                      border: OutlineInputBorder(),
                      labelText: '닉네임',
                    ),
                  ),
                ),


                Container(
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
                Container(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: TextField(
                    obscureText: true,
                    controller: passwordConfirmController,
                    decoration: InputDecoration(
                      hintText: '비밀번호 확인',
                      border: OutlineInputBorder(),
                      labelText: '비밀번호 확인',
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.yellow,
                    // foreground
                  ),
                  child: Text('완료'),
                  onPressed: () {
                    setState(() {
                      _isloading = true;
                    });
                    if (passwordController.text ==
                        passwordConfirmController.text)
                      register();
                    else if (passwordController.text != passwordConfirmController.text){
                      setState(() {
                        _isloading = false;
                      });
                      AlertController.show(
                          "비밀번호 틀림", "비밀번호와 비밀번호 확인이 일치하지 않습니다!",
                          TypeAlert.success);
                    }
                    else if (nameController.text =='') {
                      setState(() {
                        _isloading = false;
                      });
                      AlertController.show(
                          "닉네임 빈칸", "닉네임을 입력해주세요!",
                          TypeAlert.success);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      );
  }

  register() async {
    Map body = {
      "username": widget.userID,
      "password": passwordController.text,
      "first_name": nameController.text,
    };
    var responsee =
        await http.post(Uri.http("13.125.62.90", "api/v2/auth/users/"), body: body);
    var jsonRegist = json.decode((utf8.decode(responsee.bodyBytes)));
    if (responsee.statusCode == 201) {
      //계정 생성 성공


      var userr = jsonRegist['id'];

      var responselogin = await http
          .post(Uri.http("13.125.62.90", "api/v2/auth/token/login/"), body: {
        "username": widget.userID,
        "password": passwordController.text
      });
      var jsonLogin = json.decode(responselogin.body);

      var token = jsonLogin['auth_token'];
      print(jsonLogin);
      setState(() {
        _isloading = false;
        sharedPreferences.setString("token", token);
        sharedPreferences.setInt('userID', userr);
        sharedPreferences.setString("nickname",nameController.text);
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
}
