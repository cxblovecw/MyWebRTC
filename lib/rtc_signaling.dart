import 'package:MyWebRTC/websocket.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'dart:convert';

enum SignalingState{
  CallStateConnect,
  CallStateBye,
  ConnectionOpen,
  ConnectionClosed,
  ConnectionError,
}

// 信令状态的回调
typedef SignalingStateCallback(SignalingState state);
// 媒体流的状态回调
typedef StreamStateCallback(MediaStream stream);
// 对方进入房价回调
typedef OtherEventCallback(dynamic event);

class RTCSignaling{
  final String myAccount;
  final String friendAccount;
  String url;
  MediaStream localStream;
  RTCPeerConnection pc;
  JsonDecoder decoder = new JsonDecoder();
  SignalingStateCallback onStateChange;
  StreamStateCallback onLocalStream;
  StreamStateCallback onAddRemoteStream;
  StreamStateCallback onRemoveRemoteStream;
  Map<String, dynamic> iceServers = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
  };
  final Map<String, dynamic> dtlsConfig = {
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };
  final Map<String, dynamic> offerAnswerConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [],
  };

  RTCSignaling(this.url,this.myAccount,this.friendAccount,this.localStream);
  Future returnPeerConnection(MediaStream localStream)async{
    pc = await createPeerConnection(iceServers, dtlsConfig);
    pc.addStream(localStream);
    pc.onIceCandidate=(candidate){
      MySocketChannel.send('candidate',{
        'from':myAccount,
        'to': friendAccount,
        'candidate': {
          'sdpMLineIndex': candidate.sdpMlineIndex,
          'sdpMid': candidate.sdpMid,
          'candidate': candidate.candidate,
        },
      });
    };
    pc.onAddStream = (stream) {
      if (this.onAddRemoteStream != null) this.onAddRemoteStream(stream);
    };
    pc.onRemoveStream = (stream) {
      
    };  
    return pc;
  }
  void connect(){
    try{
     MySocketChannel.stream.listen((event) {
      event = stringToMap(event);
      var type = event['type'];
      var content = event['content'];
      if (type == 'candidate') {
        Map candidateMap = content['candidate'];
        if (pc != null) {
          RTCIceCandidate candidate = new RTCIceCandidate(
            candidateMap['candidate'],
            candidateMap['sdpMid'],
            candidateMap['sdpMLineIndex']);
          pc.addCandidate(candidate);
        }
      }else if(type=='offer'){
          print("收到offer收到offer收到offer收到offer收到offer");
          var description=content['description'];
          pc.setRemoteDescription(RTCSessionDescription(description['sdp'],description['type'])).then((value)=> {sendAnswer()});
        }else if(type=='answer'){
          print("收到answer收到answer收到answer收到answer收到answer");
          var description=content['description'];
          pc.setRemoteDescription(RTCSessionDescription(description['sdp'],description['type']));
        }
    });
    }catch(e){
      print(e);
    }
  }
  void sendOffer(RTCPeerConnection pc) async{
    try {
      // 使用pc.createOffer(offerConstraints)方法 创建RTC会话描述 
      RTCSessionDescription s = await pc.createOffer(offerAnswerConstraints);
      // 设置本地描述
      pc.setLocalDescription(s);  
      //向远端发送自己的媒体信息
      MySocketChannel.send('offer',{
        'from':myAccount,
        'to': friendAccount,
        'description': {'sdp': s.sdp, 'type': s.type},
      });
    } catch (e) {
      print(e.toString());
    }
  }
  void sendAnswer()async{
    try {
      RTCSessionDescription s = await pc.createAnswer(offerAnswerConstraints);
      pc.setLocalDescription(s);
      MySocketChannel.send('answer', {
        'from':myAccount,
        'to':friendAccount ,
        'description': {'sdp': s.sdp, 'type': s.type},
      });
    } catch (e) {
      print(e.toString());
    }
  }
}