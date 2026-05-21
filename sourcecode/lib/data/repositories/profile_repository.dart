//This repository class handles the profile data part
import 'package:dio/dio.dart';
import 'package:itgrowtech/data/api/api.dart';
import 'package:itgrowtech/data/models/profile_model.dart';

class ProfileRepository {
  
  final Api _api = Api();

  //Peanut Service GetLastFourNumbersPhone
  Future<String> getLastFourNumbersPhone(int login, String token) async {
    try{
      Response response = await _api.makeApiCall.post("https://peanut.ifxdb.com/api/ClientCabinetBasic/GetLastFourNumbersPhone", data: {'login': login, 'token': token});
      return response.data.toString();

    } catch(ex){
      rethrow;
    }
  }

  //Peanut Service GetAccountInformation
  Future<dynamic> getAccountInformation(int login, String token) async {
    try{
      Response response = await _api.makeApiCall.post("https://peanut.ifxdb.com/api/ClientCabinetBasic/GetAccountInformation", data: {'login': login, 'token': token});
      
      if (response.data is String){
        return response.data;
      }

      ProfileModel profile = ProfileModel.fromJson(response.data);
      return profile;

    } catch(ex){
      rethrow;
    }
  }
}