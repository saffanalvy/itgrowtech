abstract class PromoState {}

//Loading...
class PromoLoadingState extends PromoState{}

//Error
class PromoErrorState extends PromoState{
  final String message;
  PromoErrorState(this.message);
}

//PromoLoadedState
class PromoLoadedState extends PromoState{
  final List<List<String?>> promoItems;
  PromoLoadedState(this.promoItems);
}