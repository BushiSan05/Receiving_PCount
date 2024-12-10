import 'package:shared_preferences/shared_preferences.dart';

class ServerUrl {
  //static String urlCI = 'http://172.16.43.95/pcount/';
  // static String  urlCI = 'http://172.16.43.125/pcount/';
  //static String  urlCI = 'http://172.16.163.2:81/pcount_app/';
  // static String urlCI = 'http://172.16.161.100/pcount/pcount/';
  // static String  urlCI = 'http://172.16.163.2:81/pcount_app/pcount/';
  // static String  urlCI = 'http://172.16.163.2:81/pcount_app/pcount_alturas/';
  //static String  urlCI = 'http://172.16.163.2:81/pcount_app/pcount_alturas_snackbar/';
  // static String urlCI = 'http://172.16.161.100/pcount/pcount/';

  //------> Note: This is the default IP, should the same with the Local IP <----------------------
  static String  urlCI = 'http://172.16.163.2:81/pcount_app/receiving_pcount_local/';
  String get serverValue => urlCI;
  set serverValue(String url) => urlCI = url;
}
