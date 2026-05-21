import 'package:itgrowtech/data/models/profile_model.dart';

abstract class ProfileState {}

//Loading...
class ProfileLoadingState extends ProfileState{}

//Error
class ProfileErrorState extends ProfileState{
  final String message;
  ProfileErrorState(this.message);
}

//Profile Loaded state
class ProfileLoadedState extends ProfileState{
  final String phoneNumber;
  final ProfileModel profile;
  ProfileLoadedState(this.phoneNumber, this.profile);
}

//Re-login state
class ReloginState extends ProfileState{}
