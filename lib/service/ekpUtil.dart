import 'package:flutter_des/flutter_des.dart';

class EkpUtil{
  static Future getEncryptedPasswd (String passwd,String jSessionId) async{
    String key=jSessionId.substring(0,8);
    String iv=jSessionId.substring(8,16);
    print("------------");
    print(key);
    print(iv);
    String result = await FlutterDes.encryptToBase64(passwd, key, iv: iv);
    print(result);
    return '\u4445\u5320\u4D45'+result;

  }

  static String getJSessionIdFromCookie(String cookies){
    String key="JSESSIONID=";
    int index=cookies.indexOf(key);
    return index>-1?cookies.substring(index+key.length,cookies.indexOf(";",index)):"";
  }
}