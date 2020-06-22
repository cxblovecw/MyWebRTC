import 'package:MyWebRTC/video.dart';
import 'package:MyWebRTC/websocket.dart';
import 'package:flutter/material.dart';


class CallRequest extends StatefulWidget {
  String myAccount;
  String friendAccount;
  CallRequest(this.myAccount,this.friendAccount);
  @override
  _CallRequestState createState() => _CallRequestState();
}

class _CallRequestState extends State<CallRequest> {
  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(child: Container()),
            Row(children: <Widget>[
              IconButton(icon: Icon(Icons.phone),color: Colors.red, onPressed: (){
                MySocketChannel.send('callResult',{
                  'from':widget.myAccount,
                  'to':widget.friendAccount,
                  'result':'reject'
                });
              }),
              IconButton(icon: Icon(Icons.videocam),color:Colors.green, onPressed: (){
                MySocketChannel.send('callResult',{
                  'from':widget.myAccount,
                  'to':widget.friendAccount,
                  'result':'agree'
                });
                Navigator.of(context).push(MaterialPageRoute(builder: (context){
                  return Video(true,widget.myAccount,widget.friendAccount,'receiver');
                }));
              }),
            ],)
          ],
        ),
      ),
    );
  }
}