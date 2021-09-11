import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:custom_searchable_dropdown/custom_searchable_dropdown.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import 'HomePage.dart';

class Diary extends StatefulWidget {
  @override
  _DiaryState createState() => _DiaryState();
}

class _DiaryState extends State<Diary> {
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
  final typeController = TextEditingController();
  final whyController = TextEditingController();
  final countController = TextEditingController();
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

  Future diarylog() async {
    await analytics.setCurrentScreen(
      screenName: '매매일지',
      screenClassOverride: 'diary',
    );
  } //앱

  @override
  void initState() {
    super.initState();
    diarylog();
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
    priceController.dispose();
    whyController.dispose();
    typeController.dispose();
    monthController.dispose();
    countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backwardsCompatibility: false,
          toolbarHeight: 110,
          backgroundColor: Color.fromRGBO(240, 175, 142, 100),
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '매매일지',
                  style: TextStyle(
                      fontFamily: 'Strong',
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
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
                    return StatefulBuilder(builder: (context, setState) {
                      return AlertDialog(
                        content: Stack(
                          overflow: Overflow.visible,
                          children: <Widget>[
                            _InputWidget('삭제'),
                          ],
                        ),
                      );
                    });
                  });
            },
            child: Icon(Icons.add),
          ),
        ]),
        body: Container(
          color: Color.fromRGBO(240, 175, 142, 100),
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
                style: TextStyle(color: FlexColor.darkScaffoldBackground),
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
  var type;

  Widget _InputWidget(String n) {
    return SingleChildScrollView(
      child: StatefulBuilder(builder: (context, setState) {
        return Column(
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
            if (n == '삭제')
              Row(
                children: [
                  Container(
                    child: Text('종목'),
                  ),
                  Expanded(
                    child: CustomSearchableDropDown(
                      label: '클릭하여 종목 선택',
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
                  child: Container(
                    child: Text('매매종류'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: 100,
                    child: DropdownButton(
                      hint: type == null
                          ? Text('선택')
                          : Text(
                              type,
                              style: TextStyle(color: Colors.blue),
                            ),
                      isExpanded: true,
                      iconSize: 30.0,
                      style: TextStyle(color: Colors.blue),
                      items: ['매수', '매도'].map(
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
                            type = val;
                          },
                        );
                      },
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
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '단가',
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
                Container(
                  width: 100,
                  child: TextField(
                    style: TextStyle(
                      color: Colors.black,
                    ),
                    controller: countController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: '수량',
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
            SizedBox(height: 50),
            Container(
              width: 500,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  controller: whyController,
                  decoration: InputDecoration(
                    hintText: '매수/매도 이유',
                    contentPadding: const EdgeInsets.only(
                        left: 14.0, bottom: 1.0, top: 1.0),
                  ),
                ),
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
                        countController.text.isNotEmpty &&
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
                      var set = {};
                      var why = whyController.text;
                      if (whyController.text == "") {
                        why = "생략";
                      }

                      var newset = {
                        "단가": priceController.text,
                        "매매": type,
                        "이유": why,
                        "수량": countController.text
                      };
                      await firestore
                          .collection(_auth.currentUser!.uid)
                          .doc('매매일지')
                          .get()
                          .then((DocumentSnapshot ds) {
                        try {
                          set = ds[date];
                        } catch (e) {}
                      });

                      if (n == '삭제') {
                        if (set.containsKey(selectedItems)) {
                          var number = set[selectedItems].keys.toList().length;
                          var addition = number + 1;
                          set[selectedItems][addition.toString()] = newset;
                        } else {
                          set[selectedItems] = {'1': newset};
                        }
                        await firestore
                            .collection(_auth.currentUser!.uid)
                            .doc('매매일지')
                            .update({date: set});
                      } else {
                        set[selectedItems][n.toString()] = newset;
                        await firestore
                            .collection(_auth.currentUser!.uid)
                            .doc('매매일지')
                            .update({date: set});
                      }

                      countController.clear();
                      priceController.clear();
                      whyController.clear();
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
                                      if (n == '삭제')
                                        showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                content: Stack(
                                                  overflow: Overflow.visible,
                                                  children: <Widget>[
                                                    SingleChildScrollView(
                                                        child:
                                                            _InputWidget('삭제')),
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
        );
      }),
    );
  }

  Color getMyColor(String maemaee) {
    if (maemaee == "매수") {
      return Color.fromRGBO(255, 182, 193, 1);
    } else {
      return Color.fromRGBO(172, 221, 222, 10);
    }
  }

  Widget _List() {
    return new StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(_auth.currentUser!.uid)
            .doc('매매일지')
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
                        padding: const EdgeInsets.all(6.0),
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
                            color: Color.fromRGBO(96, 97, 179, 1),
                          ),
                          padding: EdgeInsets.all(10),
                        ),
                      ),
                      Expanded(
                          child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            //data[index]가 날짜별 갯수
                            //data[index].keys는 갯수들
                            for (var i in data[index].keys)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                                child: Container(
                                  child: Container(
                                    padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 80,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.rectangle,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                color: Color.fromRGBO(
                                                    137, 119, 173, 5)),
                                            child: Text(
                                              i,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Hanma',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              for (var j in data[index][i].keys)
                                                GestureDetector(
                                                  onTapDown:
                                                      (TapDownDetails details) {
                                                    double left = details
                                                        .globalPosition.dx;
                                                    double top = details
                                                        .globalPosition.dy;
                                                    showMenu(
                                                      position:
                                                          RelativeRect.fromLTRB(
                                                              left, top, 0, 0),
                                                      context: context,
                                                      items: [
                                                        PopupMenuItem(
                                                          value: 1,
                                                          child: Text("삭제"),
                                                        ),
                                                        PopupMenuItem(
                                                          value: 2,
                                                          child: Text("수정"),
                                                        ),
                                                      ],
                                                      elevation: 8.0,
                                                    ).then((value) {
// NOTE: even you didnt select item this method will be called with null of value so you should call your call back with checking if value is not null
                                                      if (value !=
                                                          null) if (value == 1)
                                                        showDialog(
                                                            context: context,
                                                            builder: (context) {
                                                              return AlertDialog(
                                                                title: Text(
                                                                    '기록 삭제'),
                                                                content: Text(
                                                                    '삭제하시겠습니까?'),
                                                                actions: [
                                                                  FlatButton(
                                                                      child: Text(
                                                                          '아니오'),
                                                                      onPressed:
                                                                          () {
                                                                        Navigator.pop(
                                                                            context);
                                                                      }),
                                                                  FlatButton(
                                                                    child: Text(
                                                                        '네'),
                                                                    onPressed:
                                                                        () async {
                                                                      Map<String,
                                                                              dynamic>
                                                                          update =
                                                                          data[
                                                                              index];

                                                                      update[i].removeWhere((key,
                                                                              value) =>
                                                                          key ==
                                                                          j);
                                                                      var keylist = update[
                                                                              i]
                                                                          .keys
                                                                          .toList();
                                                                      var newmap =
                                                                          {};
                                                                      var cou =
                                                                          1;

                                                                      for (var k
                                                                          in keylist) {
                                                                        newmap[cou
                                                                            .toString()] = update[
                                                                                i]
                                                                            [k];
                                                                        cou++;
                                                                      }

                                                                      update[i] =
                                                                          newmap;

                                                                      if (newmap.toString() ==
                                                                              '{}' &&
                                                                          update.keys.toList().length ==
                                                                              1)
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection(_auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                '매매일지')
                                                                            .update({
                                                                          index:
                                                                              FieldValue.delete()
                                                                        });
                                                                      else if (newmap
                                                                              .toString() !=
                                                                          '{}') {
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection(_auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                '매매일지')
                                                                            .update({
                                                                          index:
                                                                              update
                                                                        });
                                                                      } else {
                                                                        update.removeWhere((key,
                                                                                value) =>
                                                                            key ==
                                                                            i);
                                                                        await FirebaseFirestore
                                                                            .instance
                                                                            .collection(_auth
                                                                                .currentUser!.uid)
                                                                            .doc(
                                                                                '매매일지')
                                                                            .update({
                                                                          index:
                                                                              update
                                                                        });
                                                                      }
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                  ),
                                                                ],
                                                              );
                                                            });
                                                      if (value == 2) {
                                                        selectedItems = i;
                                                        dateController.text =
                                                            index;
                                                        priceController.text =
                                                            data[index][i][j]
                                                                ['단가'];
                                                        countController.text =
                                                            data[index][i][j]
                                                                ['수량'];
                                                        type = data[index][i][j]
                                                            ['매매'];

                                                        whyController.text =
                                                            data[index][i][j]
                                                                ['이유'];
                                                        showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return StatefulBuilder(
                                                                  builder: (context,
                                                                      setState) {
                                                                return AlertDialog(
                                                                  content:
                                                                      Stack(
                                                                    overflow:
                                                                        Overflow
                                                                            .visible,
                                                                    children: <
                                                                        Widget>[
                                                                      _InputWidget(
                                                                          j),
                                                                    ],
                                                                  ),
                                                                );
                                                              });
                                                            });
                                                      }
                                                    });
                                                  },
                                                  child: Container(
                                                    child: Card(
                                                      color: getMyColor(
                                                        (data[index][i][j]
                                                            ['매매']),
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                          children: [
                                                            Container(
                                                              padding:
                                                                  EdgeInsets
                                                                      .fromLTRB(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          5),
                                                              width: 200,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  if (data[index][i]
                                                                              [
                                                                              j]
                                                                          [
                                                                          '매매'] ==
                                                                      "매수")
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                            '매수단가: ',
                                                                            style:
                                                                                TextStyle(fontSize: 14),
                                                                          ),
                                                                          Text(
                                                                            data[index][i][j]['단가'].toString() +
                                                                                '원',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: 'Hanma',
                                                                                fontSize: 14),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  if (data[index][i]
                                                                              [
                                                                              j]
                                                                          [
                                                                          '매매'] !=
                                                                      "매수")
                                                                    Container(
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Text(
                                                                              '매도단가: ',
                                                                              style: TextStyle(fontSize: 14)),
                                                                          Text(
                                                                            data[index][i][j]['단가'].toString() +
                                                                                '원',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontFamily: 'Strong',
                                                                                fontSize: 14),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                          '수량: ',
                                                                          style:
                                                                              TextStyle(fontSize: 14)),
                                                                      Text(
                                                                          data[index][i][j]['수량'] +
                                                                              '주',
                                                                          style: TextStyle(
                                                                              fontSize: 14,
                                                                              fontFamily: 'Strong',
                                                                              fontWeight: FontWeight.bold)),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Text(
                                                              '총 ' +
                                                                  (int.parse(data[index][i][j]
                                                                              [
                                                                              '수량']) *
                                                                          int.parse(data[index][i][j]
                                                                              [
                                                                              '단가']))
                                                                      .toString() +
                                                                  '원',
                                                              style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: Colors
                                                                      .black,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontFamily:
                                                                      'Strong'),
                                                            ),
                                                            Container(
                                                              child: Card(
                                                                elevation: 10,
                                                                child:
                                                                    Container(
                                                                  width: 200,
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              10),
                                                                  child: Text(
                                                                    data[index][i][j]
                                                                            [
                                                                            '이유']
                                                                        .replaceAll(
                                                                            "\\n",
                                                                            "\n"),
                                                                    maxLines:
                                                                        40,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                  color: Color(
                                                                      0xffFFFFA5),
                                                                ),
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          )
                                        ]),
                                  ),
                                ),
                              )
                          ],
                          crossAxisAlignment: CrossAxisAlignment.end,
                        ),
                      ))
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
          ));
        });
  }
}
