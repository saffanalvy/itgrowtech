abstract class AuthState {}

//Loading...
class LoadingState extends AuthState{}

//Error
class ErrorState extends AuthState{
  final String message;
  ErrorState(this.message);
}

//Logged in state
class LoggedInState extends AuthState{
  final String peanutToken;
  final String partnerToken;
  LoggedInState(this.peanutToken, this.partnerToken);
}

//Logged out state
class LoggedOutState extends AuthState{}