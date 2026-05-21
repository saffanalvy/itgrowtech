import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:itgrowtech/data/repositories/profile_repository.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_cubit.dart';
import 'package:itgrowtech/logic/cubits/auth_cubit/auth_state.dart';
import 'package:itgrowtech/logic/cubits/profile_cubit/profile_cubit.dart';
import 'package:itgrowtech/logic/services/cached_login_data.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';
import 'package:itgrowtech/presentation/screens/profile/profile_screen.dart';
import 'package:itgrowtech/utils/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //ProfileRepository profileRepository = ProfileRepository();
  //await profileRepository.getLastFourNumbersPhone(20234561, "ee7491664f41a05cee55a032c59b6b1be0686616d3a465d96174e94102fe18ae");
  //await profileRepository.getAccountInformation(20234561, "ee7491664f41a05cee55a032c59b6b1be0686616d3a465d96174e94102fe18ae");

  await CachedLoginData.init();
  final login = CachedLoginData.getLogin;
  final peanutToken = CachedLoginData.getPeanutToken;
  final partnerToken = CachedLoginData.getPartnerToken;

  runApp(MyApp(login: login, peanutToken: peanutToken, partnerToken: partnerToken));
}

class MyApp extends StatelessWidget {
  final int login;
  final String peanutToken;
  final String partnerToken;

  const MyApp({super.key, required this.login, required this.peanutToken, required this.partnerToken});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit(), lazy: false),
        BlocProvider(create: (context) => ProfileCubit(), lazy: false),
      ],
      child: MaterialApp(
        title: 'ITGrowTech Mock App',
        theme: ThemeData(
          colorScheme: .fromSeed(seedColor: Colors.deepPurple),
        ),
        home: BlocBuilder<AuthCubit, AuthState>(
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
                body: SafeArea(
                  child: Center(
                    child: Text(state.message),
                  ),
                ),
              );
            }

            //Goto Profile screen if logged in
            if(state is LoggedInState){
              return ProfileScreen();
            }

            //If not logged in then show Auth Screen
            if(state is LoggedOutState){
              return AuthScreen();
            }

            return Scaffold(
              body: SafeArea(
                child: Center(
                  child: Text("Some error occured!"),
                ),
              ),
            );
          }
        ),
      ),
      onGenerateRoute: AppRoutes.onGenerateRoute,
        //If app runs for the first time then initial route is SetGenderScreen
        //Else HomeScreen
        initialRoute: (login != 0 && peanutToken.isNotEmpty && partnerToken.isNotEmpty) ? "/profile" : "/auth",
      ),
    );
  }
}
