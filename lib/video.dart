import 'rtc_signaling.dart';
import 'package:MyWebRTC/websocket.dart';
import 'package:flutter/material.dart';
import "package:flutter_webrtc/webrtc.dart";
import 'package:web_socket_channel/io.dart';

class Video extends StatefulWidget {
  String role;
  bool isVideo;
  String myAccount;
  String friendAccount;
  Video(this.isVideo, this.myAccount, this.friendAccount, this.role);
  @override
  _VideoState createState() => _VideoState();
}

class _VideoState extends State<Video> {
  // 是否静音
  bool isMute = false;
  // 麦克风是否可用
  bool noSpeaking = false;
  // 是否切换大小屏
  bool switchView = false;
  // 信令对象
  RTCSignaling rtcSignaling;
  //是否处于通话
  bool isCalling = false;
  // 我的屏幕
  // static Widget me;
  // 好友屏幕
  // static Widget friend=Container();
  static RTCVideoRenderer localRenderer = RTCVideoRenderer();
  // 对端媒体视频窗口
  static RTCVideoRenderer remoteRenderer = RTCVideoRenderer();
  @override
  void initState() {
    super.initState();
    initStateAsync();
  }

  @override
  void deactivate() {
    super.deactivate();
    // if (rtcSignaling != null) rtcSignaling.close();
  
    // if (remoteRenderer != null) {
    //   remoteRenderer.srcObject = null;
    //   // remoteRenderer.dispose();
    //   remoteRenderer=null;
    // }
    //  localRenderer.srcObject = null;
    // localRenderer.dispose();
  }

  initStateAsync() async {
    await localRenderer.initialize();
    await remoteRenderer.initialize();
    var localStream = await createStream();
    localRenderer.srcObject = localStream;
    MySocketChannel.stream.listen((event){
      event = stringToMap(event);
      var type = event['type'];
      var content = event['content'];
      if (type == 'callResult') {
        if (content['result'] == 'reject') {

        }else if (content['result'] == 'agree') {
        //   rtcSignaling = RTCSignaling(
        // "ws://192.168.1.12:3000", widget.myAccount, widget.friendAccount,localStream);
        rtcSignaling = RTCSignaling(
        "ws://172.30.92.225:3000", widget.myAccount, widget.friendAccount,localStream);
         rtcSignaling.onAddRemoteStream = getRemoteStream;
         rtcSignaling.returnPeerConnection(localStream).then((pc) => {
          rtcSignaling.connect(),
          rtcSignaling.sendOffer(pc),
         });
         
        }
      }
    });
    if (widget.role == 'sender') {
      MySocketChannel.send('callRequest',{
        'from': widget.myAccount,
        'to': widget.friendAccount,
      });
    } else if(widget.role == 'receiver'){
      if(rtcSignaling==null){
        // rtcSignaling = RTCSignaling(
        // "ws://192.168.1.12:3000", widget.myAccount, widget.friendAccount,localStream);
        rtcSignaling = RTCSignaling(
        "ws://172.30.92.225:3000", widget.myAccount, widget.friendAccount,localStream);
      }
      rtcSignaling.onAddRemoteStream = getRemoteStream;
      rtcSignaling.returnPeerConnection(localStream).then((value) =>rtcSignaling.connect() );
      }

  }
  getRemoteStream(stream){
    setState(() {
      remoteRenderer.srcObject=stream;
    });
  }
  Future<MediaStream> createStream() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'mandatory': {
          // 'minWidth':'640', 
          // 'minHeight': '480',
          'minFrameRate': '30',
        },
        'facingMode': 'user',
        'optional': [],
      }
    };
    MediaStream stream = await navigator.getUserMedia(mediaConstraints);
    return stream;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: switchView
                ? RTCVideoView(localRenderer)
                : RTCVideoView(remoteRenderer)
          ),
          // 顶部按钮组
          Positioned(
            top: 30,
            left: 0,
            right: 0,
            child: Container(
                child: Row(
              children: <Widget>[
                // 最小化按钮
                IconButton(
                    icon: Icon(Icons.settings_overscan, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).pop();
                    }),
                Expanded(child: Container()),
                // 切换前后摄像头
                IconButton(
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    onPressed: () {
                      // AgoraRtcEngine.switchCamera();
                    }),
              ],
            )),
          ),
          //  小屏显示屏幕
          Positioned(
            top: 85,
            right: 5,
            child: GestureDetector(
              onTap: () {
                print("改变状态");
                setState(() {
                  switchView = !switchView;
                });
              },
              child: Container(
                width: 150,
                height: 180,
                child: AnimatedSwitcher(
                  duration: Duration(seconds: 5),
                  child: !switchView
                      ? RTCVideoView(localRenderer):RTCVideoView(remoteRenderer)
                          
                ),
              ),
            ),
          ),
          // ),),
          // 包含插件返回的Widget不知道为啥事件没法触发 因此使用这个透明遮罩触发事件
          // Positioned(
          //     top: 85,
          //     right: 5,
          //     child: GestureDetector(
          //       onTap: () {},
          //       child: Container(
          //           color: Colors.transparent,
          //           width: 120,
          //           height: 180,
          //           child: Container(
          //             color: Colors.yellow,
          //           )),
          //     )),
          // 顶部按钮组
          Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(30, 0, 30, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // 控制麦是否打开
                    Container(
                      alignment: Alignment.center,
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          color: noSpeaking ? Colors.blue : Colors.black26,
                          borderRadius: BorderRadius.circular(35)),
                      child: IconButton(
                          icon: Icon(noSpeaking ? Icons.mic_off : Icons.mic,
                              color: Colors.white),
                          onPressed: () {
                            setState(() {
                              noSpeaking = !noSpeaking;
                            });
                            // AgoraRtcEngine.muteLocalAudioStream(noSpeaking);
                          }),
                    ),
                    // 关闭通话
                    Container(
                      height: 70,
                      width: 70,
                      margin: EdgeInsets.only(left: 25, right: 25),
                      decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(35)),
                      child: IconButton(
                          icon: Icon(Icons.local_phone, color: Colors.white),
                          onPressed: () {
                            // 离开频道
                            // AgoraRtcEngine.leaveChannel();
                            // 销毁AgoraRtcEngine实例对象
                            // AgoraRtcEngine.destroy();
                            // 传递进来的方法 目的是控制最小化之后的浮动按钮的显示 但是在这里控制不了外部的state 将方法传递进来 然后调用即可控制
                            // widget.closeCall();
                         
                            Navigator.of(context).pop();
                          }),
                    ),
                    //  是否静音
                    Container(
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: isMute ? Colors.blue : Colors.black26,
                            borderRadius: BorderRadius.circular(35)),
                        child: IconButton(
                            icon: Icon(
                                isMute ? Icons.volume_off : Icons.volume_up,
                                color: Colors.white),
                            onPressed: () {
                              setState(() {
                                isMute = !isMute;
                              });
                              // AgoraRtcEngine.muteAllRemoteAudioStreams(isMute);
                            })),
                  ],
                ),
              ))
        ],
      ),
    ));
  }
}