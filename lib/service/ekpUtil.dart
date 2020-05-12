
import 'package:flutter_des/flutter_des.dart';
import 'DioManager.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/global_config.dart';

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

  static loginEkp() async{
    print('http request accour...');
    DioManager dioManager=DioManager.getInstance();
    Dio dio=dioManager.getDio();
    Response response=await dio.head("/login.jsp");

    CookieJar cookieJar=dioManager.getCookieJar();
    List<Cookie> cookieList=cookieJar.loadForRequest(Uri.parse("http://ekp.king-long.com.cn"));
    print(cookieList);

    String jSessionId=EkpUtil.getJSessionIdFromCookie(cookieList.toString());
    String encryptedPwd=await EkpUtil.getEncryptedPasswd("kinglong@2019",jSessionId);
    print(encryptedPwd);


    String baseUrl=GlobalConfig.baseUrl;
    var postData={
      'j_username': 'admin',
      'j_password': encryptedPwd,
      'j_redirectto': baseUrl+'/whereis.jsp',
      'j_lang': 'zh-CN'
    };

    var options = dio.options;

    var headers_base = {
      'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
      'Accept-Encoding': 'gzip, deflate',
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
      'Cache-Control': 'max-age=0',
      'Connection': 'keep-alive',
      'Content-Type': 'application/x-www-form-urlencoded',
      'Host': 'ekp.king-long.com.cn',
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.110 Safari/537.36',
      'Referer': baseUrl+'/login.jsp',
      'Origin': baseUrl,
      'Upgrade-Insecure-Requests': '1'
    };
    options.headers.addAll(headers_base);


    print("##################################################");
    print(options.headers);
    print("##################################################");
    options.validateStatus=(status)=> status >= 200;
    try{
      print(postData);
      Response response=await dio.post("/j_acegi_security_check",data:postData);
      print(response.statusCode);
      print("**********************************");
      print(response.headers);
      print(response.data);
    }catch(e){
      print(e.toString());
    }
//    print(await dio.get("/whereis.jsp"));
//    dio.close();
    print(cookieJar.loadForRequest(Uri.parse("http://ekp.king-long.com.cn")));
  }
}