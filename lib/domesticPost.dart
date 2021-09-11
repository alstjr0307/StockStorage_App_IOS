import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'HomePage.dart';
import 'addPost.dart';
import 'domesticsearchpage.dart';

import 'dart:async';
import 'allDetail.dart';
import 'package:dio/dio.dart';

import 'package:intl/intl.dart';

class Info extends StatefulWidget {
  final String category;

  Info({Key? key, required this.category}) : super(key: key);

  @override
  _InfoState createState() => _InfoState();
}

class _InfoState extends State<Info> with AutomaticKeepAliveClientMixin<Info> {
  ScrollController _sc = new ScrollController();

  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;
  var posttype = '';
  var sharedPreferences;
  var token;

  Future domesticlog() async {
    await analytics.setCurrentScreen(
        screenName: widget.category, screenClassOverride: '게시판');
  } //앱

  @override
  void initState() {
    _getMoreData(page);

    super.initState();
    domesticlog();

    _sc.addListener(() {
      if (_sc.position.pixels == _sc.position.maxScrollExtent &&
          page < maxpage) {
        _getMoreData(page);
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

    sharedPreferences = await SharedPreferences.getInstance();
    token = sharedPreferences.getString('token');
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url =
          "http://13.125.62.90/api/v1/BlogPostsList/?category=${widget
              .category}&page=" +
              (index + 1).toString();

      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;

      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        tList[i]['time'] = DateFormat("M월dd일 H:m")
            .format(DateTime.parse(tList[i]['create_dt']));
      }

      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
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
    return Expanded(
      child: Container(
        color: Color.fromRGBO(240, 175, 142, 100),
        child: RefreshIndicator(
          child: ListView.builder(
              itemCount: posts.length + 1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == posts.length) {
                  return _buildProgressIndicator();
                } else {
                  return Container(
                    margin: new EdgeInsets.fromLTRB(5, 0, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Card(
                        margin:
                        EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                        color: Color.fromRGBO(240, 175, 142, 0.5),
                        elevation: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                const EdgeInsets.fromLTRB(10.0, 0, 8.0, 0),
                                child: Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(),
                                    Text(
                                      (posts[index]['title']),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Row(
                                            children: [
                                              Icon(Icons.person, size: 15),
                                              Text(
                                                (posts[index]['writer']
                                                    .toString()),
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    fontFamily: 'Strong'),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.comment,
                                                size: 15,
                                                color: Colors.redAccent,
                                              ),
                                              Text(
                                                  ' ${posts[index]['comment']
                                                      .toString()}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red)),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.thumb_up,
                                                size: 15,
                                                color: Colors.red,
                                              ),
                                              Text(
                                                  ' ${posts[index]['likes']
                                                      .toString()}',
                                                  style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.red))
                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.timer,
                                                size: 12, color: Colors.grey),
                                            Text(posts[index]['time'],
                                                style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                allDetail(
                                  index: posts[index]["id"],
                                ),
                          ),
                        );
                      },
                    ),
                  );
                }
              }),
          onRefresh: _getData,
        ),
      ),
    );
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

  @override
  bool get wantKeepAlive => true;
  late Map user;
  late List data;
  late Widget screen;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          (() {
            if (widget.category == 'f') {
              return '주식 토론방';
            }
            return '주식정보방';
          })(),
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromRGBO(240, 175, 142, 100),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: [
          if (widget.category == 'f')
            IconButton(
                icon: Icon(
                  CupertinoIcons.pencil,
                  color: Colors.black,
                ),
                onPressed: () {
                  if (token != null)
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AddPost()));
                  else
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: new Text("로그인 필요"),
                          content: new Text("글을 작성하려면 로그인 하셔야합니다"),
                          actions: <Widget>[
                            new FlatButton(
                              child: new Text("확인"),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),

                          ],
                        );
                      },
                    );
                }),
          IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            DomesticSearchPage(category: 'f')));
              })
        ],
      ),
      body: Column(
        children: [
          _buildList(),
        ],
      ),
    );
  }
}
