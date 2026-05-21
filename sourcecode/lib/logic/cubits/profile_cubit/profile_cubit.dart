import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/data/models/profile_model.dart';
import 'package:itgrowtech/data/repositories/profile_repository.dart';
import 'package:itgrowtech/logic/cubits/profile_cubit/profile_state.dart';
import 'package:itgrowtech/logic/services/cached_login_data.dart';

class ProfileCubit extends Cubit<ProfileState>{
    

  ProfileCubit() : super(ProfileLoadingState());

  //Profile Repository instance
  ProfileRepository profileRepository = ProfileRepository();
  
  //Getting profile data
  void getProfileData() async {
    final int login = CachedLoginData.getLogin;
    final String token = CachedLoginData.getPeanutToken;

    if (login != 0 && token.isNotEmpty){
      try{
        final String phoneNumber = await profileRepository.getLastFourNumbersPhone(login, token);
        final dynamic profile = await profileRepository.getAccountInformation(login, token);

        if (phoneNumber == "Access denied" && profile is String){
          emit(ReloginState());
        } else {
          emit(ProfileLoadedState(phoneNumber, profile as ProfileModel));
        }

      } on DioException catch (ex){
        switch (ex.type){
          case DioExceptionType.connectionTimeout:
            emit(ProfileErrorState('Connection timeout'));
          case DioExceptionType.sendTimeout:
            emit(ProfileErrorState('Send timeout'));
          case DioExceptionType.receiveTimeout:
            emit(ProfileErrorState('Receive timeout'));
          case DioExceptionType.badResponse:
            emit(ProfileErrorState('Server error: ${ex.response?.statusCode}'));
          case DioExceptionType.connectionError:
            emit(ProfileErrorState('No internet / connection error'));
          case DioExceptionType.unknown:
            emit(ProfileErrorState('Check if your wifi is on'));
          default:
            emit(ProfileErrorState(ex.type.toString()));
      }
    }
    }
  }
}
