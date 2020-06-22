// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:flutter/material.dart';
// class VoiceCall extends StatefulWidget {
//   Function closeCall;
//   VoiceCall(this.closeCall);
//   @override
//   _VoiceCallState createState() => _VoiceCallState();
// }

// class _VoiceCallState extends State<VoiceCall> {
//   bool isMute=false;
//   bool noSpeaking=false;
//   @override
//   Widget build(BuildContext context) {
//       return MaterialApp(
//       home: Scaffold(
//         body: Stack(
//           alignment: Alignment.center,
//           children: <Widget>[
//             Container(
//               width: double.infinity,
//               height: double.infinity,
//               decoration: BoxDecoration(
//                 color:Colors.yellow
//               ),
//             ),
//             Positioned(
//               left: 0,
//               top: 30,
//               child: IconButton(icon:Icon(Icons.arrow_back_ios),onPressed:() {
//                 Navigator.of(context).pop();
//             })),
//             Positioned(
//               top: 250,
//               child:Container(
//                 width: 120,
//                 height: 120,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(60),
//                   image: DecorationImage(image:NetworkImage("https://c-ssl.duitang.com/uploads/item/201803/19/20180319132911_UxCLe.jpeg"))
//           	  ),
//             ),),
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child:Container(
//                 padding: EdgeInsets.fromLTRB(30, 0, 30,20),
//                 child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: <Widget>[
//                    Container(
//                     alignment: Alignment.center,
//                     height: 70,
//                     width: 70,
//                     decoration: BoxDecoration(
//                       color: noSpeaking?Colors.blue:Colors.black26,
//                       borderRadius: BorderRadius.circular(35)
//                     ),
//                     child:IconButton(icon: Icon(noSpeaking?Icons.mic_off:Icons.mic,color:Colors.white), onPressed:(){
//                       setState(() {
//                         noSpeaking=!noSpeaking;  
//                       });
//                       AgoraRtcEngine.muteLocalAudioStream(noSpeaking);
//                   }),),
//                    Container(
//                     height: 70,
//                     width: 70,
//                     margin: EdgeInsets.only(left: 25,right: 25),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(35)
//                     ),
//                     child:IconButton(icon: Icon(Icons.local_phone,color: Colors.white), onPressed: (){
//                       AgoraRtcEngine.disableAudio();
//                       AgoraRtcEngine.leaveChannel();
//                       widget.closeCall();
//                       Navigator.of(context).pop();
//                   }),),
//                    Container(
//                     height: 70,
//                     width: 70,
//                     decoration: BoxDecoration(
//                       color: isMute?Colors.blue:Colors.black26,
//                       borderRadius: BorderRadius.circular(35)
//                     ),
//                     child:IconButton(icon: Icon(isMute?Icons.volume_off:Icons.volume_up,color:Colors.white), onPressed: (){
//                       setState(() {
//                         isMute=!isMute;
//                       });
//                       print("是否禁音");
//                       AgoraRtcEngine.muteAllRemoteAudioStreams(isMute);
//                   })),
//                 ],
//               ),
//               ))
//           ],
//         ),
//       ),
//     );
//   }
// }