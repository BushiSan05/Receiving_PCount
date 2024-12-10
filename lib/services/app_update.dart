class AppUpdateVersion{
  static String urlCICheckUpdate = 'http://172.16.163.2:81/pcount_app/pcount_local_james/';
  static var _appVersion         = {'Version' : '1.9'};

  versionNumber()=> _appVersion['Version'];
}