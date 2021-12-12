import 'dart:convert';
import 'dart:core';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'HomePage.dart';

class Recommend extends StatefulWidget {
  @override
  _RecommendState createState() => _RecommendState();
}

class _RecommendState extends State<Recommend> {
  final _formKey = GlobalKey<FormState>();
  bool asTabs = false;
  late String selectedValue;

  final List items = [];
  var selectedItems;
  String result = '';
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final dateController = TextEditingController();
  final stockController = TextEditingController();
  final monthController = TextEditingController();
  final priceController = TextEditingController();
  final whyController = TextEditingController();
  final recommenderController = TextEditingController();
  final sonController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  var json;

  Future<List> _loadFromAsset() async {
    final String data = await rootBundle.loadString("assets/KStock.json");
    var json = jsonDecode(data);
    setState(() {
      for (Map stock in json) {
        items.add(stock['name']);
      }
    });
    return items;
  }

  Future recommendlog() async {
    await analytics.setCurrentScreen(
      screenName: '추천주기록',
    );
  } //앱

  @override
  void initState() {
    super.initState();
    recommendlog();
    if (DateTime.now().toString().substring(5, 6) == '0') {
      monthController.text = DateTime.now().toString().substring(0, 4) +
          '년 ' +
          DateTime.now().toString().substring(6, 7) +
          '월';
    } else {
      monthController.text = DateTime.now().toString().substring(0, 4) +
          '년 ' +
          DateTime.now().toString().substring(5, 7) +
          '월';
    }

    dateController.text = DateTime.now().toString().substring(0, 10);
    _loadFromAsset();
  }

  @override
  void dispose() {
    dateController.dispose();
    stockController.dispose();
    monthController.dispose();
    recommenderController.dispose();
    whyController.dispose();
    sonController.dispose();
    super.dispose();
  }

  var type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backwardsCompatibility: false,
          toolbarHeight: 110,
          backgroundColor: Color.fromRGBO(122, 154, 130, 1),
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '추천주 기록장',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white),
                ),
              ),
              _DateSelect(),
            ],
          ),
        ),
        floatingActionButton: SpeedDial(child: Icon(Icons.list), children: [
          SpeedDialChild(
            child: Icon(Icons.home),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          SpeedDialChild(
            onTap: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: Stack(
                        overflow: Overflow.visible,
                        children: <Widget>[
                          SingleChildScrollView(child: _InputWidget()),
                        ],
                      ),
                    );
                  });
            },
            child: Icon(Icons.add),
          ),
        ]),
        body: Container(
          color: Colors.white,
          child: Column(
            children: [_List()],
          ),
        ));
  }

  Widget _DateSelect() {
    return Container(
      height: 50,
      child: Row(
        children: [
          Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: FlexColor.redLightPrimary),
            child: IconButton(
              onPressed: () {
                var year;
                var nextmonth;

                if (monthController.text.substring(6, 8) == '1월') {
                  year = int.parse((monthController.text.substring(0, 4))) - 1;
                  nextmonth = 12;
                } else if (monthController.text.toString().length == 8) {
                  year = int.parse(monthController.text.substring(0, 4));
                  nextmonth =
                      int.parse(monthController.text.substring(6, 7)) - 1;
                } else {
                  year = int.parse(monthController.text.substring(0, 4));
                  nextmonth =
                      int.parse(monthController.text.substring(6, 8)) - 1;
                }

                monthController.text =
                    year.toString() + '년 ' + nextmonth.toString() + '월';
                setState(() {});
              },
              icon: Icon(
                Icons.arrow_left,
              ),
            ),
          ),
          Expanded(
            child: Container(
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: FlexColor.lightSurface,
                  hintText: '월 선택',
                  contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 1.0, top: 1.0),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(25.7),
                  ),
                ),
                style: TextStyle(
                    color: FlexColor.darkScaffoldBackground, fontSize: 12),
                textAlign: TextAlign.center,
                autofocus: false,
                readOnly: true,
                controller: monthController,
                onTap: () async {
                  var date = await showMonthPicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                      locale: Locale("ko", "KO"));
                  if (date.toString().substring(5, 6) == '0') {
                    monthController.text = date.toString().substring(0, 4) +
                        '년 ' +
                        date.toString().substring(6, 7) +
                        '월';
                  } else {
                    monthController.text = date.toString().substring(0, 4) +
                        '년 ' +
                        date.toString().substring(5, 7) +
                        '월';
                  }
                  setState(() {});
                },
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5),
            decoration: BoxDecoration(
                shape: BoxShape.circle, color: FlexColor.redLightPrimary),
            child: IconButton(
                onPressed: () {
                  var year;
                  var nextmonth;

                  if (monthController.text.toString().length == 8) {
                    year = int.parse(monthController.text.substring(0, 4));
                    nextmonth =
                        int.parse(monthController.text.substring(6, 7)) + 1;
                  } else if (monthController.text.substring(6, 9) == '12월') {
                    year =
                        int.parse((monthController.text.substring(0, 4))) + 1;
                    nextmonth = 1;
                  } else {
                    year = int.parse(monthController.text.substring(0, 4));
                    nextmonth =
                        int.parse(monthController.text.substring(6, 8)) + 1;
                  }

                  monthController.text =
                      year.toString() + '년 ' + nextmonth.toString() + '월';
                  setState(() {});
                },
                icon: Icon(Icons.arrow_right)),
          )
        ],
      ),
    );
  }

  AlertDialog alert = AlertDialog(
    title: Text("기록 중입니다"),
    content: Text("잠시만 기다려주세요 "),
  );

  Widget _InputWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                child: Text('날짜'),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    readOnly: true,
                    controller: dateController,
                    decoration: InputDecoration(
                      hintText: '날짜',
                      contentPadding: const EdgeInsets.only(
                          left: 10.0, bottom: 1.0, top: 1.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    onTap: () async {
                      var date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime(2100),
                        locale: Locale("ko", "KR"),
                      );
                      dateController.text = date.toString().substring(0, 10);
                    },
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: recommenderController,
                  decoration: InputDecoration(
                    hintText: '추천인',
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 1.0, top: 1.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: CustomSearchableDropDown(
                  label: '클릭하여 종목선택',
                  items: items,
                  dropDownMenuItems: items,
                  onChanged: (value) {
                    selectedItems = value;
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '추천단가',
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 1.0, top: 1.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: TextStyle(
                    color: Colors.black,
                  ),
                  controller: sonController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '손절가(선택)',
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 1.0, top: 1.0),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: 800,
            child: TextField(
              keyboardType: TextInputType.multiline,
              maxLines: null,
              controller: whyController,
              decoration: InputDecoration(
                  hintText: '추천 이유 및 기타 내용',
                  contentPadding:
                  const EdgeInsets.only(left: 14.0, bottom: 1.0, top: 1.0),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(width: 0),
                  )),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              child: new TextButton(
                autofocus: false,
                onPressed: () async {
                  if (selectedItems != null &&
                      dateController.text.isNotEmpty &&
                      recommenderController.text.isNotEmpty &&
                      priceController.text.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return alert;
                        });

                    var date = dateController.text;
                    bool typee;
                    if (type == "매수") {
                      typee = true;
                    } else {
                      typee = false;
                    }
                    var set = [];
                    var why = whyController.text;
                    if (whyController.text == "") {
                      why = "생략";
                    }

                    var newset = {
                      "매수추천가": priceController.text,
                      "종목": selectedItems,
                      "기타": why,
                      "추천인": recommenderController.text,
                      "손절가": sonController.text
                    };
                    await firestore
                        .collection(_auth.currentUser!.uid)
                        .doc('추천주 기록')
                        .get()
                        .then((DocumentSnapshot ds) {
                      try {
                        set = ds[date];
                      } catch (e) {}
                    });

                    set.add(newset);

                    await firestore
                        .collection(_auth.currentUser!.uid)
                        .doc('추천주 기록')
                        .update({date: set});

                    recommenderController.clear();
                    priceController.clear();
                    whyController.clear();
                    sonController.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('내용이 비어있습니다'),
                            content: Text('값을 입력해주세요'),
                            actions: [
                              FlatButton(
                                  onPressed: () {
                                    Navigator.pop(context, "ok");
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            content: Stack(
                                              overflow: Overflow.visible,
                                              children: <Widget>[
                                                SingleChildScrollView(
                                                    child: _InputWidget()),
                                              ],
                                            ),
                                          );
                                        });
                                  },
                                  child: Text('확인'))
                            ],
                          );
                        });
                  }
                },
                style: TextButton.styleFrom(
                    primary: Colors.white, backgroundColor: Colors.red),
                child: Text('입력'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color getMyColor(String maemaee) {
    if (maemaee == "매수") {
      return Color.fromRGBO(255, 182, 193, 1);
    } else {
      return Color.fromRGBO(135, 206, 235, 1);
    }
  }

  Widget _List() {
    return new StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(_auth.currentUser!.uid)
            .doc('추천주 기록')
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
          var keyss = data!.keys
              .where((k) =>
          k.substring(6, 7) == monthController.text.substring(6, 7) &&
              k.substring(0, 4) ==
                  monthController.text.substring(0, 4) ||
              k.substring(5, 7) == monthController.text.substring(6, 8) &&
                  k.substring(0, 4) == monthController.text.substring(0, 4))
              .toList();
          keyss.sort();
          return Flexible(
            child: ListView(
              children: [
                for (var index in keyss)
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            alignment: Alignment.center,
                            width: 60,
                            height: 60,
                            child: Text(
                              index.replaceRange(0, 8, '') + '일',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(0, 82, 33, 1),
                            ),
                            padding: EdgeInsets.all(10),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                for (var i in data[index])
                                  Padding(
                                    padding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 10),
                                    child: InkWell(
                                      onLongPress: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('기록 삭제'),
                                              content: Text('삭제하시겠습니까?'),
                                              actions: [
                                                FlatButton(
                                                    child: Text('아니오'),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    }),
                                                FlatButton(
                                                  child: Text('네'),
                                                  onPressed: () async {
                                                    List set = data[index];
                                                    set.remove(i);

                                                    if (set.isNotEmpty) {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(_auth
                                                          .currentUser!.uid)
                                                          .doc('추천주 기록')
                                                          .update({index: set});
                                                    } else {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection(_auth
                                                          .currentUser!.uid)
                                                          .doc('추천주 기록')
                                                          .update({
                                                        index:
                                                        FieldValue.delete()
                                                      });
                                                    }
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: Container(
                                          child: Card(
                                            color: Color.fromRGBO(
                                                255, 236, 227, 1),
                                            child: Padding(
                                              padding:
                                              const EdgeInsets.all(7.0),
                                              child: Column(
                                                children: [
                                                  Padding(
                                                    padding: const EdgeInsets
                                                        .fromLTRB(0, 0, 0, 8),
                                                    child: Row(
                                                      children: [
                                                        Text('종목: '),
                                                        Text(
                                                          i['종목'],
                                                          style: TextStyle(
                                                              fontFamily:
                                                              'NanumGothic',
                                                              color: Colors.red,
                                                              fontSize: 15),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                  Row(
                                                    children: [
                                                      Text('추천인: '),
                                                      Text(i['추천인'],
                                                          style: TextStyle(
                                                              fontFamily:
                                                              'Strong',
                                                              color:
                                                              Colors.black,
                                                              fontSize: 15)),
                                                    ],
                                                  ),
                                                  Row(
                                                    mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          Text('추천단가: '),
                                                          Text(
                                                            i['매수추천가'],
                                                            style: TextStyle(
                                                                color:
                                                                Colors.red,
                                                                fontSize: 15),
                                                          ),
                                                        ],
                                                      ),
                                                      Row(
                                                        children: [
                                                          Text('손절가: '),
                                                          Text(
                                                            i['손절가'],
                                                            style: TextStyle(
                                                                color:
                                                                Colors.red,
                                                                fontSize: 15),
                                                          )
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                  Container(
                                                    child: Card(
                                                      elevation: 10,
                                                      child: Container(
                                                        width: 500,
                                                        padding:
                                                        EdgeInsets.all(10),
                                                        child: Text(
                                                          i['기타'].replaceAll(
                                                              "\\n", "\n"),
                                                          maxLines: 40,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                        color:
                                                        Color(0xffFFFFA5),
                                                      ),
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                //data[index]가 날짜별 갯수
                                //data[index].keys는 갯수들
                              ],
                              crossAxisAlignment: CrossAxisAlignment.end,
                            ),
                          ),
                        ),
                      ],
                    ),
                    decoration: BoxDecoration(
                        border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 3,
                            ))),
                  ),
              ],
            ),
          );
        });
  }
}