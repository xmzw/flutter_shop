import 'package:flutter/material.dart';
import '../service/http_method.dart';
import 'package:dio/dio.dart';
import 'dart:io';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import '../service/ekpUtil.dart';

class TestPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return _TestPage();
  }
}

class _TestPage extends State<TestPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 50,
        ),
        Text('$index'),
        Container(
            width: 200,
            height: 300,
            child: Column(
              children: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.repeat),
                  label: Text('click me'),
//            child: Text('click me'),
                  color: Colors.blue,
                  textColor: Colors.white,
                  elevation: 100,
                  onPressed: () {
                    setState(() {
                      index++;
                    });
                  },
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                    child: Text('get'),
                    onPressed: () async {
                      String baseUrl = "http://ekp.king-long.com.cn";
                      print(Uri.parse(baseUrl));
                      var dio = Dio();
                      var cookieJar = CookieJar();
                      dio.interceptors.add(CookieManager(cookieJar));
                      // Print cookies
                      List<Cookie> cookieList=[];
                      print("first");
                      // cookieList=cookieJar.loadForRequest(Uri.parse(baseUrl));
                      // print(cookieList);
                      // cookieJar.saveFromResponse(Uri.parse(baseUrl), cookieList);
                      // print(cookieList);
                      // second request with the cookie
                      print("head");
                      print(await dio.head(baseUrl));
                      print("second");
                      cookieList=cookieJar.loadForRequest(Uri.parse(baseUrl));
                      print(cookieList);
                      cookieJar.saveFromResponse(Uri.parse(baseUrl), cookieList);
                      print(cookieList);

                      String jSessionId=EkpUtil.getJSessionIdFromCookie(cookieList.toString());
                      String encryptedPwd=await EkpUtil.getEncryptedPasswd("kinglong@2019",jSessionId);
                      print(encryptedPwd);

                      // print(await dio.get(url+"/whereis.jsp"));
                      // print(await dio.get(url+"/whereis.jsp"));

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

                      var postData={
                        'j_username': 'admin',
                        'j_password': encryptedPwd,
                        'j_redirectto': baseUrl+'/whereis.jsp',
                        'j_lang': 'zh-CN'
                      };
                      dio.options.headers.addAll(headers_base);
                      var options = dio.options;
                      options.followRedirects=true;
                      try{
                        Response response=await dio.post(baseUrl+"/j_acegi_security_check",data:postData);
                        print("**********************************");
                        print(response.redirects);
                      }catch(e){
                        print(e.toString());
//                        throw e;
                      }

                      print(cookieJar.loadForRequest(Uri.parse(baseUrl)));
                      dio.close();
                    })
              ],
            ))
      ],
    );
  }
}
