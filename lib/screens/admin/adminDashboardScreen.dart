import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/main.dart';
import 'package:physicalcountv2/screens/admin/activityLogScreen.dart';
import 'package:physicalcountv2/screens/admin/signatureCapture.dart';
import 'package:physicalcountv2/screens/admin/syncDatabaseScreen.dart';
import 'package:physicalcountv2/services/api.dart';
import 'package:physicalcountv2/services/app_update.dart';
import 'package:physicalcountv2/services/server_url.dart';
import 'package:physicalcountv2/services/server_url_list.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/customLogicalModal.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AdminDashboardScreen extends StatefulWidget {
  final user;
  final id;
  final businessUnit;
  const AdminDashboardScreen({Key? key, required this.user, required this.id, required this.businessUnit}) : super(key: key);
  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {

  final List<String> items = [
    'Item1',
    'Item2',
    'Item3',
    'Item4',
  ];
  var version = AppUpdateVersion().versionNumber();
  String? selectedValue;
  //late Servers servers;
  ServerUrlList sul = ServerUrlList();
  var server = ServerUrlList().serverUrlKey();
  var serverName = [''];
  late var _currentItemSelectd = '';
  String prev_server="";
  String new_server ="";
  bool btnUpdateClick = true;

  late SqfliteDBHelper _sqfliteDBHelper;
  Logs _log = Logs();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm:ss aaa");

  @override
  void initState()  {
    print('Business Unit ::: ${widget.businessUnit}');
    ServerUrl su = ServerUrl();
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    btnUpdateClick = false;
    serverName.addAll(server);
    // serverName.removeAt(0);
    checkSelectedServer();
    if (mounted) setState(() {});
    super.initState();
  }

  checkSelectedServer()async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ServerUrl su = ServerUrl();
    if(widget.businessUnit == 'All'){
      prefs.getString('new_server');
      String value = prefs.getString('new_server') ?? ''.toString();
      if(value.isEmpty){
        serverName.removeAt(0);
        setState(() {
          this._currentItemSelectd = serverName[0];
        });
      }else{
        serverName.removeAt(0);
        setState(() {
          this._currentItemSelectd = prefs.getString('new_server').toString();
        });
        print('NEW SERVER : ${prefs.getString('new_server').toString()}');
        su.serverValue = sul.ip(value);
      }
    }else{
      var check = await sul.ip(widget.businessUnit);
      print('Checked :: $check');
      if(check != 'Not found'){
        prefs.setString("new_server", widget.businessUnit.toString().trim());
        setState(() {
          this._currentItemSelectd = widget.businessUnit!;
        });
        // su.serverValue = sul.ip(newValueSelected);
        new_server = prefs.getString('new_server').toString();
        su.serverValue = sul.ip(new_server);
        print("new server :: ${ServerUrl.urlCI}");
      }else{
        Navigator.of(context).pop();
        instantMsgModal(
            context,
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.red,
              size: 40,
            ),
            Text("Admin Business Unit Error!"));
      }
    }
    /*this._currentItemSelectd = prefs.getString('new_server').toString();
    print('NEW SERVER : ${prefs.getString('new_server').toString()}');*/
  }
  checkAppUpdate()async{
    print('VERSION: $version');
    var res = await checkUpdate(version);
    print(res);
    if(res == 'Uptodate'){
      await _showDialog("$res", "Your app is up to date. \n App version$version", '');
    }else{
      if(res['version'] != ''){
        await _showDialog("Latest Version available", "App Version ${res['version']}",'${res['url']}');
      }else{
        await _showDialog("Error", "Something went wrong",'');
      }
    }
    print("false");
    btnUpdateClick = false;
  }

  _showDialog(String title, String content, String url){
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context){
          return CupertinoAlertDialog(
            title: title != 'Uptodate' ?
              Text("$title"):
              Icon(Icons.check_circle, color: Colors.green, size: 36,),
            content: Text("$content", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),),
            actions: <Widget>[
              title != 'Uptodate' ?
                TextButton(
                  child: Text("Download"),
                  onPressed: ()async{
                    //Navigator.of(context).pop();
                    _launchURL(url);
                    //openBrowserURL(url: url, inApp: true);
                  },
                ):
                SizedBox(),
              title != 'Uptodate' ?
                TextButton(
                  child: Text("Later"),
                  onPressed: (){
                  Navigator.of(context).pop();
                  },
                ):
                SizedBox(),
            ],
          );
        }
    );
  }

  _launchURL(String urlApk) async {
    var url = '$urlApk';
    //var url = 'https://tinyurl.com/pcountpm1';
    if (await launch(url)) {
      await canLaunch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void serverLog(String fServer)async{
    _log.date = dateFormat.format(DateTime.now());
    _log.time = timeFormat.format(DateTime.now());
    _log.device = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
    _log.user = "${widget.user}";
    _log.empid = "${widget.id}";
    _log.details = "[SERVER][$fServer Change to $_currentItemSelectd]";
    await _sqfliteDBHelper.insertLog(_log);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              "ADMINISTRATOR ACCESS",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20.0
              ),
            ),
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                widget.businessUnit == 'All' ?
                Text("Select Server : ",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                  ),
                ):
                SizedBox(),
                widget.businessUnit == 'All' ?
                DropdownButtonHideUnderline(
                child: Container(
                  height: 40, // Set the desired height
                  width: 160, // Set the desired width
                  child: DropdownButton(
                    value: _currentItemSelectd,
                    items: serverName.map((String dropDownStringItem){
                      return DropdownMenuItem(
                        value: dropDownStringItem,
                        child: Text(dropDownStringItem),
                      );
                    }).toList(),
                    onChanged: (String? newValueSelected) async{
                      var check = await sul.ip(newValueSelected.toString());
                      if(check != 'Not found'){
                        if(newValueSelected != _currentItemSelectd){
                          showDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (BuildContext context){
                                return CupertinoAlertDialog(
                                  title: Text("Switching Server"),
                                  content: Text("Continue to Switch a new Server?"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("Yes"),
                                      onPressed: ()async{
                                        var fServer = _currentItemSelectd;
                                        SharedPreferences prefs = await SharedPreferences.getInstance();
                                        ServerUrl su = ServerUrl();
                                        ServerUrlList sul = ServerUrlList();
                                        print("previous server :: ${su.serverValue}");
                                        // _onDropDownItemSelected(newValueSelected);
                                        setState(() {
                                          prefs.setString("new_server", newValueSelected.toString().trim());
                                          this._currentItemSelectd = newValueSelected!;
                                          // su.serverValue = sul.ip(newValueSelected);
                                          new_server = prefs.getString('new_server').toString();
                                          su.serverValue = sul.ip(new_server);
                                          print("new server :: ${ServerUrl.urlCI}");
                                        });
                                        serverLog(fServer);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text("No"),
                                      onPressed: (){
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              }
                          );
                        }
                      }
                    },
                    icon: Icon(Icons.cable_rounded),
                    iconSize: 20,
                    iconEnabledColor: Colors.lightBlueAccent,
                    style: TextStyle(color: Colors.blueAccent),
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                  ),
                  ),
                ):
                // SizedBox(),
                SizedBox(width: 30,),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.red),
                  color: Colors.white,
                  onPressed: () {
                    logOut();
                  },
                ),
              ],
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Divider(),
                  menuList(Icons.sync, "Sync Database", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SyncDatabaseScreen(user: "${widget.user}", id: "${widget.id}")),
                    );
                  }),
                  Divider(),
                  menuList(CupertinoIcons.list_bullet_below_rectangle,
                      "Activity Log", () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ActivityLogScreen()),
                    );
                  }),
                  // Divider(),
                  // menuList(CupertinoIcons.signature, "Signature Uploading", () {
                  //   Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => SignatureCapture()),
                  //   );
                  // }),
                  Divider(),
                  // menuList(CupertinoIcons.checkmark_rectangle, "Check for Update", () async{
                  //   if(!btnUpdateClick){
                  //     btnUpdateClick = true;
                  //     if (mounted) setState(() {});
                  //     var res = await checkConnection();
                  //     if (mounted) setState(() {});
                  //     if (res == 'error') {
                  //       instantMsgModal(
                  //           context,
                  //           Icon(
                  //             CupertinoIcons.exclamationmark_circle,
                  //             color: Colors.red,
                  //             size: 40,
                  //           ),
                  //           Text("${GlobalVariables.httpError}"));
                  //       btnUpdateClick = false;
                  //     } else if (res == 'errornet') {
                  //       instantMsgModal(
                  //           context,
                  //           Icon(
                  //             CupertinoIcons.exclamationmark_circle,
                  //             color: Colors.red,
                  //             size: 40,
                  //           ),
                  //           Text("${GlobalVariables.httpError}"));
                  //       btnUpdateClick = false;
                  //     } else {
                  //       if (res == 'connected') {
                  //         await checkAppUpdate();
                  //       }else{
                  //         btnUpdateClick = false;
                  //       }
                  //       // setState(() {
                  //       //   btn_sync =true;
                  //       // });
                  //     }
                  //   }
                  //   /*Navigator.push(
                  //     context,
                  //     MaterialPageRoute(
                  //         builder: (context) => CheckForUpdate()),
                  //   );*/
                  // }),
                  // Divider(),
                  // MaterialButton(
                  //   child: Text("test"),
                  //   onPressed: () {
                  //     DateFormat dateFormat = DateFormat("yyyy-MM-dd");
                  //     // DateFormat timeFormat = DateFormat("hh:mm:ss aaa");
                  //     DateFormat timeFormat = DateFormat("HH:mm:ss");
                  //     print(dateFormat.format(DateTime.now()) +
                  //         " " +
                  //         timeFormat.format(DateTime.now()));
                  //   },
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget menuList(IconData icon, String title, VoidCallback voidCallback) {
    return GestureDetector(
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
        child: Container(
          height: MediaQuery.of(context).size.height / 7,
          color: Colors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Icon(
                      icon,
                      color: Colors.blue,
                      size: 70.0,
                    ),
                  ),
                  Material(
                    type: MaterialType.transparency,
                    child: FittedBox(
                      child: Text(
                        title,
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
      onTap: voidCallback,
    );
  }

  logOut() {
    customLogicalModal(context, Text("Are you sure you want to logout?"),
        () => Navigator.pop(context), () async {
      _log.date = dateFormat.format(DateTime.now());
      _log.time = timeFormat.format(DateTime.now());
      _log.device =
          "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
      _log.user = "${widget.user}";
      _log.empid = "${widget.id}";
      _log.details = "[LOGOUT][Admin Logout]";
      await _sqfliteDBHelper.insertLog(_log);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (BuildContext context) => PhysicalCount(),
          ),
          (Route route) => false);
    });
  }
}
