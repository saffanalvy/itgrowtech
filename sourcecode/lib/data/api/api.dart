//Setting up the Dio HTTP client and logger in the Api class
//Making this class seperate for reusability purpose purpose

import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class Api {
  final Dio _dio = Dio();

  Api(){
    _dio.interceptors.add(PrettyDioLogger());
  }

  Dio get makeApiCall => _dio;
}