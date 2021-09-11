import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';

class ChangeNickname extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _State();
}

class _State extends State<ChangeNickname> {
  TextEditingController nicknameController = TextEditingController();

  bool _isLoading = false;
  Widget errormsg = Container();

  sign(String nickname) async {
    Map data = {
      "first_name" : nickname
    };

    var jsonData;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");
    var userid = sharedPreferences.getInt("userID");
    print('123');
    print('아이디'+ userid.toString());
    var response = await http.patch(
        Uri.http("13.125.62.90", "api/v1/AuthUser/$userid/"),
        headers: {"Authorization": "Token ${token}"},
        body: data);

    print(response.statusCode);
    print('user: $userid');
    if (response.statusCode == 200) {
      print('1');

      print('제대로 됨');
      setState(() {
        _isLoading = false;
        sharedPreferences.setString("nickname", nickname);
        Navigator.pop(context);
        showDialog(context: context, builder: (context) {
          return AlertDialog(
            title: Text('닉네임 변경 성공'),
            content: Text("닉네임을 성공적으로 변경하였습니다 '${nickname}' "),
            actions: [
              FlatButton(onPressed: () {
                Navigator.pop(context);
              },
                  child: Text('확인')),
            ],
          );
        });
      }
      );
    }
    if (response.statusCode == 400) {
      print(response.body);
      setState(() {
        _isLoading = false;
        errormsg = Card(
          color: Colors.red,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.error, size: 50),
                title: Text(
                  '중복된 닉네임입니다',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      });
    } else
      print(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('닉네임 변경'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: EdgeInsets.all(10),
                child: Text(
                  '닉네임 변경',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                      fontSize: 30),
                )),

            Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                maxLength: 10,
                inputFormatters: [new FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9ㄱ-ㅎ가-힣ㆍᆢ]')),],
                controller: nicknameController,
                decoration: InputDecoration(
                  hintText: '(한글, 영어, 숫자 가능, 10자 이내)',
                  border: OutlineInputBorder(),
                  labelText: '새 닉네임',
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Container(
              height: 50,
              padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: RaisedButton(
                textColor: Colors.white,
                color: Colors.blue,
                child: Text(
                  '제출',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  sign(nicknameController.text);

                },
              ),
            ),
            errormsg,
          ],
        ),
      ),
    );
  }
}
