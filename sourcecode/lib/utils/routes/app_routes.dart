//This class handles the basic generated routing of all the screens navigations

import 'package:flutter/material.dart';
import 'package:itgrowtech/presentation/screens/auth/auth_screen.dart';
import 'package:itgrowtech/presentation/screens/profile/profile_screen.dart';
import 'package:itgrowtech/presentation/screens/promo/promo_screen.dart';
import 'package:itgrowtech/presentation/screens/signals_archive/signal_screen.dart';

class AppRoutes {
  static Route? onGenerateRoute(RouteSettings routeSettings) {

    //Handles the Screens routing of the app 
    switch (routeSettings.name) {
      //Auth Screen
      case "/auth":
        return MaterialPageRoute(
          builder: (BuildContext context) => const AuthScreen(),
        );
      
      //Profile Screen
      case "/profile":
        return MaterialPageRoute(
          builder: (BuildContext context) => const ProfileScreen(),
        );

      //Signal Screen
      case "/signal":
        return MaterialPageRoute(
          builder: (BuildContext context) => const SignalScreen(),
        );
      
      //Promo Screen
      case "/promo":
        return MaterialPageRoute(
          builder: (BuildContext context) => const PromoScreen(),
        );

      default:
        return null;
    }
  }
}