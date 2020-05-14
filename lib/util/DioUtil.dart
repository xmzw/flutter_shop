/*
 *Dio网络请求的工具类
 */

import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';

class DioUtil {
  Dio dio;
  Dio tokenDio = new Dio();
  static DioUtil _instance;

  static DioUtil getInstance() {
    if (_instance == null) {
      _instance = DioUtil();
    }
    return _instance;
  }

  //get方法
  Future<Response> get(url, {data, options, cancelToken}) async {
    String accessToken = DataUtil.getAccessToken; //获取当前的accessToken
    String refreshToken = DataUtil.getRefreshToken; //获取当前的refreshToken

    options = BaseOptions(
      connectTimeout: 15000,
      headers: {},
    );

    dio = new Dio(options);

    //添加自定义的token拦截器
    dio.interceptors.add(new TokenInterceptor());

    Response response;
    try {
      response = await dio.get(url, cancelToken: cancelToken);
    } on DioError catch (e) {
      print(e.response.data);
    }
    return response;
  }

}


class TokenInterceptor extends Interceptor {
  @override
  onError(DioError error) async {
    if (error.response != null && error.response.statusCode == 401) { //401代表token过期
      Dio dio = DioUtil().dio;//获取Dio单例
      dio.lock();
      String accessToken = await getToken(); //异步获取新的accessToken
      DataUtil.saveAccessToken(accessToken); //保存新的accessToken
      dio.unlock();

      //重新发起一个请求获取数据
      var request = error.response.request;
      try {
        var response = await dio.request(request.path,
            data: request.data,
            queryParameters: request.queryParameters,
            cancelToken: request.cancelToken,
            options: request,
            onReceiveProgress: request.onReceiveProgress);
        return response;
      } on DioError catch (e) {
        return e;
      }
    }
    super.onError(error);
  }


  Future<String> getToken() async {
    String accessToken = DataUtil.getAccessToken; //获取当前的accessToken
    String refreshToken = DataUtil.getRefreshToken; //获取当前的refreshToken


    Dio dio =DioUtil.getInstance().tokenDio; ////创建新Dio实例

    dio.options.headers['x-access-token'] = accessToken;//设置当前的accessToken

    try {
      String url = url; //refreshToken url
      var response = await dio.get(url,options: options); //请求refreshToken刷新的接口
      accessToken = response.data['access_token']; //新的accessToken
      refreshToken = response.data['refresh_token'];//新的refreshToken
      DataUtil.saveRefreshToken(refreshToken); //保存新的refreshToken
    } on DioError catch (e) {
      if (e.response == null) {
      } else {
        eventBus.fire(new LoginEvent("Login"));//refreshToken过期，eventBus弹出登录页面
      }
    }
    return accessToken;
  }

}