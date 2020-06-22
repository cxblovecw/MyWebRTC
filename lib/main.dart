import 'package:MyWebRTC/callRequest.dart';
import 'package:MyWebRTC/video.dart';
import 'package:flutter/material.dart';
import 'websocket.dart';
import 'dart:convert';

main()=>{runApp(Home())};

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  static GlobalKey<NavigatorState> navigatorKey=GlobalKey();
  String myAccount="";
  String friendAccount="";
  MySocketChannel msc;
  bool isCalling=false;
  mapToString(Map value){
    return JsonEncoder().convert(value);
  }
  stringToMap(String str){
    return JsonDecoder().convert(str);
  }
  @override
  void initState() { 
    super.initState();
    msc=MySocketChannel("ws://172.30.92.225:3000");
    // msc=MySocketChannel("ws://192.168.1.12:3000");
    // msc.connect();
    MySocketChannel.stream.listen((event) {
    event=stringToMap(event);
    if(event['type']=='callRequest'){
      var content=event['content'];
      friendAccount=content['from'];
      navigatorKey.currentState.push(MaterialPageRoute(builder: (context){
        // 这里直接使用了发送过来的结果 因此这里的to是自身
        return CallRequest(content['to'],content['from']);
      }));
    }
    });
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: "主页",
      home:Scaffold(
        appBar: AppBar(
          title: Text("主页"),
        ),
        body: Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: TextField(
                    onChanged: (value){
                      setState(() {
                        myAccount=value;
                      });
                    },
                  ),),
                  FlatButton(onPressed: (){
                    // msc.connect();
                    MySocketChannel.send('connect',{
                      'account':myAccount
                    });
                  }, child: Text("登录"))
                ],
              ),
              Container(height: 30,),
              Row(children: <Widget>[
                Expanded(child: TextField(
                    onChanged: (value){
                      setState(() {
                        friendAccount=value;
                      });
                    },
                  ),),
                  // GestureDetector(
                  //   child: Text("视频通话"),
                  //   onTap: goVideo()
                  // ),
                  GoVideo(myAccount,friendAccount)
              ],)
            ],
          ),
        ),
      ),
    );
  }
}


class GoVideo extends StatelessWidget {
  String myAccount;
  String friendAccount;
  GoVideo(this.myAccount,this.friendAccount);
  @override
  Widget build(BuildContext context) {
    return OutlineButton(onPressed: (){
      Navigator.push(context,MaterialPageRoute(builder: (context){
        return Builder(builder: (context){
          return Video(true,myAccount,friendAccount,'sender');
        });
      }));
    }, child: Text("视频通话"));
  }
}