import 'package:dio/dio.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'writerpost.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class MyProfile extends StatelessWidget {
  final dio = new Dio();

  Future<Map> getProfile() async {

    var sharedPreferences = await SharedPreferences.getInstance();

    var token = sharedPreferences.getString("token");
    var userid = sharedPreferences.getInt("userID");

    var profileurl =
        'http://13.125.62.90/api/v1/AuthUser/${userid.toString()}/';

    final responseall = await dio.get(profileurl,
        options: Options(headers: {"Authorization": "Token ${token}"}));

    Map profile = responseall.data;

    profile['create_dt'] = DateFormat("M월dd일")
        .format(DateTime.parse(profile['date_joined']));

    return profile;
  }

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: getProfile(),
        builder: (context, snapshot) {
          final restaurant = snapshot.data as Map;
          if (snapshot.hasData)
            return Scaffold(
              body: Column(
                children: [
                  Container(
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [                                      Color.fromRGBO(0, 82, 33, 1),
                                Color.fromRGBO(185, 204, 179, 1)])),
                      child: Container(
                        width: double.infinity,
                        height: 350.0,
                        child: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 20,),
                              Text(
                                restaurant['first_name'],
                                style: TextStyle(
                                    fontSize: 40.0,
                                    color: Colors.white,
                                    fontFamily: 'Strong',
                                    fontWeight: FontWeight.bold

                                ),
                              ),
                              SizedBox(height:10),
                              Text(
                                restaurant["create_dt"]+' 가입',
                                style: TextStyle(
                                    fontSize: 15.0,
                                    color: Colors.white,
                                    fontFamily: 'Nanum',
                                    fontWeight: FontWeight.bold

                                ),
                              ),
                              SizedBox(
                                height: 30.0,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5.0),
                                clipBehavior: Clip.antiAlias,
                                color: Colors.white,
                                elevation: 5.0,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0, vertical: 22.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WriterPost(userID :restaurant['id'], nickname: restaurant['first_name'])));
                                          },
                                          child: Column(
                                            children: [
                                              Text(
                                                "게시물",
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                  fontSize: 22.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 5.0,
                                              ),
                                              Text(
                                                restaurant['post']
                                                    .toString(),
                                                style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Colors.pinkAccent,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          children: [
                                            Text(
                                              "댓글",
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.0,
                                            ),
                                            Text(
                                              restaurant['comment']
                                                  .toString(),
                                              style: TextStyle(
                                                fontSize: 20.0,
                                                color: Colors.pinkAccent,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )),
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30.0, horizontal: 16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [],
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),

                ],
              ),
            );
          else {
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.amber),
                  )),
            );
          }
        });
  }
}