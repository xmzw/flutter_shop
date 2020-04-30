import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:async';
import '../config/service_url.dart';


Future getHomePageContent() async{
  var params={

  };
  Dio dio = new Dio();
   Response response=await dio.post(servicePath['homePageContent'],data:params);
  if (response.statusCode==200){
    return response.data;
  }else{
    throw Exception("");
  }
}