import 'package:flutter/material.dart';
import 'TagPostList.dart';

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:back_button_interceptor/back_button_interceptor.dart';

class Storage extends StatefulWidget {
  @override
  _StorageState createState() => _StorageState();
}

class _StorageState extends State<Storage>  {
  TextEditingController controller = new TextEditingController();


  var json;

  @override
  Widget build(BuildContext context) {
    return LoadData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadFromAsset();
  }

  Future<String> _loadFromAsset() async {
    final String data = await rootBundle.loadString("assets/KStock.json");
    json = jsonDecode(data);
    setState(() {
      for (Map<String, dynamic> stock in json) {
        _stocks.add(Stocks.fromJson(stock));
      }
    });
    return data;
  }

  @override
  Widget LoadData() {
    return new Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white, size: 40),
        backgroundColor: Color.fromRGBO(122, 154, 130, 1),
        title: Text('종목저장소'),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            color: Color.fromRGBO(122, 154, 130, 1),
            child: new Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                child: new ListTile(
                  leading: new Icon(Icons.search),
                  title: new TextField(

                    controller: controller,

                    decoration: new InputDecoration(
                        fillColor: Colors.white,
                        hintText: '종목 검색', border: InputBorder.none),
                    onChanged: onSearchTextChanged,

                  ),
                  trailing: new IconButton(
                    icon: new Icon(Icons.cancel),
                    onPressed: () {
                      controller.clear();
                      onSearchTextChanged('');
                    },
                  ),
                ),
              ),
            ),
          ),
          new Expanded(
            child: _searchResult.length != 0 || controller.text.isNotEmpty
                ? new ListView.builder(
              itemCount: _searchResult.length,
              itemBuilder: (context, i) {
                return new Card(
                  child: InkWell(
                    child: new ListTile(
                      title: new Text(_searchResult[i].name),
                      subtitle: Text(_searchResult[i].descrip),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => StoragePost(
                                  tag: _searchResult[i].name)));
                    },
                  ),
                  margin: const EdgeInsets.all(0.0),
                );
              },
            )
                : new ListView.builder(
              itemCount: _stocks.length,
              itemBuilder: (context, index) {
                return new Card(
                  child: InkWell(
                    child: new ListTile(
                      title: new Text(_stocks[index].name),
                      subtitle: new Text(_stocks[index].descrip),
                    ),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  StoragePost(tag: _stocks[index].name)));
                    },
                  ),
                  margin: const EdgeInsets.all(0.0),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    _stocks.forEach((_stocks) {
      if (_stocks.name.contains(text) || _stocks.descrip.contains(text))
        _searchResult.add(_stocks);
    });

    setState(() {});
  }
}

List<Stocks> _searchResult = [];

List<Stocks> _stocks = [];

class Stocks {
  final String name, descrip;

  Stocks({required this.name, required this.descrip});

  factory Stocks.fromJson(Map<String, dynamic> json) {
    return new Stocks(
      name: json['name'],
      descrip: json['market'],
    );
  }
}