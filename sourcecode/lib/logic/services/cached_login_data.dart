import 'package:shared_preferences/shared_preferences.dart';

class CachedLoginData {
  //SharedPreferences instance
  static SharedPreferences? _prefs;

  //Init method called at the beginning of the app
  static Future init() async => _prefs = await SharedPreferences.getInstance();

  //Getter: Login
  static int get getLogin => _prefs?.getInt("login") ?? 0;
  //Getter: Peanut service token
  static String get getPeanutToken => _prefs?.getString("peanutToken") ?? "";
  //Getter: Partner service token
  static String get getPartnerToken => _prefs?.getString("partnerToken") ?? "";

  //Setter: Login
  static Future setLogin(int login) async =>
    await _prefs?.setInt("login", login);

  //Setter: Peanut service token
  static Future setPeanutToken(String peanutToken) async =>
      await _prefs?.setString("peanutToken", peanutToken);
  //Setter: Partner service token
  static Future setPartnerToken(String partnerToken) async =>
      await _prefs?.setString("partnerToken", partnerToken);

  //Clear cached login data
  static void clearCachedLoginData() async {
    await _prefs?.remove("login");
    await _prefs?.remove("peanutToken");
    await _prefs?.remove("partnerToken");
  }
}