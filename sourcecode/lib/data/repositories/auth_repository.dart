//This repository class handles the authentication part
import 'package:dio/dio.dart';
import 'package:itgrowtech/data/api/api.dart';

class AuthRepository {
  
  final Api _api = Api();

  //Peanut Service Authentication
  Future<String> isAccountCredentialCorrect(int login, String password) async {
    try{
      Response response = await _api.makeApiCall.post("https://peanut.ifxdb.com/api/ClientCabinetBasic/IsAccountCredentialsCorrect", data: {'login': login, 'password': password});
      return response.data["token"].toString();

    } on DioException {
      rethrow;
    }
  }

  //Partner Service Authentication
  Future<String> requestMoblieCabinetApiToken(int login, String password) async {
    try{
      Response response = await _api.makeApiCall.post("https://client-api.contentdatapro.com/api/Authentication/RequestMoblieCabinetApiToken", data: {'login': login, 'password': password});
      return response.data.toString();

    } on DioException {
      rethrow;
    }
  }
}