import 'package:flutter/material.dart';

import 'dart:async';
import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'allDetail.dart';
import 'package:intl/intl.dart';

class StoragePost extends StatefulWidget {
  final String tag;

  const StoragePost({Key? key, required this.tag}) : super(key: key);

  @override
  _StoragePostState createState() => _StoragePostState();
}

class _StoragePostState extends State<StoragePost> {


  bool boolcontent = true;
  ScrollController _sc = new ScrollController();
  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;


  @override
  void initState() {
    this._getMoreData(page);
    super.initState();
    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        this._getMoreData(page);
      }
    });

  }

  @override
  void dispose() {
    _sc.dispose();
    page = 0;
    posts = [];
    isLoading = false;

    super.dispose();
  }

  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];

    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token"); //token 값 불러오기

    List postlist = [];
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });
      var tagitemurl =
          "http://13.125.62.90/api/v1/TaggitTaggedItem/?namee=${widget.tag}";

      final taggitemresponse = await dio.get(
        tagitemurl,
      );
      for (var i = 0; i < taggitemresponse.data.length; i++) {
        postlist.add(taggitemresponse.data[i]['object'].toString());
      }

      String idlist = '';
      for (var i = 0; i < postlist.length; i++) {
        idlist = idlist + postlist[i] + ',';
      }

      if (idlist != '') {
        var url =
            "http://13.125.62.90/api/v1/BlogPostsList/?id_in=${idlist}&page=" +
                (index + 1).toString();

        final response = await dio.get(url);
        maxpage = response.data['count'] ~/ 10 + 1;

        tList = [];
        for (int i = 0; i < response.data['results'].length; i++) {
          tList.add(response.data['results'][i]);
          tList[i]['time'] = DateFormat("M월dd일 H:m")
              .format(DateTime.parse(tList[i]['create_dt']));
        }

        boolcontent = true;

        setState(() {
          isLoading = false;
          posts.addAll(tList);
          page++;
        });
      } else {
        maxpage = 0;
        posts = [];
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }

  Widget _buildList() {
    if (boolcontent == true)
      return RefreshIndicator(
        child: ListView.builder(
            itemCount: posts.length + 1,
            controller: _sc,
            // Add one more item for progress indicator
            padding: EdgeInsets.symmetric(vertical: 8.0),
            itemBuilder: (BuildContext context, int index) {
              if (index == posts.length) {
                return _buildProgressIndicator();
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(10.0), bottom: Radius.circular(10.0)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey,
                          offset: Offset(0.0, 1.0), //(x,y)
                          blurRadius: 5.0,
                        ),
                      ],
                    ),
                    margin: new EdgeInsets.fromLTRB(5, 0, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(10.0, 0, 8.0, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(),
                            Text(
                              (posts[index]['title']),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Icon(Icons.person, size: 15),
                                      Text(
                                        (posts[index]['writer'].toString()),
                                        style: TextStyle(
                                            fontSize: 10, fontFamily: 'Strong'),
                                      ),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.comment,
                                        size: 15,
                                        color: Colors.redAccent,
                                      ),
                                      Text(
                                          ' ${posts[index]['comment'].toString()}',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.red)),
                                      SizedBox(width: 10),
                                      Icon(
                                        Icons.thumb_up,
                                        size: 15,
                                        color: Colors.red,
                                      ),
                                      Text(' ${posts[index]['likes'].toString()}',
                                          style: TextStyle(
                                              fontSize: 12, color: Colors.red))
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.timer,
                                        size: 12, color: Colors.grey),
                                    Text(posts[index]['time'],
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => allDetail(
                              index: posts[index]["id"],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              }
            }),
        onRefresh: _getData,
      );
    else {
      return Container(
        child: Center(
            child: Text(
              '게시물이 없습니다',
              style: TextStyle(color: Colors.blueGrey, fontSize: 20),
            )),
      );
    }
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0),
      child: new Center(
        child: new Opacity(
          opacity: isLoading ? 1.0 : 00,
          child: new CircularProgressIndicator(),
        ),
      ),
    );
  }



  late Map user;
  late List data;

  late Widget screen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 40),
        backgroundColor: Color.fromRGBO(122, 154, 130, 1),
        title: Text(widget.tag),
      ),

      body: _buildList(),
    );
  }
}