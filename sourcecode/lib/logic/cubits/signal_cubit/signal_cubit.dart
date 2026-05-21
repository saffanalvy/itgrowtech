import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/data/models/signal_model.dart';
import 'package:itgrowtech/data/repositories/signal_repository.dart';
import 'package:itgrowtech/logic/cubits/signal_cubit/signal_state.dart';
import 'package:itgrowtech/logic/services/cached_login_data.dart';

class SignalCubit extends Cubit<SignalState>{
    

  SignalCubit() : super(SignalLoadingState());

  //Signal Repository instance
  SignalRepository signalRepository = SignalRepository();
  
  //Getting signals data
  void getSignals(String currencyPairs, int dateFrom, int dateTo) async {
    try{
      //Getting Login
      int login = CachedLoginData.getLogin;

      //Getting Partner Token
      String passkey = CachedLoginData.getPartnerToken;

      //Getting signal response
      final signalData = await signalRepository.getAnalyticSignals(passkey, login, currencyPairs, dateFrom, dateTo);

      if (signalData is String && signalData == "Access denied"){
        emit(SignalReloginState());
      } else {
        emit(SignalLoadedState(signalData as List<SignalModel>));
      }
    } on DioException catch (ex){
        switch (ex.type){
          case DioExceptionType.connectionTimeout:
            emit(SignalErrorState('Connection timeout'));
          case DioExceptionType.sendTimeout:
            emit(SignalErrorState('Send timeout'));
          case DioExceptionType.receiveTimeout:
            emit(SignalErrorState('Receive timeout'));
          case DioExceptionType.badResponse:
            emit(SignalErrorState('Server error: ${ex.response?.statusCode}'));
          case DioExceptionType.connectionError:
            emit(SignalErrorState('No internet / connection error'));
          case DioExceptionType.unknown:
            emit(SignalErrorState('Check if your wifi is on'));
          default:
            emit(SignalErrorState(ex.type.toString()));
      }
    }
  }
}