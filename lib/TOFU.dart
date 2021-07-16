import 'dart:convert';
import 'dart:core';
import 'dart:core';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Tofu extends StatefulWidget {
  @override
  _TofuState createState() => _TofuState();
}

class _TofuState extends State<Tofu> {
  final _formKey = GlobalKey<FormState>();
  bool asTabs = false;
  late String selectedValue;

  final List<DropdownMenuItem> items = [];
  var selectedItems;
  String result = '';
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  final monthController = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  var json;

  Future<List> _loadFromAsset() async {
    final String data = await rootBundle.loadString("assets/KStock.json");
    var json = jsonDecode(data);
    setState(() {
      for (Map stock in json) {
        items.add(DropdownMenuItem(
          child: Text(stock["name"]),
          value: stock["name"],
        ));
      }
    });
    return items;
  }

  @override
  void initState() {
    super.initState();
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

    _loadFromAsset();
  }

  @override
  void dispose() {

    monthController.dispose();

    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backwardsCompatibility: false,
          toolbarHeight: 110,
          title: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '두부개미 추천주',
                  style: TextStyle(
                      fontFamily: 'Strong',
                      fontWeight: FontWeight.bold,
                      color: FlexColor.materialLightBackground),
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
        ],
        ),
        body: Column(
          children: [_List()],
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




  Widget _List() {
    return new StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('0re')
            .doc('추천주')
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
          var keysss = data!.keys
              .where((k) =>
          k.substring(6, 7) == monthController.text.substring(6, 7) &&
              k.substring(0, 4) ==
                  monthController.text.substring(0, 4) ||
              k.substring(5, 7) == monthController.text.substring(6, 8) &&
                  k.substring(0, 4) == monthController.text.substring(0, 4))
              .toList();
          keysss.sort();
          var keyss = List.from(keysss.reversed);
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
                                  color: Colors.black,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold),
                            ),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: FlexColor.amberDarkPrimary),
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
                                    child: Padding(
                                      padding: const EdgeInsets.all(6.0),
                                      child: Container(
                                        child: Card(
                                          color:
                                          Color.fromRGBO(225, 248, 220, 10),
                                          child: Padding(
                                            padding: const EdgeInsets.all(7.0),
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding:
                                                  const EdgeInsets.fromLTRB(
                                                      0, 0, 0, 8),
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [


                                                      Row(
                                                        children: [
                                                          Text('종목: '),
                                                          Text(
                                                            i['종목'],
                                                            style: TextStyle(
                                                                fontFamily:
                                                                'Strong',
                                                                color: Colors.black,
                                                                fontSize: 20),
                                                          )
                                                        ],
                                                      ),


                                                    ],
                                                  ),
                                                ),
                                                Row(
                                                  children: [
                                                    Text('추천단가: '),
                                                    Text(
                                                      i['추천가'],
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'Strong',
                                                          color: Colors.red,
                                                          fontSize: 20),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Text('목표가: '),
                                                    Text(
                                                      i['목표가'],
                                                      style: TextStyle(
                                                          fontFamily:
                                                          'Strong',
                                                          color: Colors.red,
                                                          fontSize: 20),
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
                                                        i['이유'].replaceAll("\\n", "\n"),
                                                        maxLines: 40,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                      color: Color(0xffFFFFA5),
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
