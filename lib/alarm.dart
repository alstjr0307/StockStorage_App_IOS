import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
class Alarm extends StatefulWidget {
  @override
  _AlarmState createState() => _AlarmState();
}

class _AlarmState extends State<Alarm> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('알림', style:TextStyle(color:Colors.black, fontWeight: FontWeight.bold, fontFamily: 'Strong')),
        iconTheme: IconThemeData(color: Colors.white, size: 40),
        backgroundColor: Color.fromRGBO(122, 154, 130, 1),
      ),
      body: _List(),
    );
  }
  Future alarmlog() async {
    await analytics.setCurrentScreen(
      screenName: '알림',
      screenClassOverride: 'alarm',
    );
  } //앱
  var sharedPreferences;
  var username;
  var token;
  var comment = '없음';

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("token") != null) {
      username = sharedPreferences.getString("nickname");
      token = sharedPreferences.getString("token");
      comment = sharedPreferences.getString("commentnoti");
      print(comment);
      setState(() {

      });
    }
  }
  @override
  void initState() {
    super.initState();
    comment = '없음';
    checkLoginStatus();

    alarmlog();
  }
  Widget _List() {
    return StreamBuilder(stream:FirebaseFirestore.instance
        .collection('0000alarm')
        .doc('알람')
        .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('error'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final data = snapshot.requireData.data();
          var index = data!.keys.toList();
          index.sort();

          double c_width = MediaQuery.of(context).size.width*0.9;

          return ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Card(
                  elevation: 10,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Icon(Icons.comment, color: Colors.red,),
                            Text('  새 댓글', style: TextStyle(fontSize: 14, color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            if (comment != null)
                              Container(width:300,child:

                              Text(comment, style: TextStyle(fontSize:17, fontFamily: 'Strong', ),overflow: TextOverflow.ellipsis,)),
                            if (comment ==null)
                              Container(width:300,child:

                              Text('없음', style: TextStyle(fontSize:17, fontFamily: 'Strong', ),overflow: TextOverflow.ellipsis,)),
                          ],
                        ),
                      ),
                      if (comment != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container( width: c_width,child: Text(comment.replaceAll("\\n", "\n"), maxLines: 3)),

                        ),
                      if (comment== null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container( width: c_width,child: Text('새 댓글 없음', maxLines: 3)),

                        ),

                    ],
                  ),
                ),
              ),

              SizedBox(height: 20,),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  child:Text('공지사항', style: TextStyle(fontFamily: 'Strong', fontWeight: FontWeight.bold, fontSize: 20)),
                ),
              ),
              for (var i in index.reversed) //i는 시간, data[i]는 map
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.timer),
                            Text(i, style: TextStyle(fontSize: 12)),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Text(data[i]['title'], style: TextStyle(fontSize:17, fontFamily: 'Strong'),),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container( width: c_width,child: Text(data[i]['content'].replaceAll("\\n", "\n"), maxLines: 3)),
                        )

                      ],
                    ),
                  ),
                )
            ],
          );
        }
    );
  }
}