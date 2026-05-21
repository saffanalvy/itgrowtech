import 'package:itgrowtech/data/models/signal_model.dart';

abstract class SignalState {}

//Loading...
class SignalLoadingState extends SignalState{}

//Error
class SignalErrorState extends SignalState{
  final String message;
  SignalErrorState(this.message);
}

//SignalLoadedState
class SignalLoadedState extends SignalState{
  final List<SignalModel> signals;
  SignalLoadedState(this.signals);
}

//SignalReloginState
class SignalReloginState extends SignalState{}
