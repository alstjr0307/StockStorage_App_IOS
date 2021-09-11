import 'package:flutter/material.dart';
import 'allDetail.dart';

import 'package:dio/dio.dart';
import 'package:intl/intl.dart';
class DomesticSearchPage extends StatefulWidget {
  final String category;

  DomesticSearchPage({Key? key, required this.category}) : super(key: key);
  @override
  _DomesticSearchPageState createState() => _DomesticSearchPageState();
}

class _DomesticSearchPageState extends State<DomesticSearchPage> {
  var searchController = TextEditingController();
  var searchOption = '제목+내용';

  late Container adContainer;

  static int page = 0;
  bool isLoading = false;
  List posts = [];
  final dio = new Dio();
  late int maxpage;
  var posttype = '';
  var sharedPreferences;
  var token;

  ScrollController _sc = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(240, 175, 142,100),
          iconTheme: IconThemeData(color:Colors.black),
          title: Text((() {
          if (widget.category =='f'){
            return '주식 토론방 검색';}
          return '주식정보방 검색';
        })(),style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),),
        ),
        body: Column(
          children: [
            _SearchSection(),
            _buildList(),
          ],
        ));
  }

  Widget _SearchSection() {
    return Row(
      children: [
        new Flexible(
          child: TextField(
            autofocus: true,
            controller: searchController,
            style: new TextStyle(
              color: Colors.black,
            ),
            decoration: new InputDecoration(

                prefixIcon: new Icon(Icons.search, color: Colors.blue),
                hintText: '검색어를 입력해주세요',
                hintStyle: new TextStyle(color: Colors.blue)),
          ),
        ),
        Container(

          child: DropdownButton(
            hint: Text(
              searchOption,
              style: TextStyle(color: Colors.blue),
            ),
            iconSize: 30.0,
            style: TextStyle(color: Colors.blue),
            items: ['제목', '내용', '제목+내용'].map(
              (val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Text(val),
                );
              },
            ).toList(),
            onChanged: (val) {
              setState(
                () {
                  searchOption = val.toString();
                },
              );
            },
          ),
        ),
        IconButton(icon: Icon(Icons.search), onPressed: () {
          page = 0;
          posts = [];
          isLoading = false;
          if (searchOption == '제목+내용')
            _getMoreData(page);
          else if(searchOption == '제목')
            _getMoreDataTitle(page);
          else if(searchOption =='내용')
            _getMoreDataContent(page);

          _sc.addListener(() {
            if (_sc.position.pixels == _sc.position.maxScrollExtent &&
                page < maxpage) {
              _getMoreData(page);
            }
          });
        })
      ],
    );
  }
  Future<void> _getData() async {
    //새로고침을 위한 것
    setState(() {
      page = 0;
      posts = [];
      _getMoreData(page);
    });
  }
  void _getMoreDataContent(int index) async {
    //데이터 추가하기
    List tList = [];


    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "http://13.125.62.90/api/v1/BlogPosts/?category=${widget.category}&contentsearch=${searchController.text}&page=" +
          (index + 1).toString();

      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;

      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }


      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
    }
  }
  void _getMoreDataTitle(int index) async {
    //데이터 추가하기
    List tList = [];

    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "http://13.125.62.90/api/v1/BlogPosts/?category=${widget.category}&titlesearch=${searchController.text}&page=" +
          (index + 1).toString();

      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;

      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);
        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }


      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
    }
  }
  void _getMoreData(int index) async {
    //데이터 추가하기
    List tList = [];


    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      var url = "http://13.125.62.90/api/v1/BlogPostsList/?category=${widget.category}&multisearch=${searchController.text}&page=" +
          (index + 1).toString();
      print(url);
      final response = await dio.get(url);
      maxpage = (response.data['count'] - 1) ~/ 10 + 1;
      tList = [];

      for (int i = 0; i < response.data['results'].length; i++) {
        tList.add(response.data['results'][i]);

        tList[i]['time'] = DateFormat("M월dd일 H:m").format(DateTime.parse(tList[i]['create_dt']));
      }


      setState(() {
        isLoading = false;
        posts.addAll(tList);
        page++;
      });
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
  Widget _buildList() {
    return Expanded(
      child: Container(
        child: RefreshIndicator(
          child: ListView.builder(
              itemCount: posts.length +1,
              controller: _sc,
              // Add one more item for progress indicator
              padding: EdgeInsets.symmetric(vertical: 8.0),
              itemBuilder: (BuildContext context, int index) {
                if (index == posts.length) {
                  return _buildProgressIndicator();


                }
                else {
                  return Container(
                    margin: new EdgeInsets.fromLTRB(5, 0, 5, 0),
                    width: 25.0,
                    height: 80.0,
                    child: InkWell(
                      child: Card(
                        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                        color: Colors.white70,
                        elevation: 5,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(10.0,0,8.0,0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                                              Icon(Icons.person, size:15),
                                              Text(
                                                (posts[index]['writer'].toString()), style: TextStyle(fontSize: 12),
                                              ),
                                              SizedBox(width:10),

                                            ],
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.timer, size: 12,color: Colors.grey),
                                            Text(posts[index]['time'],style: TextStyle(fontSize: 12, color: Colors.grey)),
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
                            builder: (context) => allDetail(
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
}
