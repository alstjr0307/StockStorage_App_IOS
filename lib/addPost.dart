import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:html_editor_enhanced/html_editor.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import 'HomePage.dart';

class AddPost extends StatefulWidget {
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool asTabs = false;
  late String selectedValue;

  List<int> selectedItems = [];
  static const String appTitle = "Search Choices demo";
  final String loremIpsum = "Lorem sdf sdfipsum dsf sdf dolor";

  final List<DropdownMenuItem> items = [];
  Future logging() async {
    await analytics.setCurrentScreen(
      screenName: '글쓰기',
      screenClassOverride: '글쓰기',
    );
  } //앱
  String result = '';
  HtmlEditorController controller = HtmlEditorController();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  late String category;

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
    _loadFromAsset();
    logging();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(240, 175, 142,100),
        iconTheme: IconThemeData(color: Colors.black, size: 40),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                minimumSize: Size(50, 30),
                alignment: Alignment.centerLeft),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: new Text("초기화"),
                    content: new Text("내용을 초기화하시겠습니까?"),
                    actions: <Widget>[
                      new FlatButton(
                        child: new Text("네"),
                        onPressed: () {
                          Navigator.pop(context);
                          controller.clear();
                        },
                      ),
                      new FlatButton(
                        child: new Text("취소"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  color: Colors.red,
                  border: Border.all(width: 1.0, color: Colors.red),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Text('초기화', style: TextStyle(color: Colors.white))),
          ),
          TextButton(
            style: TextButton.styleFrom(
                padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                minimumSize: Size(50, 30),
                alignment: Alignment.centerLeft),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: new Text("작성 완료"),
                    content: new Text("글을 업로드 하시겠습니까?"),
                    actions: <Widget>[

                      new FlatButton(
                        child: new Text("취소"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      new FlatButton(
                        child: new Text("네"),
                        onPressed: () async {
                          final txt = await controller.getText();
                          Navigator.pop(context);
                          await addPost(titleController.text, txt, 'f');

                        },
                      ),
                    ],
                  );
                },
              );
            },
            child: Container(
                padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                decoration: BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.rectangle,
                  border: Border.all(width: 1.0, color: Colors.white),
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
                child: Text('등록', style: TextStyle(color: Colors.white))),
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: "제목을 입력해주세요",
                  ),
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                HtmlEditor(
                  controller: controller,
                  htmlEditorOptions: HtmlEditorOptions(
                    hint: '내용을 입력해주세요',
                    shouldEnsureVisible: true,
                    //initialText: "<p>text content initial, if any</p>",
                  ),
                  htmlToolbarOptions: HtmlToolbarOptions(
                    defaultToolbarButtons: [
                      InsertButtons(),
                      FontSettingButtons(),
                      ColorButtons(),
                      ParagraphButtons(),
                    ],
                    toolbarPosition: ToolbarPosition.aboveEditor,
                    //by default
                    toolbarType: ToolbarType.nativeExpandable,
                    //by default

                    mediaLinkInsertInterceptor:
                        (String url, InsertFileType type) {
                      print(url);
                      return true;
                    },
                    mediaUploadInterceptor:
                        (PlatformFile file, InsertFileType type) async {
                      print(file.name); //filename
                      print(file.size); //size in bytes
                      print(file.extension); //file extension (eg jpeg or mp4)
                      return true;
                    },
                  ),
                  otherOptions: OtherOptions(height: 500),

                  //this is commented because it overrides the default Summernote handlers
                  /*onImageLinkInsert: (String? url) {
                    print(url ?? "unknown url");
                  },
                  onImageUpload: (FileUpload file) async {
                    print(file.name);
                    print(file.size);
                    print(file.type);
                    print(file.base64);
                  },*/
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 40,
              ),
            ],
          )
        ],
      ),
    );
  }

  Future<void> addPost(String title, String content, String category) async {

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          child: new Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              new CircularProgressIndicator(),
              new Text("글 작성완료중"),
            ],
          ),
        );
      },
    );
    var sharedPreferences = await SharedPreferences.getInstance();
    var token = sharedPreferences.getString("token");

    var now = new DateTime.now();
    var str = DateFormat("yyyy-MM-ddTHH:mm:ss").format(now);
    category = "F";
    var pushtoken =  sharedPreferences.getString('pushtoken');
    print(pushtoken.toString()+'푸시');
    final responseerw = await http.post(
        Uri.http('13.125.62.90', "api/v1/BlogPosts/"),
        headers: {
          "Authorization": "Token ${token}",
          "Content-Type": "application/json"
        },
        body: jsonEncode(
          <String, dynamic>{
            "title": title,
            "content": content,
            "slug": "none",
            "description": "none",
            "create_dt": str,
            "modify_dt": str,
            "category": category,
            "owner": sharedPreferences.getInt('userID'),
            "pushtoken" : pushtoken,
          },
        ));
    if (responseerw.statusCode == 201) {
      var postid = jsonDecode(responseerw.body)["id"];
      print(responseerw.body);


      for (var i = 0; i < selectedItems.length; i++) {
        print(items[selectedItems[i]].value.toString());
        final tagpost =
            await http.post(Uri.http('13.125.62.90', 'api/v1/TaggitTag/'),
                headers: {
                  "Authorization": "Token ${token}",
                  "Content-Type": "application/json",
                },
                body: jsonEncode(<String, dynamic>{
                  "slug": items[selectedItems[i]].value.toString() + 'z',
                  "name": items[selectedItems[i]].value.toString()
                }));
        if (tagpost.statusCode == 201) {
          var tagid = jsonDecode(tagpost.body)["id"];
          print('태그 새로추가 태그아이디는 ${tagid}');
          final taggit = await http.post(
            Uri.http('13.125.62.90', 'api/v1/TaggitTaggedItem/'),
            headers: {
              "Authorization": "Token ${token}",
              "Content-Type": "application/json"
            },
            body: jsonEncode(<String, dynamic>{
              "object": postid,
              "content_type": 14,
              "tag": tagid
            }),
          );
        } else if (tagpost.statusCode == 400) {

          var tagg = await http.get(
            Uri.http('13.125.62.90', 'api/v1/TaggitTag/',
                {"name": items[selectedItems[i]].value}),
            headers: {
              "Authorization": "Token ${token}",
              "Content-Type": "application/json"
            },
          );
          var tagid = jsonDecode(tagg.body)[0]['id'];
          final taggit = await http.post(
            Uri.http('13.125.62.90', 'api/v1/TaggitTaggedItem/'),
            headers: {
              "Authorization": "Token ${token}",
              "Content-Type": "application/json"
            },
            body: jsonEncode(<String, dynamic>{
              "object": postid,
              "content_type": 14,
              "tag": tagid
            }),
          );
        }
      }
      Navigator.pop(context);
      Navigator.pop(context);
    } else {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: new Text("오류"),
            content: new Text("제목과 내용을 비워두지 마세요!"),
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
    }
  }

  dynamic myEncode(dynamic item) {
    if (item is DateTime) {
      return item.toIso8601String();
    }
    return item;
  }
}
