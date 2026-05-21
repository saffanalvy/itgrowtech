import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/profile_cubit/profile_cubit.dart';
import 'package:itgrowtech/logic/cubits/profile_cubit/profile_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: ((context, stateA) {
        //Show loading bar
        if (stateA is LoadingState) {
          return Scaffold(
            body: SafeArea(child: Center(child: CircularProgressIndicator())),
          );
        }

        //Show error message
        if (stateA is ErrorState) {
          return Scaffold(
            body: SafeArea(child: Center(child: Text(stateA.message))),
          );
        }

        //Goto Profile screen if logged in
        if (stateA is LoggedInState) {
          context.read<ProfileCubit>().getProfileData();

          return BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, stateB) {
              if (stateB is ProfileLoadingState){
                return Scaffold(
                  body: SafeArea(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                );
              }
              
              if (stateB is ProfileErrorState){
                return Scaffold(
                  body: SafeArea(
                    child: Center(
                      child: Text(stateB.message),
                    ),
                  ),
                );
              }

              if (stateB is ReloginState){
                context.read<AuthCubit>().logout();
                //return AuthScreen();
              }

              if (stateB is ProfileLoadedState){          
                return Scaffold(
                  appBar: AppBar(
                    title: Text("Profile ${stateB.phoneNumber}"),
                    automaticallyImplyLeading: false,
                    actions: [
                      IconButton(
                        onPressed: () {
                          context.read<AuthCubit>().logout();
                          //Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
                        },
                        icon: Icon(Icons.logout),
                      ),
                    ],
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Signal
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/signal");
                        },
                        child: Text("Signal"),
                      ),
                      //Promo
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, "/promo");
                        },
                        child: Text("Promo"),
                      ),

                      Text("address: ${stateB.profile.address}"),
                      Text("balance: ${stateB.profile.balance}"),
                      Text("city: ${stateB.profile.city}"),
                      Text("country: ${stateB.profile.country}"),
                      Text("currency: ${stateB.profile.currency}"),
                      Text("currentTradesCount: ${stateB.profile.currentTradesCount}"),
                      Text("currentTradesVolume: ${stateB.profile.currentTradesVolume}"),
                      Text("equity: ${stateB.profile.equity}"),
                      Text("freeMargin: ${stateB.profile.freeMargin}"),
                      Text("isAnyOpenTrades: ${stateB.profile.isAnyOpenTrades}"),
                      Text("isSwapFree: ${stateB.profile.isSwapFree}"),
                      Text("leverage: ${stateB.profile.leverage}"),
                      Text("name: ${stateB.profile.name}"),
                      Text("phone: ${stateB.profile.phone}"),
                      Text("totalTradesCount: ${stateB.profile.totalTradesCount}"),
                      Text("totalTradesVolume: ${stateB.profile.totalTradesVolume}"),
                      Text("type: ${stateB.profile.type}"),
                      Text("verificationLevel: ${stateB.profile.verificationLevel}"),
                      Text("zipCode: ${stateB.profile.zipCode}"),
                    ],
                  ),
                );
              }
              
              return Scaffold(
                body: SafeArea(child: Center(child: Text("Some error occured!"),)),
              );
            },
          );
        }

        //If not logged in then show Auth Screen
        if (stateA is LoggedOutState) {
          //Navigator.pushNamedAndRemoveUntil(context, "/auth", (route) => false);
          return AuthScreen();
        }

        //If any error occurs
        return Scaffold(
          body: SafeArea(child: Center(child: Text("Some error occured!"))),
        );
      }),
    );
  }
}
