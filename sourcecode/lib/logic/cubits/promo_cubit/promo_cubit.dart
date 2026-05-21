import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/data/repositories/promo_repository.dart';
import 'package:itgrowtech/logic/cubits/promo_cubit/promo_state.dart';

class PromoCubit extends Cubit<PromoState>{
    

  PromoCubit() : super(PromoLoadingState());

  //Promo Repository instance
  PromoRepository promoRepository = PromoRepository();
  
  //Getting Promo data
  void getPromoData() async {
    try{

      //Getting promo response
      final promoData = await promoRepository.getPromos();
      emit(PromoLoadedState(promoData));
      
    } on DioException catch (ex){
        switch (ex.type){
          case DioExceptionType.connectionTimeout:
            emit(PromoErrorState('Connection timeout'));
          case DioExceptionType.sendTimeout:
            emit(PromoErrorState('Send timeout'));
          case DioExceptionType.receiveTimeout:
            emit(PromoErrorState('Receive timeout'));
          case DioExceptionType.badResponse:
            emit(PromoErrorState('Server error: ${ex.response?.statusCode}'));
          case DioExceptionType.connectionError:
            emit(PromoErrorState('No internet / connection error'));
          case DioExceptionType.unknown:
            emit(PromoErrorState('Check if your wifi is on'));
          default:
            emit(PromoErrorState(ex.type.toString()));
      }
    }
  }
}