import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/main.dart';
import 'package:physicalcountv2/screens/user/userAreaScreen.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/customLogicalModal.dart';

import '../../services/server_url.dart';
import '../../services/server_url_list.dart';

class UserDashboardScreen extends StatefulWidget {
  const UserDashboardScreen({Key? key}) : super(key: key);

  @override
  _UserDashboardScreenState createState() => _UserDashboardScreenState();
}
class _UserDashboardScreenState extends State<UserDashboardScreen> {
  ServerUrlList sul = ServerUrlList();
  late SqfliteDBHelper _sqfliteDBHelper;
  Logs _log = Logs();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm:ss aaa");

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        // backgroundColor: Colors.grey[300],
        backgroundColor: Colors.white,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          title: Padding(
            padding: const EdgeInsets.only(left: 8.0),
            // child: Text(
            //   "Welcome ${GlobalVariables.logFullName}",
            //   style: TextStyle(color: Colors.blue),
            // ),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                      text: "Welcome! ",
                      style: TextStyle(fontSize: 25, color: Colors.blue)),
                  TextSpan(
                      text: "${GlobalVariables.logFullName}",
                      style: TextStyle(fontSize: 25, color: Colors.black))
                ],
              ),
            ),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.logout, color: Colors.red),
              color: Colors.white,
              onPressed: () {
                logOut();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  Divider(),
                  menuList(CupertinoIcons.barcode_viewfinder, "Item Scanning",
                          () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => UserAreaScreen()),
                        );
                      }),
                  Divider(),
                  GlobalVariables.byCategory == true && GlobalVariables.byVendor == true //------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Item to scan:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "1. Item belongs to category ${GlobalVariables.categories}\n",
                              style: TextStyle(fontSize: 25, color: Colors.black)),
                          TextSpan(
                              text: "2. Item belongs to vendor ${GlobalVariables.vendors}\n\n",
                              style: TextStyle(fontSize: 25, color: Colors.black)),
                          TextSpan(
                              text: "Store:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "${sul.server(ServerUrl.urlCI)}",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black)),
                        ],
                      ),
                    ),
                  )
                      : GlobalVariables.byCategory == false && GlobalVariables.byVendor == false //------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Item to scan:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "1. ALL CATEGORY\n",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black)),
                          TextSpan(
                              text: "2. ALL VENDOR\n\n",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black)),
                          TextSpan(
                              text: "Store:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "${sul.server(ServerUrl.urlCI)}",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black)),
                        ],
                      ),
                    ),
                  )
                      : GlobalVariables.byCategory == true && GlobalVariables.byVendor == false //------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Item to scan:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text:
                              "1. Item belongs to category ${GlobalVariables.categories}\n\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black)),
                          TextSpan(
                              text: "Store:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "${sul.server(ServerUrl.urlCI)}",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black)),
                        ],
                      ),
                    ),
                  )
                      : GlobalVariables.byCategory == false && GlobalVariables.byVendor == true //------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//
                      ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Item to scan:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight:
                                  FontWeight.bold)),
                          TextSpan(
                              text:
                              "1. Item belongs to vendor ${GlobalVariables.vendors}\n\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.black)),
                          TextSpan(
                              text: "Store:\n",
                              style: TextStyle(
                                  fontSize: 25,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "${sul.server(ServerUrl.urlCI)}",
                              style: TextStyle(
                                  fontSize: 25, color: Colors.black)),
                        ],
                      ),
                    ),
                  )
                      : SizedBox(),
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
          _log.device = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
          _log.user = GlobalVariables.logFullName;
          _log.empid = GlobalVariables.logEmpNo;
          _log.details = "[LOGOUT][Inventory Clerk]";
          await _sqfliteDBHelper.insertLog(_log);
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (BuildContext context) => PhysicalCount(),
              ),
                  (Route route) => false);
        });
  }
}