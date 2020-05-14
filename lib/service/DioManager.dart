import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import '../config/global_config.dart';
import 'result_code.dart';
import 'ekpUtil.dart';

/*
 * 网络请求管理类
 */
class DioManager {

  //写一个单例
  //在 Dart 里，带下划线开头的变量是私有变量
  static DioManager _instance;

  static DioManager getInstance() {
    if (_instance == null) {
      _instance = DioManager();
    }
    return _instance;
  }
  Dio dio = new Dio();
  CookieJar cookieJar=CookieJar();
  var baseUrl=GlobalConfig.baseUrl;

  DioManager() {
//    var baseUrl=GlobalConfig.baseUrl;
    // Set default configs
    dio.options.headers = {
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
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = 5000;
    dio.options.receiveTimeout = 3000;



//    dio.interceptors.add(LogInterceptor(responseBody: GlobalConfig.isDebug)); //是否开启请求日志
    dio.interceptors.add(CookieManager(cookieJar));//cookie
    cookieJar.loadForRequest(Uri.parse(baseUrl));




  }

  Dio getDio(){
    return dio;
  }

  CookieJar getCookieJar(){
    return cookieJar;
  }

  loginEkp() async {
//    String baseUrl = "http://ekp.king-long.com.cn";
    print(Uri.parse(baseUrl));
    var dio = Dio();
    var cookieJar = CookieJar();
    dio.interceptors.add(CookieManager(cookieJar));
//     Print cookies
    List<Cookie> cookieList=[];
    print("first");
    // cookieList=cookieJar.loadForRequest(Uri.parse(baseUrl));
    // print(cookieList);
    // cookieJar.saveFromResponse(Uri.parse(baseUrl), cookieList);
    // print(cookieList);
    // second request with the cookie

    var options = dio.options;
    options.baseUrl=baseUrl;

    print("head");
    print(await dio.head("/login.jsp"));
    print("second");
    cookieList=cookieJar.loadForRequest(Uri.parse(baseUrl));
    print(cookieList);
//                      cookieJar.saveFromResponse(Uri.parse(baseUrl), cookieList);
//                      print(cookieList);

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

//                      options.followRedirects=true;
    options.validateStatus=(status)=> status >= 200;
//                      print(await dio.post(baseUrl+"/whereis.jsp"));
    try{
    Response response=await dio.post("/j_acegi_security_check",data:postData);
    print("**********************************");
    print(response.redirects);
    }catch(e){
    print(e.toString());
//                        throw e;
    }

    print(await dio.get("/whereis.jsp"));
//                      dio.close();
    print(cookieJar.loadForRequest(Uri.parse("http://ekp.king-long.com.cn")));
    dio.close();
  }

  //get请求
  get(String url, Map<String,dynamic> params,Function successCallBack,Function errorCallBack) async {
    _requstHttp(url, successCallBack, 'get', params, errorCallBack);
  }

  //post请求
  post(String url, params,Function successCallBack,Function errorCallBack) async {
    _requstHttp(url, successCallBack, "post", params, errorCallBack);
  }

  _requstHttp(String url, Function successCallBack,
      [String method, Map<String,dynamic> params, Function errorCallBack]) async {
    Response response;
    try {
      if (method == 'get') {
        if (params != null && params.isNotEmpty) {
          response = await dio.get(url, queryParameters: params);
        } else {
          response = await dio.get(url);
        }
      } else if (method == 'post') {
        if (params != null && params.isEmpty) {
          response = await dio.post(url, data: params);
        } else {
          response = await dio.post(url);
        }
      }
    }on DioError catch(error) {
      // 请求错误处理
      Response errorResponse;
      if (error.response != null) {
        errorResponse = error.response;
      } else {
        errorResponse = new Response(statusCode: 666);
      }
      // 请求超时
      if (error.type == DioErrorType.CONNECT_TIMEOUT) {
        errorResponse.statusCode = ResultCode.CONNECT_TIMEOUT;
      }
      // 一般服务器错误
      else if (error.type == DioErrorType.RECEIVE_TIMEOUT) {
        errorResponse.statusCode = ResultCode.RECEIVE_TIMEOUT;
      }

      // debug模式才打印
      if (GlobalConfig.isDebug) {
        print('请求异常: ' + error.toString());
        print('请求异常url: ' + url);
        print('请求头: ' + dio.options.headers.toString());
        print('method: ' + dio.options.method);
      }
      _error(errorCallBack, error.message);
      return '';
    }
    // debug模式打印相关数据
    if (GlobalConfig.isDebug) {
      print('请求url: ' + url);
      print('请求头: ' + dio.options.headers.toString());
      if (params != null) {
        print('请求参数: ' + params.toString());
      }
      if (response != null) {
        print('返回参数: ' + response.toString());
      }
    }
    String dataStr = json.encode(response.data);
    print("dataStr=$dataStr");
    Map<String, dynamic> dataMap = json.decode(dataStr);
    if (dataMap == null || dataMap['state'] == 0) {
      _error(errorCallBack, '错误码：' + dataMap['errorCode'].toString() + '，' + response.data.toString());
    }else if (successCallBack != null) {
      successCallBack(dataMap);
    }
  }
  _error(Function errorCallBack, String error) {
    if (errorCallBack != null) {
      errorCallBack(error);
    }
  }
}