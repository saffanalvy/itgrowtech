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
      if (ex.type == DioExceptionType.unknown){
        emit(ErrorState("Please check your internet connection!"));
      } else{
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
    } catch(ex){
      emit(ErrorState(ex.toString()));
    }
  }

  //Removing all cached login data and logging out
  void logout(){
    try{
      CachedLoginData.clearCachedLoginData();
      emit(LoggedOutState());
    } catch(ex){
      emit(ErrorState(ex.toString()));
    }
  }
}




