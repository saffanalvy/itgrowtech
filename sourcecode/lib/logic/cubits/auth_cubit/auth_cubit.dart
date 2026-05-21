import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/data/repositories/auth_repository.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/services/cached_login_data.dart';

class AuthCubit extends Cubit<AuthState>{
    

  AuthCubit() : super(LoadingState()){
    isLoggedIn();
  }

  //Auth Repository instance
  AuthRepository authRepository = AuthRepository();
  
  //Getting tokens and checking if logged in or not
  void isLoggedIn() {
    try{
      //Getting Login
      int login = CachedLoginData.getLogin;

      //Getting Peanut Token
      String peanutToken = CachedLoginData.getPeanutToken;
      //Getting Partner Token
      String partnerToken = CachedLoginData.getPartnerToken;

      if (login == 0 && peanutToken.isEmpty && partnerToken.isEmpty){
        emit(LoggedOutState());
      } else {
        emit(LoggedInState(peanutToken, partnerToken));
      }
    } on DioException catch (ex){
        switch (ex.type){
          case DioExceptionType.connectionTimeout:
            emit(ErrorState('Connection timeout'));
          case DioExceptionType.sendTimeout:
            emit(ErrorState('Send timeout'));
          case DioExceptionType.receiveTimeout:
            emit(ErrorState('Receive timeout'));
          case DioExceptionType.badResponse:
            emit(ErrorState('Server error: ${ex.response?.statusCode}'));
          case DioExceptionType.connectionError:
            emit(ErrorState('No internet / connection error'));
          case DioExceptionType.unknown:
            emit(ErrorState('Check if your wifi is on'));
          default:
            emit(ErrorState(ex.type.toString()));
      }
    }
  }

  //Using repository authenticating to two services and getting auth tokens
  void newLogIn(int login, String password) async {
    try{
      String peanutToken = await authRepository.isAccountCredentialCorrect(login, password);
      String partnerToken = await authRepository.requestMoblieCabinetApiToken(login, password);

      await CachedLoginData.setLogin(login);
      await CachedLoginData.setPeanutToken(peanutToken);
      await CachedLoginData.setPartnerToken(partnerToken);

      emit(LoggedInState(peanutToken, partnerToken));
    } on DioException catch (ex){
        switch (ex.type){
          case DioExceptionType.connectionTimeout:
            emit(ErrorState('Connection timeout'));
          case DioExceptionType.sendTimeout:
            emit(ErrorState('Send timeout'));
          case DioExceptionType.receiveTimeout:
            emit(ErrorState('Receive timeout'));
          case DioExceptionType.badResponse:
            emit(ErrorState('Server error: ${ex.response?.statusCode}'));
          case DioExceptionType.connectionError:
            emit(ErrorState('No internet / connection error'));
          case DioExceptionType.unknown:
            emit(ErrorState('Check if your wifi is on'));
          default:
            emit(ErrorState(ex.type.toString()));
      }
    }
  }

  //Removing all cached login data and logging out
  void logout(){
    try{
      CachedLoginData.clearCachedLoginData();
      emit(LoggedOutState());
    } on DioException catch (ex){
        switch (ex.type){
          case DioExceptionType.connectionTimeout:
            emit(ErrorState('Connection timeout'));
          case DioExceptionType.sendTimeout:
            emit(ErrorState('Send timeout'));
          case DioExceptionType.receiveTimeout:
            emit(ErrorState('Receive timeout'));
          case DioExceptionType.badResponse:
            emit(ErrorState('Server error: ${ex.response?.statusCode}'));
          case DioExceptionType.connectionError:
            emit(ErrorState('No internet / connection error'));
          case DioExceptionType.unknown:
            emit(ErrorState('Check if your wifi is on'));
          default:
            emit(ErrorState(ex.type.toString()));
      }
    }
  }
}




