import 'package:dio/dio.dart';
import 'package:itgrowtech/data/api/api.dart';
import 'package:itgrowtech/data/models/signal_model.dart';

class SignalRepository {
  
  final Api _api2 = Api();

  //Partner Service GetAnalyticSignals
  Future<dynamic> getAnalyticSignals(String passkey, int login, String currencyPairs, int dateFrom, int dateTo) async {
    try{
      _api2.makeApiCall.options.headers["passkey"] = passkey;
      Response response = await _api2.makeApiCall.get("https://client-api.contentdatapro.com/clientmobile/GetAnalyticSignals/$login?tradingsystem=3&pairs=$currencyPairs&from=$dateFrom&to=$dateTo");
      
      if (response.data is String){
        return response.data;
      }

      List<dynamic> signalMaps = response.data;
      return signalMaps.map((signalMap) => SignalModel.fromJson(signalMap)).toList();

    } on DioException {
      rethrow;
    }
  }


}