import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';

class SignalScreen extends StatelessWidget {
  const SignalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: ((context, state) {
        //Show loading bar
        if(state is LoadingState){
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        //Show error message
        if(state is ErrorState){
          return Scaffold(
            appBar: AppBar(title: Text("Signal")),
            body: SafeArea(
              child: Center(
                child: Text(state.message),
              ),
            ),
          );
        }

        //Goto Profile screen if logged in
        if(state is LoggedInState){
          return Scaffold(
            appBar: AppBar(
              title: Text("Signal"),
              actions: [
                IconButton(
                  onPressed: (){
                    context.read<AuthCubit>().logout();
                  }, 
                  icon: Icon(Icons.logout),
                )
              ],
            ),
            body: Center(child: Text("Signal"),),
          );
        }

        //If not logged in then show Auth Screen
        if(state is LoggedOutState){
          return AuthScreen();
        }

        //If any error occurs
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: Text("Some error occured!"),
            ),
          ),
        );
      }
    ),
    );
  }
}