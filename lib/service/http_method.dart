import 'package:dio/dio.dart';

class HttpMethod{
  static Future getUrl (url,{params}) async{
    var dio = new Dio();
    dio.options.contentType="application/x-www-form-urlencoded";
    Response response = null;
    if (params==null){
      response =await dio.get(url);
    }else{
      response =await dio.get(url,queryParameters:params);
    }
    if (response.statusCode==200){
      var data = response.data;
   //   print(data);
    }else{
      print("url get错误!");
      print((response.statusCode as String)+"==>"+response.statusMessage);
    }


    return response.data;
  }
  
  main(){
    HttpMethod.getUrl("http://ekp.king-long.com.cn");
  }
}