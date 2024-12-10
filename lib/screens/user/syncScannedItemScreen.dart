import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemCountModel.dart';
import 'package:physicalcountv2/db/models/itemNotFoundModel.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/services/api.dart';
import 'package:physicalcountv2/syncscreentoserver.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;

import '../../widget/scanRovingITModal.dart';

class SyncScannedItemScreen extends StatefulWidget {
  const SyncScannedItemScreen({Key? key}) : super(key: key);

  @override
  _SyncScannedItemScreenState createState() => _SyncScannedItemScreenState();
}

class _SyncScannedItemScreenState extends State<SyncScannedItemScreen> with SingleTickerProviderStateMixin {
  final GlobalKey<SfSignaturePadState> signatureUserGlobalKey = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureAuditGlobalKey = GlobalKey();

  late SqfliteDBHelper _sqfliteDBHelper;
  List _myAudit = [];
  List _items = [];
  List _nfitems = [];
  List _auditTrail = [];
  List count_type=[];
  // String count_type="";
  String _auditor = "";
  bool checkingNetwork = false;
  bool btn_sync = false;
  bool btn_close_click = true;
  // late AnimationController animationController;
  Logs _log = Logs();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm:ss aaa");
  bool proceed = true;
  String userSignature = "";
  String auditSignature = "";

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    btn_sync = true;
    btn_close_click = false;
    if (mounted) setState(() {});
    _getMyAudit();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // print(GlobalVariables.saveAuditSignature);
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                if(!btn_sync){
                  btn_close_click = true;
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (BuildContext context){
                        return CupertinoAlertDialog(
                          title: Text("Syncing ongoing"),
                          content: Text("Continue to Close?"),
                          actions: <Widget>[
                            TextButton(
                              child: Text("Yes"),
                              onPressed: (){
                                btn_close_click = false;
                                Navigator.of(context).pop();
                                Navigator.of(context).pop();
                              },
                            ),
                            TextButton(
                              child: Text("No"),
                              onPressed: (){
                                Navigator.of(context).pop();
                                btn_close_click = false;
                              },
                            ),
                          ],
                        );
                      }
                  );
                }else{
                  Navigator.of(context).pop();
                }
              }
          ),
          title: Row(
            children: [
              Flexible(
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    "Sync Count Data to Database",
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Flexible(
              //     child: syncingStatus == false ? '' : syncingStatus==true ? AnimatedBuilder(
              //       animation: animationController,
              //          child: Icon(
              //           CupertinoIcons.arrow_2_circlepath,
              //           color: Colors.blue),
              //           builder: (BuildContext context,
              //           Widget? _widget) {
              //       return new Transform.rotate(
              //         angle: animationController.value * 40,
              //         child: _widget,
              //     );
              //   },
              //   )
              // ),
            ],
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            checkingNetwork ? LinearProgressIndicator(minHeight: 8.0) : SizedBox(),
            Spacer(),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "NOTE: \n  Make sure to review all the item before syncing. \n You cannot edit or delete all synced item.",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      fontSize: 23),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            MaterialButton(
              color: Colors.green,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      CupertinoIcons.tray_arrow_up_fill,
                      size: 25,
                      color: Colors.white,
                    ),
                    Text(
                      " Start to sync",
                      style: TextStyle(color: Colors.white, fontSize: 25),
                    ),
                  ],
                ),
              ),
              onPressed: () async {
                if(btn_sync){
                  //var res = "connected";
                  var res = await checkConnection();
                  print('RES: $res');
                  if (res == 'connected') {
                    btn_sync = false;

                    final dataUser = await signatureUserGlobalKey.currentState!.toImage(pixelRatio: 2.0); //3.0

                    final bytesUser = await dataUser.toByteData(format: ui.ImageByteFormat.png);

                    final dataAudit = await signatureAuditGlobalKey.currentState!.toImage(pixelRatio: 2.0); //3.0

                    final bytesAudit = await dataAudit.toByteData(format: ui.ImageByteFormat.png);

                    if (signatureUserGlobalKey.currentState!.toPathList().length == 0 || signatureAuditGlobalKey.currentState!.toPathList().length == 0) {
                      instantMsgModal(
                          context,
                          Icon(
                            CupertinoIcons.exclamationmark_circle,
                            color: Colors.red,
                            size: 40,
                          ),
                          Text("ERROR!\n"
                              "Both the user and auditor signatures are required before syncing",
                            textAlign: TextAlign.center,
                          )
                      );
                    } else {
                      userSignature = base64Encode(bytesUser!.buffer.asUint8List());
                      auditSignature = base64Encode(bytesAudit!.buffer.asUint8List());

                      continueSync(base64Encode(bytesUser!.buffer.asUint8List()),
                          base64Encode(bytesAudit!.buffer.asUint8List()));
                    }
                  }else{
                    instantMsgModal(
                        context,
                        Icon(
                          CupertinoIcons.exclamationmark_circle,
                          color: Colors.red,
                          size: 40,
                        ),
                        Text("No Connection. Please connect to a network."));
                    btn_sync = true;
                  }
                }
              },
            ),
            Spacer(),
            Divider(),
            Row(
              children: [
                Text(
                  "  User Signature",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton(
                    onPressed: () {
                      signatureUserGlobalKey.currentState!.clear();
                    },
                    child: Text("Clear"))
              ],
            ),
            Padding(
                padding: EdgeInsets.only(right: 8, left: 8),
                child: Container(
                    child: SfSignaturePad(
                      key: signatureUserGlobalKey,
                      //backgroundColor: Colors.white,
                      strokeColor: Colors.black,
                      minimumStrokeWidth: 1.0,
                      maximumStrokeWidth: 4.0,
                      backgroundColor: Colors.transparent,
                      // minimumStrokeWidth: 1.0,
                      // maximumStrokeWidth: 4.0,
                    ),

                    height: 150,
                    width: 300,
                    decoration:
                    BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        image: AssetImage("assets/images/signaturepad/guideLine.png"),
                        fit: BoxFit.cover,
                      ),))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${GlobalVariables.logFullName.toUpperCase()}",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Divider(),
            Row(
              children: [
                Text(
                  "  Checker Signature",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    signatureAuditGlobalKey.currentState!.clear();
                  },
                  child: Text("Clear"),
                ),
                // TextButton(
                //   onPressed: () async {
                //     signatureAuditGlobalKey.currentState!.clear();
                //     SharedPreferences prefss =
                //         await SharedPreferences.getInstance();

                //     final dataAudit = await signatureAuditGlobalKey
                //         .currentState!
                //         .toImage(pixelRatio: 3.0);
                //     final bytesAudit = await dataAudit.toByteData(
                //         format: ui.ImageByteFormat.png);

                //     prefss.setString('saveAuditSignature',
                //         base64Encode(bytesAudit!.buffer.asUint8List()));
                //   },
                //   child: Text("Save"),
                // ),
              ],
            ),
            Padding(
                padding: EdgeInsets.only(right: 10, left: 10),
                child: Container(
                    child: SfSignaturePad(
                        key: signatureAuditGlobalKey,
                        backgroundColor: Colors.transparent,
                        strokeColor: Colors.black,
                        minimumStrokeWidth: 1.0,
                        maximumStrokeWidth: 4.0),
                    height: 150,
                    width: 300,
                    decoration:
                    BoxDecoration(border: Border.all(color: Colors.grey),
                      image: DecorationImage(
                        image: AssetImage("assets/images/signaturepad/guideLine.png"),
                        fit: BoxFit.cover,
                      ),))),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "$_auditor",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Spacer(),
          ],
        ),
      ),
    );
  }
  _getMyAudit() async {
    _myAudit = [];
    _auditor = "";
    _myAudit = await _sqfliteDBHelper
        .findAuditByLocationId(GlobalVariables.currentLocationID);
    if (_myAudit.length > 0) {
      _auditor = _myAudit[0]['name'].toString().toUpperCase();
    }
    if (mounted) setState(() {});
  }
  tryCatch(String execute, List items)async{
    var timeLimit = const Duration(seconds: 15);
    var res;
    try{
      switch(execute) {
      //----| 1 |------
        case "advance-NF-items":
          res = await syncNfItem_adv(items, userSignature, auditSignature).timeout(timeLimit);
          break;
      //----| 2 |------
        case "advance-count-items":
          res = await syncItem_adv(items, userSignature, auditSignature).timeout(timeLimit);
          break;
      //----| 3 |------
        case "actual-NF-items":
          print("ACTUAL NFITEM CASE");
          res = await syncNfItem(items, userSignature, auditSignature).timeout(timeLimit);
          print("NF ITEMS :: $res");
          break;
      //----| 5 |------
        case "actual-count-items":
          print("ACTUAL COUNT CASE");
          res = await syncItem(items, userSignature, auditSignature).timeout(timeLimit);
          print("DATA SYNC :: $res");
          break;
      //----| 6 |------
        case "audit-trail":
          res = await syncAuditTrail(items).timeout(timeLimit);
          break;
      //----| 7 |------
        case "NF-Item-freegoods":
          res = await syncNfItem_freegoods(items, userSignature, auditSignature).timeout(timeLimit);
          break;
      //----| 8 |------
        case "count-Item-freegoods":
          res = await syncItem_freegoods(items, userSignature, auditSignature).timeout(timeLimit);
          break;
      }
      //var res = await syncNfItem_adv(_nfitems, bytesUser, bytesAudit).timeout(timeLimit);
      if (GlobalVariables.statusCode == 200) {
        if(res == true) { proceed = true; }
        else{
          proceed = false;
          var details = "[ASYNC][Something went wrong, During $execute sync.]";
          var text = "Something went wrong! Please try again Later";
          tryCatchLogs(details, text);
        }
      } else if (GlobalVariables.statusCode >= 400 && GlobalVariables.statusCode <= 499) {
        proceed = false;
        var details = "[ASYNC][Error: Client issued a malformed or illegal request, During $execute sync.]";
        var text = "Error: Client issued a malformed or illegal request.";
        tryCatchLogs(details, text);
      } else if (GlobalVariables.statusCode >= 500 || GlobalVariables.statusCode <= 599) {
        proceed = false;
        var details = "[ASYNC][Error: Internal server error, During $execute sync.]";
        var text = "Error: Internal server error.";
        tryCatchLogs(details, text);
      }
    } on TimeoutException catch (e) {
      var details = "[ASYNC][Connection is Low, During $execute sync. Error: $e]";
      var text = "Timeout Exception, please try again Later.";
      tryCatchLogs(details, text);
    } on SocketException catch (e) {
      proceed = false;
      var details = "[ASYNC][Connection is Low, During $execute sync. Error: $e]";
      var text = "Socket Exception: $e";
      tryCatchLogs(details, text);
    } on HttpException {
      proceed = false;
      var details = "[ASYNC][Error: An HTTP error occurred, During $execute sync.]";
      var text = "Error: An HTTP error occurred. Please try again later.";
      tryCatchLogs(details, text);
    } on FormatException {
      proceed = false;
      print("ERROR :: $FormatException");
      var details = "[ASYNC][Error: Format exception error occurred. During $execute sync.]";
      var text = "Error: Format exception error occurred. Please try again later.";
      tryCatchLogs(details, text);
    }
  }

  tryCatchLogs(String details, String text)async{
    _log.date    = dateFormat.format(DateTime.now());
    _log.time    = timeFormat.format(DateTime.now());
    _log.device  = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
    _log.user    = GlobalVariables.logFullName;
    _log.empid   = GlobalVariables.logEmpNo;
    _log.details = details;
    await _sqfliteDBHelper.insertLog(_log);
    Navigator.of(context).pop();
    instantMsgModal(
        context,
        Icon(
          CupertinoIcons.exclamationmark_circle,
          color: Colors.red,
          size: 40,
        ),
        Text(text));
  }
  continueSync(String bytesUser, String bytesAudit) async {
    //bool proceed = true;
    // var timeLimit = const Duration(seconds: 5);
    print(GlobalVariables.currentLocationID);
    checkingNetwork = true;
    if (mounted) setState(() {});
    //var res = "connected";
    var res = await checkConnection();
    // checkingNetwork = false;
    // if (mounted) setState(() {});
//-------------------CONNECTION CHECK!-----------------------
    if (res == 'error') {
      checkingNetwork = false;
      if (mounted) setState(() {});
      instantMsgModal(
          context,
          Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.red,
            size: 40,
          ),
          Text("${GlobalVariables.httpError}"));
      btn_sync = true;
    } else if (res == 'errornet') {
      checkingNetwork = false;
      if (mounted) setState(() {});
      instantMsgModal(
          context,
          Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.red,
            size: 40,
          ),
          Text("${GlobalVariables.httpError}"));
      btn_sync = true;
    } else {
      if(res == 'connected'){
        await _getCountedItems();
        await _getCountedNfItems();
        await _getAuditTrail();
        await _getCountType();
        print('COUNT TYPE: ${count_type[0]['countType']}');
//-----------------ADVANCE-----------------------
        //NF ITEMS//
        if(count_type[0]['countType']=='ADVANCE'){
          if(_nfitems.length == 0 && _items.length == 0){
            checkingNetwork = false;
            if (mounted) setState(() {
              // Navigator.pop(context);
            });
            instantMsgModal(
                context,
                Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: Colors.red,
                  size: 40,
                ),
                Text("No data to sync."));
            btn_sync = true;
            return;
          }
          else  {
            if (_nfitems.length > 0 && proceed) {
              print("NF ITEMS :: $_nfitems");
              /*print("NF ITEMS :: $_nfitems");
              print("NF ITEMS :: $_nfitems");*/

              //-------------try catch here 1--------------------
              await tryCatch("advance-NF-items", _nfitems);
              //-------------try catch end here 1--------------------
              if (proceed) {
                await _sqfliteDBHelper.updateItemNotFoundByLocation(
                    GlobalVariables.currentLocationID, "exported = 'EXPORTED'");
                _log.date     = dateFormat.format(DateTime.now());
                _log.time     = timeFormat.format(DateTime.now());
                _log.device   = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                _log.user     = GlobalVariables.logFullName;
                _log.empid    = GlobalVariables.logEmpNo;
                _log.details  = "[SYNCED][USER Synced Not Found Item on Location ID: ${GlobalVariables.currentLocationID}]";
                await _sqfliteDBHelper.insertLog(_log);
              }
            }
            //COUNT
            if (_items.length > 0 && proceed) {
              //-------------try catch here 2--------------------
              await tryCatch("advance-count-items", _items);
              //-------------try catch end here 2--------------------
              if (proceed) {
                await _sqfliteDBHelper.updateItemCountByLocation(
                    GlobalVariables.currentLocationID, "exported = 'EXPORTED'");
                _log.date = dateFormat.format(DateTime.now());
                _log.time = timeFormat.format(DateTime.now());
                _log.device =
                "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                _log.user = GlobalVariables.logFullName;
                _log.empid = GlobalVariables.logEmpNo;
                _log.details =
                "[SYNCED][USER Synced Count Item on Location ID: ${GlobalVariables
                    .currentLocationID}]";
                await _sqfliteDBHelper.insertLog(_log);
              }
            }
            if (_auditTrail.length > 0 && proceed) {
              //-------------try catch here 3--------------------
              await tryCatch("audit-trail", _auditTrail);
              //-------------try catch end here 3--------------------
              if (proceed) {
                checkingNetwork = false;
                if (mounted) setState(() {
                  // Navigator.pop(context);
                });
                await _sqfliteDBHelper.updateTblAuditTrail();
                if(btn_close_click){
                  btn_close_click = false;
                  Navigator.of(context).pop();
                }
                Navigator.of(context).pop();
                instantMsgModal(
                    context,
                    Icon(
                      CupertinoIcons.checkmark_alt_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                    Text("Data successfully synced."));
              }
            }
          }


//----------------------ACTUAL------------------------------
        } else if(count_type[0]['countType']=='ACTUAL'){
          if(_nfitems.length == 0 && _items.length == 0){
            checkingNetwork = false;
            if (mounted) setState(() {
              // Navigator.pop(context);
            });
            instantMsgModal(
                context,
                Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: Colors.red,
                  size: 40,
                ),
                Text("No data to sync."));
            btn_sync = true;
            return;
          }else{
            if (_nfitems.length > 0 && proceed) {
              //-------------try catch here 4--------------------
              await tryCatch("actual-NF-items", _nfitems);
              print("mao nig nfitems $_nfitems");
              //-------------try catch end here 4--------------------
              if (proceed) {
                // await _sqfliteDBHelper.updateItemCountByLocation(
                await _sqfliteDBHelper.updateNFItemCountByUser(
                    GlobalVariables.logEmpNo, "exported = 'EXPORTED'");
                _log.date     = dateFormat.format(DateTime.now());
                _log.time     = timeFormat.format(DateTime.now());
                _log.device   = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                _log.user     = GlobalVariables.logFullName;
                _log.empid    = GlobalVariables.logEmpNo;
                _log.details  = "[SYNCED][USER Synced Not Found Item on Location ID: ${GlobalVariables.currentLocationID}]";
                await _sqfliteDBHelper.insertLog(_log);
              }
              print("nabilin sa NF $_nfitems");
            }
            //COUNT
            if (_items.length > 0 && proceed) {
              //-------------try catch here 5--------------------
              print("ACTUAL ITEMS :: $_items");
              await tryCatch("actual-count-items", _items);
              //-------------try catch end here 5--------------------
              if (proceed) {
                // await _sqfliteDBHelper.updateItemCountByLocation(
                await _sqfliteDBHelper.updateItemCountByUser(
                    GlobalVariables.logEmpNo, "exported = 'EXPORTED'");
                _log.date    = dateFormat.format(DateTime.now());
                _log.time    = timeFormat.format(DateTime.now());
                _log.device  = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                _log.user    = GlobalVariables.logFullName;
                _log.empid   = GlobalVariables.logEmpNo;
                _log.details = "[SYNCED][USER Synced Count Item on Location ID: ${GlobalVariables.currentLocationID}]";
                await _sqfliteDBHelper.insertLog(_log);
              }
              print("nabilin sa Count $_items");
            }
            if (_auditTrail.length > 0 && proceed) {
              //-------------try catch here 6--------------------
              await tryCatch("audit-trail", _auditTrail);
              //-------------try catch end here 6--------------------
              if (proceed) {
                checkingNetwork = false;
                if (mounted) setState(() {
                  // Navigator.pop(context);
                });
                await _sqfliteDBHelper.updateTblAuditTrail();
                if(btn_close_click){
                  btn_close_click = false;
                  Navigator.of(context).pop();
                }
                Navigator.of(context).pop();
                instantMsgModal(
                    context,
                    Icon(
                      CupertinoIcons.checkmark_alt_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                    Text("Data successfully synced."));
                // _log.details = "[SYNCED][Location ID: ${GlobalVariables.currentLocationID} is done syncing.]";
                // await _sqfliteDBHelper.insertLog(_log);
              } else {
                checkingNetwork = false;
                if (mounted) setState(() {});
                instantMsgModal(
                    context,
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text("Something went wrong.")
                );
                btn_sync = true;
              }
            } else {
              checkingNetwork = false;
              if (mounted) setState(() {
                //Navigator.pop(context);
              });
              instantMsgModal(
                  context,
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: Colors.red,
                    size: 40,
                  ),
                  Text("No audit-trail data."));
              btn_sync =true;
              return;
            }
          }
//-------------------FREE GOODS------------------------
        }else{
          if(_nfitems.length == 0 && _items.length == 0){
            checkingNetwork = false;
            if (mounted) setState(() {
              // Navigator.pop(context);
            });
            instantMsgModal(
                context,
                Icon(
                  CupertinoIcons.exclamationmark_circle,
                  color: Colors.red,
                  size: 40,
                ),
                Text("No data to sync."));
            btn_sync = true;
            return;
          }else{
            if (_nfitems.length > 0 && proceed) {
              //-------------try catch here 7--------------------
              await tryCatch("NF-Item-freegoods",_nfitems);
              //-------------try catch end here 7--------------------
              if (proceed) {
                await _sqfliteDBHelper.updateItemNotFoundByLocation(
                    GlobalVariables.currentLocationID, "exported = 'EXPORTED'");
                _log.date     = dateFormat.format(DateTime.now());
                _log.time     = timeFormat.format(DateTime.now());
                _log.device   = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                _log.user     = GlobalVariables.logFullName;
                _log.empid    = GlobalVariables.logEmpNo;
                _log.details  = "[SYNCED][USER Synced Not Found Item on Location ID: ${GlobalVariables.currentLocationID}]";
                await _sqfliteDBHelper.insertLog(_log);
              }
            }
            //COUNT
            if (_items.length > 0 && proceed) {
              //-------------try catch here 8--------------------
              await tryCatch("count-Item-freegoods",_items);
              //-------------try catch end here 8--------------------
              if (proceed) {
                await _sqfliteDBHelper.updateItemCountByLocation(
                    GlobalVariables.currentLocationID, "exported = 'EXPORTED'");
                _log.date    = dateFormat.format(DateTime.now());
                _log.time    = timeFormat.format(DateTime.now());
                _log.device  = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                _log.user    = GlobalVariables.logFullName;
                _log.empid   = GlobalVariables.logEmpNo;
                _log.details = "[SYNCED][USER Synced Count Item on Location ID: ${GlobalVariables.currentLocationID}]";
                await _sqfliteDBHelper.insertLog(_log);
              }
            }
            if (_auditTrail.length > 0 && proceed) {
              //-------------try catch here 9--------------------
              await tryCatch("audit-trail", _auditTrail);
              //-------------try catch end here 9--------------------
              if (proceed) {
                checkingNetwork = false;
                if (mounted) setState(() {
                  // Navigator.pop(context);
                });
                await _sqfliteDBHelper.updateTblAuditTrail();
                if(btn_close_click){
                  btn_close_click = false;
                  Navigator.of(context).pop();
                }
                Navigator.of(context).pop();
                instantMsgModal(
                    context,
                    Icon(
                      CupertinoIcons.checkmark_alt_circle,
                      color: Colors.green,
                      size: 40,
                    ),
                    Text("Data successfully synced."));
              } else {
                checkingNetwork = false;
                if (mounted) setState(() {});
                instantMsgModal(
                    context,
                    Icon(
                      CupertinoIcons.exclamationmark_circle,
                      color: Colors.red,
                      size: 40,
                    ),
                    Text("Something went wrong.")
                );
                btn_sync = true;
              }
            } else {
              checkingNetwork = false;
              if (mounted) setState(() {
                //Navigator.pop(context);
              });
              instantMsgModal(
                  context,
                  Icon(
                    CupertinoIcons.exclamationmark_circle,
                    color: Colors.red,
                    size: 40,
                  ),
                  Text("No data to sync."));
              btn_sync = true;
              return;
            }
          }
        }
      }
    }
  }
  _getCountedItems() async {
    _items = await _sqfliteDBHelper.selectItemCountRawQuery(
        "SELECT itemcode, barcode, desc, description, uom, lot_number, expiry, qty, business_unit, department, section, rack_desc, datetimecreated, datetimesaved, location_id, conqty FROM ${ItemCount.tblItemCount} WHERE empno = '${GlobalVariables.logEmpNo}' AND exported != 'EXPORTED'");
    print("ITEMS :: $_items");
  }
  _getCountedNfItems() async {
    _nfitems = await _sqfliteDBHelper.selectItemNotFoundRawQuery(
        "SELECT barcode, inputted_description, itemcode, uom, qty, location, datetimecreated, business_unit, department, section, empno, rack_desc FROM ${ItemNotFound.tblItemNotFound} WHERE empno = '${GlobalVariables.logEmpNo}' AND exported != 'EXPORTED'");
    print("NFItems :: $_nfitems");
  }

  _getCountType()async{
    count_type = await _sqfliteDBHelper.getCountType(GlobalVariables.currentLocationID);
  }

  _getAuditTrail() async{
    _auditTrail = await _sqfliteDBHelper.getAuditTrail();
  }

}
