import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BlockedUser extends StatefulWidget {
  const BlockedUser({Key? key}) : super(key: key);

  @override
  _BlockedUserState createState() => _BlockedUserState();
}

class _BlockedUserState extends State<BlockedUser> {
  var sharedPreferences;
  var blockid;

  checkLoginStatus() async {
    sharedPreferences = await SharedPreferences.getInstance();
    blockid = sharedPreferences.getStringList('blockid');
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (blockid == null)
      return Scaffold(
        body: Center(child: CircularProgressIndicator())
      );
    else
    return Scaffold(
      appBar: AppBar(
        title: Text('차단된 사용자 목록'),
        backgroundColor: Color.fromRGBO(122, 154, 130, 1),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
        actionsIconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: ListView(
        children: [
          for (var i in blockid)
            if (i != '')
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: InkWell(
                  child: Container(
                      child: Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 25,
                      ),
                      Text(i,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              )),
                    ],
                  )),
                  onLongPress: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('차단 해제'),
                          content: Text('$i님을 차단해제합니다'),
                          actions: [
                            FlatButton(
                              onPressed: ()  {
                                blockid.removeWhere((item) => item == i);
                                sharedPreferences.setStringList(
                                    'blockid', blockid);
                                setState(() {});
                                Navigator.pop(context);
                              },
                              child: Text('예'),
                            ),
                            FlatButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('아니오')),
                          ],
                        );
                      },
                    );
                  },
                ),
              )
        ],
      ),
    );
  }
}
