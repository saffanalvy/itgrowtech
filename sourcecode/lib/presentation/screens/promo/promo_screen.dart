import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/promo_cubit/promo_cubit.dart';
import 'package:itgrowtech/logic/cubits/promo_cubit/promo_state.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class PromoScreen extends StatelessWidget {
  const PromoScreen({super.key});

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
            appBar: AppBar(title: Text("Promo")),
            body: SafeArea(
              child: Center(
                child: Text(state.message),
              ),
            ),
          );
        }

        //Goto Profile screen if logged in
        if(state is LoggedInState){

          context.read<PromoCubit>().getPromoData();

          return Scaffold(
            appBar: AppBar(
              title: Text("Promo"),
              actions: [
                IconButton(
                  onPressed: (){
                    context.read<AuthCubit>().logout();
                  }, 
                  icon: Icon(Icons.logout),
                )
              ],
            ),
            body: BlocBuilder<PromoCubit, PromoState>(
              builder: (context, stateB){
                
                if (stateB is PromoLoadingState){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (stateB is PromoErrorState){
                  return Center(
                    child: Text(stateB.message),
                  );
                }

                if (stateB is PromoLoadedState){
                  return ListView.builder(
                    itemCount: stateB.promoItems.length,
                    itemBuilder: ((context, index) => 
                      ListTile(
                        leading: Image.network(stateB.promoItems[index][2]!, width: 60, height: 60),
                        title: Text(stateB.promoItems[index][0]!),
                        onTap: () async{
                          final Uri url = Uri.parse(stateB.promoItems[index][1]!);
                          if (!await launchUrl(url,
                              mode: LaunchMode.externalApplication)) {
                            throw 'Could not launch $url';
                          }
                        },
                      )),
                  );
                }

                return Center(
                  child: Text("Some error occured!"),
                );
              }
            ),
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