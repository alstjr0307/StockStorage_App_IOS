import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter/widgets.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';



import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import 'package:back_button_interceptor/back_button_interceptor.dart';

import 'package:intl/intl.dart';

class allDetail extends StatefulWidget {
  final int index;

  const allDetail({Key? key, required this.index}) : super(key: key); //index = 게시물 번호
  @override
  _allDetailState createState() => _allDetailState();
}

class _allDetailState extends State<allDetail>
    with AutomaticKeepAliveClientMixin<allDetail> {
  @override
  bool get wantKeepAlive => true;
  final TextEditingController commentController = TextEditingController();
  Map content = {};
  ScrollController _sc = new ScrollController();

  Color hexToColor(String code) {
    return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  //전체게시물 데이터 수집(restapi)
  late Map commentmap;
  late Map postlistmap;
  var comment;
  var postlist;
  bool whether_like = false;
  var sharedPreferences;
  var token;
  var userid;
  var likecount;
  late Future _future;

  //백버튼 작용
  @override
  initState() {
    super.initState();
    _future = getPostData(widget.index, content);
    BackButtonInterceptor.add(myInterceptor);
  }

  @override
  void dispose() {
    BackButtonInterceptor.remove(myInterceptor);
    super.dispose();
  }

  bool myInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    Navigator.pop(context); // Do some stuff.
    return true;
  }





  @override
  Widget build(BuildContext context) {
    super.build(context);
    FocusScopeNode currentFocus = FocusScope.of(context);
    return GestureDetector(
      onTap: () {
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          final restaurant = snapshot.data as Map;
          if (snapshot.hasError)
            return Scaffold(body: Center(child: Text('게시물이 존재하지 않습니다')));
          else if (!snapshot.hasData)
            return Scaffold(
              body: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(Colors.amber),
              )),
            );
          else {
            return Scaffold(
              appBar: AppBar(
                title: Text(restaurant['title']),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: _sc,
                        children: [
                          Container(
                            padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  //제목&작성자
                                  margin: EdgeInsets.fromLTRB(3, 3, 3, 3),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 3, color: Colors.black38),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20.0)),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          SizedBox(width: 10),
                                          Expanded(
                                            child: ListTile(
                                              contentPadding: EdgeInsets.all(0),
                                              leading: Icon(
                                                  Icons.person_outline,
                                                  size: 40),
                                              title:
                                                  Text(restaurant['writer']),
                                              subtitle: Row(
                                                children: [
                                                  Text(restaurant['time']),
                                                  SizedBox(
                                                    width: 10,
                                                    height: 20,
                                                  ),


                                                ],
                                              ),
                                            ),
                                          ),

                                        ],
                                      ),
                                      titleText(
                                          restaurant['title'], context),
                                    ],
                                  ),
                                ),
                                contentText(restaurant['content']),



                                //댓글 리스트

                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Future<Map> getPostData(int postId, Map content) async {

    final response = await http.get(
      Uri.http('13.125.62.90', "api/v1/BlogPosts/${postId}/"),
    ); //게시물 가져오기
    print(response.statusCode);
    print('포스트 ${postId}');
    if (response.statusCode == 200) {
      // 만약 서버가 OK 응답을 반환하면, JSON을 파싱합니다.
      content = jsonDecode(utf8.decode(response.bodyBytes));
      content['time'] =
          DateFormat("M월dd일 H:m").format(DateTime.parse(content['create_dt']));

      return content;
    } else {
      // 만약 응답이 OK가 아니면, 에러를 던집니다.
      throw Exception('Failed to load post');
    }
  }
  Widget titleText(String title, BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 20),
      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget contentText(String content) {
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(
                    color: Colors.black26, width: 1, style: BorderStyle.solid))),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 10, 4, 20),
          child: HtmlWidget(
            content,
            onTapImage: (src) {
              print(src);
            },

          ),
        ),
      ),
      scrollDirection: Axis.vertical,
    );
  }

}
