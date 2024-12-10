import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemCountModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/screens/user/itemNotFoundScanScreen.dart';
import 'package:physicalcountv2/screens/user/itemScannedListScreen.dart';
import 'package:physicalcountv2/screens/user/itemScanningScreen.dart';
import 'package:physicalcountv2/screens/user/syncScannedItemScreen.dart';
import 'package:physicalcountv2/screens/user/viewItemNotFoundScanScreen.dart';
import 'package:physicalcountv2/screens/user/viewItemScannedListScreen.dart';
import 'package:physicalcountv2/services/api.dart';
import 'package:physicalcountv2/services/server_url_list.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:physicalcountv2/services/server_url.dart';
import 'package:physicalcountv2/widget/scanAuditModal.dart';
// import 'package:physicalcountv2/widget/managerskeyModal.dart';
import 'package:physicalcountv2/widget/scanRovingITModal.dart';

import '../../db/models/itemNotFoundModel.dart';

class UserAreaScreen extends StatefulWidget {
  const UserAreaScreen({Key? key}) : super(key: key);

  @override
  _UserAreaScreenState createState() => _UserAreaScreenState();
}


class _UserAreaScreenState extends State<UserAreaScreen> with SingleTickerProviderStateMixin{
  ServerUrlList sul = ServerUrlList();
  late SqfliteDBHelper _sqfliteDBHelper;
  // Logs _log = Logs();
  // DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  // DateFormat timeFormat = DateFormat("hh:mm:ss aaa");

  List _assignArea = [];
  bool checking = true;
  List countType = [];
  bool checkingData = false;
  bool btnSyncClick = false;
  int indexClick = -1;
  bool isLocked = false; // Variable to track the lock state
  late AnimationController animationController;

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});
    checkingData = true;
    _refreshUserAssignAreaList();
    //print("items count :: $_items");
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 7),
    );
    animationController.repeat();
    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  Future checkCountItemAssignArea(List assignArea)async{
    var areaLen = assignArea.length;
    for(int i = 0; i < areaLen; i++){
      List<ItemCount> x = await _sqfliteDBHelper.fetchItemCountWhere(
          "empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${assignArea[i]['business_unit']}' AND department = '${assignArea[i]['department']}' AND section  = '${assignArea[i]['section']}' AND rack_desc  = '${assignArea[i]['rack_desc']}' AND location_id = '${assignArea[i]['location_id']}'");
      if(x.isNotEmpty){
        await _lockUnlockLocation2(true, true, assignArea[i]['location_id'].toString()); /*print("empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${assignArea[i]['business_unit']}' AND department = '${assignArea[i]['department']}' AND section  = '${assignArea[i]['section']}' AND rack_desc  = '${assignArea[i]['rack_desc']}' AND location_id = '${assignArea[i]['location_id']}'");*/
      }
      if(i == areaLen-1){
        checkingData = false;
        _refreshUserAssignAreaList();
      }
    }
  }

  bool isWithinOneWeek(DateTime scheduledDate) {
    // final now = DateTime.now();
    final currentDateTime = DateTime.now();
    final oneWeekBefore = currentDateTime.subtract(Duration(days: 7));
    final oneWeekLater = currentDateTime.add(Duration(days: 7));

    return scheduledDate.isAfter(oneWeekBefore) && scheduledDate.isBefore(oneWeekLater);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Store: " + "${sul.server(ServerUrl.urlCI)}" ,
                style: TextStyle(color: Colors.black),
              ),
            ],
          ),
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          leadingWidth: 150,
          leading: Container(
            child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () async {
                      var count = await _sqfliteDBHelper.selectItemCountRawQuery(
                          "SELECT COUNT(*) as totalCount FROM ${ItemCount.tblItemCount} WHERE exported != 'EXPORTED'"
                      );
                      var count2 = await _sqfliteDBHelper.selectItemCountRawQuery(
                          "SELECT COUNT(*) as totalNF FROM ${ItemNotFound.tblItemNotFound} WHERE exported != 'EXPORTED'"
                      );

                      var result1 = count.isNotEmpty && count[0]['totalCount'] != null ? count[0]['totalCount'] : 0;
                      var result2 = count2.isNotEmpty && count2[0]['totalNF'] != null ? count2[0]['totalNF'] : 0;

                      // Only proceed to close if both counts are 0
                      if (result1 == 0 && result2 == 0) {
                        print("Closing screen, no items left: $result1 and $result2");
                        Navigator.of(context).pop();
                      } else {
                        Fluttertoast.showToast(
                          msg: 'There are still items that have not been synced.\n'
                              'Please check the scanned items and proceed with syncing.',
                          toastLength: Toast.LENGTH_LONG,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black54,
                          textColor: Colors.white,
                          fontSize: 16.0,
                        );
                        print("Items still exist. Can't close the screen.");
                        print("Counts are $result1 and $result2");
                      }
                    },
                  ),

                  Expanded(
                    child: Text(
                      "User Area",
                      style: TextStyle(color: Colors.blue, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ]
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ElevatedButton(
                onPressed: () async {
                  var count = await _sqfliteDBHelper.selectItemCountRawQuery(
                      "SELECT COUNT(*) as totalCount FROM ${ItemCount.tblItemCount} WHERE exported != 'EXPORTED'");
                  var count2 = await _sqfliteDBHelper.selectItemCountRawQuery(
                      "SELECT COUNT(*) as totalNF FROM ${ItemNotFound.tblItemNotFound} WHERE exported != 'EXPORTED'");

                  var result1 = count.isNotEmpty && count[0]['totalCount'] != null ? count[0]['totalCount'] : 0;
                  var result2 = count2.isNotEmpty && count2[0]['totalNF'] != null ? count2[0]['totalNF'] : 0;

                  if (result1 > 0 || result2 > 0) {
                  if (!btnSyncClick) {
                    setState(() {
                      btnSyncClick = true; // Start the sync process
                      indexClick = 0; // Set to a default index or logic if needed
                    });

                      var data = _assignArea;
                      var index = 0;
                      var res = await checkConnection();
                      if (res == 'connected') {
                        print("ang result ky $result1 ug $result2");
                        // Show confirmation dialog
                        showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (BuildContext context) {
                            return CupertinoAlertDialog(
                              title: Text(
                                  "${sul.server(ServerUrl.urlCI)} Server"),
                              content: Text("Continue to Sync in this Server?"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text("Yes"),
                                  onPressed: () async {
                                    GlobalVariables.currentLocationID =
                                    data[index]['location_id'];
                                    GlobalVariables.currentBusinessUnit =
                                    data[index]['business_unit'];
                                    GlobalVariables.currentDepartment =
                                    data[index]['department'];
                                    GlobalVariables.currentSection =
                                    data[index]['section'];
                                    GlobalVariables.currentRackDesc =
                                    data[index]['rack_desc'];
                                    setState(() {
                                      btnSyncClick = false;
                                      indexClick = index;
                                    });
                                    Navigator.of(context).pop();
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              SyncScannedItemScreen()),
                                    );
                                  },
                                ),
                                TextButton(
                                  child: Text("No"),
                                  onPressed: () {
                                    setState(() {
                                      btnSyncClick =
                                      false; // Reset sync button state
                                    });
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        setState(() {
                          btnSyncClick = false; // Reset sync button state
                        });
                        instantMsgModal(
                          context,
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            color: Colors.red,
                            size: 40,
                          ),
                          Text("No Connection. Please connect to a network."),
                        );
                      }
                    }
                  } else {
                    setState(() {
                      btnSyncClick = false; // Reset sync button state
                    });
                    print("ang result ky $result1 ug $result2");
                    instantMsgModal(
                      context,
                      Icon(
                        CupertinoIcons.exclamationmark_circle,
                        color: Colors.red,
                        size: 40,
                      ),
                      Text("ERROR! No items scanned."),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.green, // Background color
                  onPrimary: Colors.white, // Text color
                  padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0), // Padding
                  minimumSize: Size(0, 10), // Minimum size of the button
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0), // Rounded corners
                  ),
                  elevation: 0, // Shadow
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Minimize the button size to fit content
                  children: [
                    btnSyncClick
                        ? AnimatedBuilder(
                      // Ensure your animation controller is initialized
                        animation: animationController,
                          child: Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white),
                          builder: (BuildContext context, Widget? _widget) {
                            return Transform.rotate(
                              angle: animationController.value * 40,
                              child: _widget,
                            );
                      },
                    )
                        : Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white), // Icon color
                    SizedBox(width: 3), // Spacing between icon and text
                    Text("Sync All Data", style: TextStyle(fontSize: 12)), // Text style
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            checking ? LinearProgressIndicator() : SizedBox(),
            !checking
                ? Expanded(
              child: Scrollbar(
                child: ListView.builder(
                  itemCount: _assignArea.length,
                  itemBuilder: (context, index) {
                    var data = _assignArea;
                    var countData = countType;
                    if (index >= 0 && index < countData.length) {
                      var scheduledDate = DateTime.parse(countData[index]['batchDate']);

                      if (!isWithinOneWeek(scheduledDate)) {
                        // Skip adding this item to the list
                        return SizedBox.shrink();
                      }

                      print("Scheduled Date: $scheduledDate");
                      print("Is Within One Week: ${isWithinOneWeek(scheduledDate)}");
                    } else {
                      // Handle the case when index is out of bounds, e.g., print an error message or provide a default value.
                      print('Invalid index: $index');
                    }
                    for (int i = 0; i < countData.length; i++) {
                      print("Index: $i, Data: ${countData[i]}");
                    }

                    print("mao ni index: $index");

                    // Create a new list to store updated items
                    List<Map<String, dynamic>> updatedData = [];

                    // Update the lock status based on batchdate
                    for (var item in data) {
                      Map<String, dynamic> updatedItem = Map<String, dynamic>.from(item); // Create a mutable copy
                      if (updatedItem['batchdate'] != null && updatedItem['batchdate'] is String) {
                        try {
                          DateTime batchDate = DateFormat('yyyy-MM-dd HH:mm:ss').parse(updatedItem['batchdate']);
                          updatedItem['locked'] = batchDate.isBefore(DateTime.now()) ? 'true' : 'false';
                        } catch (e) {
                          print('Error parsing batchdate for item: ${updatedItem['batchdate']} - $e');
                          updatedItem['locked'] = 'true';
                        }
                      } else {
                        updatedItem['locked'] = 'false';
                      }
                      updatedData.add(updatedItem); // Add the updated item to the new list
                    }
                    return Padding(
                      padding:
                      const EdgeInsets.only(right: 8.0, left: 8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data[index]['business_unit'] +
                                "/" +
                                data[index]['department'] +
                                "/" +
                                data[index]['section'],
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            children: [
                              Icon(
                                data[index]['done'] == 'true'
                                    ? CupertinoIcons.checkmark_alt_circle_fill
                                    : CupertinoIcons.ellipsis_circle_fill,
                                size: 30,
                                color: data[index]['done'] == 'true'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              SizedBox(width: 2.0),
                              Expanded(
                                child: Text(
                                  data[index]['rack_desc'],
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                              // Expanded(
                              //   child:
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: <Widget>[
                                    Column(
                                      children: <Widget>[
                                        Text(
                                          // 'Count Type: ' + countData[index]['countType'],
                                          'Count Type: ' + (index < countData.length ? countData[index]['countType'] : 'Invalid Index'),
                                          style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                                        ),
                                        Text(
                                          // 'Type: ' + cdata[index]['ctype'],
                                          'Category: ' + (index < countData.length ? countData[index]['ctype'] : 'Invalid Index'),
                                          style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                                        ),
                                        Text(
                                          // 'Sched: ' + countData[index]['batchDate'],
                                          'Sched: ' + (index < countData.length ? countData[index]['batchDate'] : 'Invalid Index'),
                                          style: TextStyle(color: Colors.deepOrange, fontSize: 12),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              // ),
                              // Spacer(),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Spacer(),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Parse the batch date from your data
                                    final batchDate = DateFormat("yyyy-MM-dd").parse(countData[index]['batchDate']);
                                    final currentDateTime = DateTime.now();

                                    // Strip the time (hours, minutes, and seconds) from both dates
                                    final batchDateWithoutTime = DateTime(batchDate.year, batchDate.month, batchDate.day);
                                    final currentDateWithoutTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);

                                    print('BATCH DATE: $batchDateWithoutTime');
                                    print('CURRENT DATE (without time): $currentDateWithoutTime');

                                    // Compare only the date, ignoring the time
                                    final difference = currentDateWithoutTime.difference(batchDateWithoutTime).inDays;
                                    print('DIFFERENCE: $difference');

                                    // If the batch date is behind the current date, lock the location
                                    if (batchDateWithoutTime.isBefore(currentDateWithoutTime)) {
                                      setState(() {
                                        isLocked = true; // Update the lock state
                                      });
                                      instantMsgModal(
                                        context,
                                        Icon(
                                          CupertinoIcons.exclamationmark_circle,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                        Text("This location is locked due to batch date expiration."),
                                      );
                                      return; // Exit the function early if locked
                                    }

                                    // Check if the location is not locked, then proceed
                                    if (data[index]['locked'] == 'false') {
                                      GlobalVariables.currentLocationID = data[index]['location_id'];
                                      GlobalVariables.currentBusinessUnit = data[index]['business_unit'];
                                      GlobalVariables.currentDepartment = data[index]['department'];
                                      GlobalVariables.currentSection = data[index]['section'];
                                      GlobalVariables.currentRackDesc = data[index]['rack_desc'];

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => ItemScanningScreen()),
                                      ).then((value) {
                                        _refreshUserAssignAreaList();
                                      });
                                    } else {
                                      instantMsgModal(
                                        context,
                                        Icon(
                                          CupertinoIcons.exclamationmark_circle,
                                          color: Colors.red,
                                          size: 40,
                                        ),
                                        Text("This location is locked."),
                                      );
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(primary: Colors.blue),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.barcode_viewfinder),
                                      Text("Start scan"),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    GlobalVariables.currentLocationID = data[index]['location_id'];
                                    GlobalVariables.currentBusinessUnit = data[index]['business_unit'];
                                    GlobalVariables.currentDepartment = data[index]['department'];
                                    GlobalVariables.currentSection = data[index]['section'];
                                    GlobalVariables.currentRackDesc = data[index]['rack_desc'];
                                    GlobalVariables.ableEditDelete = false;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ItemScannedListScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(primary: Colors.yellow[700]),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.doc_plaintext),
                                      Text("View-S"),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    GlobalVariables.currentLocationID = data[index]['location_id'];
                                    GlobalVariables.currentBusinessUnit = data[index]['business_unit'];
                                    GlobalVariables.currentDepartment = data[index]['department'];
                                    GlobalVariables.currentSection = data[index]['section'];
                                    GlobalVariables.currentRackDesc = data[index]['rack_desc'];
                                    GlobalVariables.ableEditDelete = false;

                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => ItemNotFoundScanScreen()),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(primary: Colors.yellow[700]),
                                  child: Row(
                                    children: [
                                      Icon(CupertinoIcons.doc_plaintext),
                                      Text("View-NF"),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Parse the batch date from your data
                                    final batchDate = DateFormat("yyyy-MM-dd").parse(countData[index]['batchDate']);
                                    final currentDateTime = DateTime.now();

                                    // Strip the time (hours, minutes, and seconds) from both dates
                                    final batchDateWithoutTime = DateTime(batchDate.year, batchDate.month, batchDate.day);
                                    final currentDateWithoutTime = DateTime(currentDateTime.year, currentDateTime.month, currentDateTime.day);

                                    // Check if batch date is behind current date
                                    if (batchDateWithoutTime.isBefore(currentDateWithoutTime)) {
                                      // Location is locked because the batch date is behind, show an alert message
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                              child: Text("Location Locked"),
                                            ),

                                            content: Text("This location is locked due to an expired Schedule date!! \n\nSCHEDULE DATE  $batchDate \nCURRENT DATE  $currentDateWithoutTime"),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop(); // Close the dialog
                                                },
                                                child: Text("OK"),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      return; // Disables the button by returning early
                                    } else {
                                      // If batch date is not behind, proceed with lock/unlock logic
                                      try {
                                        GlobalVariables.currentLocationID = data[index]['location_id'];
                                        GlobalVariables.currentBusinessUnit = data[index]['business_unit'];
                                        GlobalVariables.currentDepartment = data[index]['department'];
                                        GlobalVariables.currentSection = data[index]['section'];
                                        GlobalVariables.currentRackDesc = data[index]['rack_desc'];

                                        var dtls = data[index]['locked'] == 'true'
                                            ? "[LOCK][Audit Lock Rack (${data[index]['business_unit']}/${data[index]['department']}/${data[index]['section']}/${data[index]['rack_desc']})]"
                                            : "[LOCK][Audit Unlock Rack (${data[index]['business_unit']}/${data[index]['department']}/${data[index]['section']}/${data[index]['rack_desc']})]";

                                        GlobalVariables.isAuditLogged = false;
                                        await scanAuditModal(context, _sqfliteDBHelper, dtls);

                                        if (GlobalVariables.isAuditLogged) {
                                          if (data[index]['locked'].toString() == 'true') {
                                            await _lockUnlockLocation(index, false, false);
                                            Fluttertoast.showToast(
                                                msg: "Rack Unlocked",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.black54,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          } else {
                                            await _lockUnlockLocation(index, true, true);
                                            Fluttertoast.showToast(
                                                msg: "Rack locked",
                                                toastLength: Toast.LENGTH_SHORT,
                                                gravity: ToastGravity.BOTTOM,
                                                backgroundColor: Colors.black54,
                                                textColor: Colors.white,
                                                fontSize: 16.0);
                                          }
                                        }
                                      } catch (error) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Error: $error")),
                                        );
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    primary: data[index]['locked'] == 'true' ? Colors.red : Colors.red[200],
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        data[index]['locked'] == 'true' ? CupertinoIcons.lock_fill : CupertinoIcons.lock_open_fill,
                                      ),
                                      Text(data[index]['locked'] == 'true' ? "Locked" : "Unlock"),
                                    ],
                                  ),
                                ),
                              ),

                              // Padding(
                              //   padding: const EdgeInsets.only(right: 8.0),
                              //   child: ElevatedButton(
                              //     onPressed: () async {
                              //       if (!btnSyncClick) {
                              //         setState(() {
                              //           btnSyncClick = true;
                              //           indexClick = index;
                              //         });
                              //         var res = await checkConnection();
                              //         if (res == 'connected') {
                              //           showDialog(
                              //             barrierDismissible: false,
                              //             context: context,
                              //             builder: (BuildContext context) {
                              //               return CupertinoAlertDialog(
                              //                 title: Text("${sul.server(ServerUrl.urlCI)} Server"),
                              //                 content: Text("Continue to Sync in this Server?"),
                              //                 actions: <Widget>[
                              //                   TextButton(
                              //                     child: Text("Yes"),
                              //                     onPressed: () async {
                              //                       GlobalVariables.currentLocationID = data[index]['location_id'];
                              //                       GlobalVariables.currentBusinessUnit = data[index]['business_unit'];
                              //                       GlobalVariables.currentDepartment = data[index]['department'];
                              //                       GlobalVariables.currentSection = data[index]['section'];
                              //                       GlobalVariables.currentRackDesc = data[index]['rack_desc'];
                              //                       setState(() {
                              //                         btnSyncClick = false;
                              //                         indexClick = index;
                              //                       });
                              //                       Navigator.of(context).pop();
                              //                       Navigator.push(
                              //                         context,
                              //                         MaterialPageRoute(
                              //                             builder: (context) => SyncScannedItemScreen()),
                              //                       );
                              //                     },
                              //                   ),
                              //                   TextButton(
                              //                     child: Text("No"),
                              //                     onPressed: () {
                              //                       setState(() {
                              //                         btnSyncClick = false;
                              //                         indexClick = index;
                              //                       });
                              //                       Navigator.of(context).pop();
                              //                     },
                              //                   ),
                              //                 ],
                              //               );
                              //             },
                              //           );
                              //         } else {
                              //           setState(() {
                              //             btnSyncClick = false;
                              //             indexClick = index;
                              //           });
                              //           instantMsgModal(
                              //             context,
                              //             Icon(
                              //               CupertinoIcons.exclamationmark_circle,
                              //               color: Colors.red,
                              //               size: 40,
                              //             ),
                              //             Text("No Connection. Please connect to a network."),
                              //           );
                              //         }
                              //       }
                              //     },
                              //     style: ElevatedButton.styleFrom(primary: Colors.green),
                              //     child: Row(
                              //       children: [
                              //         btnSyncClick && indexClick == index
                              //             ? AnimatedBuilder(
                              //           animation: animationController,
                              //           child: Icon(CupertinoIcons.arrow_2_circlepath, color: Colors.white),
                              //           builder: (BuildContext context, Widget? _widget) {
                              //             return Transform.rotate(
                              //               angle: animationController.value * 40,
                              //               child: _widget,
                              //             );
                              //           },
                              //         )
                              //             : Icon(CupertinoIcons.arrow_2_circlepath),
                              //         Text("Sync"),
                              //       ],
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                          Divider(),
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
  Future _lockUnlockLocation(int index, bool value, bool done) async {
    var user = await _sqfliteDBHelper.selectU(GlobalVariables.logEmpNo);
    await await _sqfliteDBHelper.updateUserAssignAreaWhere(
      "locked = '" + value.toString() + "' , done = '" + done.toString() + "'",
      "emp_no = '${user[0]['emp_no']}' AND location_id = '${GlobalVariables.currentLocationID}'",
    );
    _refreshUserAssignAreaList();
  }

  Future _lockUnlockLocation2(bool value, bool done, String locID) async {
    var user = await _sqfliteDBHelper.selectU(GlobalVariables.logEmpNo);
    await _sqfliteDBHelper.updateUserAssignAreaWhere(
      "locked = '" + value.toString() + "' , done = '" + done.toString() + "'",
      "emp_no = '${user[0]['emp_no']}' AND location_id = '$locID'",
    );
  }

  _refreshUserAssignAreaList() async {
    _assignArea = [];
    countType = [];
    _assignArea = await _sqfliteDBHelper.selectUserArea(GlobalVariables.logEmpNo, sul.server(ServerUrl.urlCI));
    countType = await _sqfliteDBHelper.getCountTypeDate(GlobalVariables.logEmpNo, sul.server(ServerUrl.urlCI));

    // countType = await _sqfliteDBHelper.getCountTypeDate(GlobalVariables.logEmpNo);

    if (_assignArea.length > 0 && countType.length > 0) {
      //checking = false;
      if (mounted) setState(() {});
    } else {
      var user = int.parse(GlobalVariables.logEmpNo) * 1;
      _assignArea = await _sqfliteDBHelper.selectUserArea(user.toString(), sul.server(ServerUrl.urlCI));
      countType = await _sqfliteDBHelper.getCountTypeDate(user.toString(),sul.server(ServerUrl.urlCI));
      print("mao ni assign area: $_assignArea");
      print("kani ang counttype: $countType");
      print("-------");
      //checking = false;
      if (mounted) setState(() {});
    }
    if(checkingData){
      await checkCountItemAssignArea(_assignArea);
    }
    else{
      checkingData = false;
      this.checking = false;
    }
  }

}
