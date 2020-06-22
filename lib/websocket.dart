import 'package:web_socket_channel/io.dart';
import 'dart:convert';

class MySocketChannel{
  static IOWebSocketChannel channel;
  static Stream stream;
  String url;
  MySocketChannel(this.url){
    channel=IOWebSocketChannel.connect(url);
    stream=channel.stream.asBroadcastStream();
  }
  // connect()async{
    
  // }
  static void send(type, content) {
    if (channel != null) channel.sink.add(mapToString({
      'type':type,
      'content':content
    }));
  }

}  
mapToString(Map value){
return JsonEncoder().convert(value);
}
stringToMap(String str){
  return JsonDecoder().convert(str);
}