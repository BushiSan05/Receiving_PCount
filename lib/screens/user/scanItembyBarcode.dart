import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemCountModel.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/screens/user/barcodeInputSearch.dart';
import 'package:physicalcountv2/screens/user/itemNotFoundScanScreen.dart';
import 'package:physicalcountv2/screens/user/itemScannedListScreen.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/customLogicalModal.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:physicalcountv2/widget/itemNofFoundModal.dart';
import 'package:physicalcountv2/widget/scanAuditModal.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/models/itemNotFoundModel.dart';
import '../../widget/saveNotFoundBarcode.dart';
import '../../widget/saveNotFoundItemModal.dart';

class ScanItemBarcode extends StatefulWidget {
  const ScanItemBarcode({Key? key}) : super(key: key);
  @override
  _ScanItemBarcode createState() => _ScanItemBarcode();
}
class _ScanItemBarcode extends State<ScanItemBarcode> {
  late FocusNode myFocusNodeBarcode;
  late FocusNode myFocusNodeQty;
  final barcodeController = TextEditingController();
  final qtyController = TextEditingController();
  final auditIDController = TextEditingController();
  List units = [];
  bool initLoad = true;
  String barcode = '';
  List<ItemNotFound> itemNotFound = [];
  bool btnSaveEnabled = false;
  String itemCode = "";
  String itemDescription = "";
  String itemUOM = "";
  int convQty = 0;
  String dtItemScanned = "";
  ItemCount _itemCount = ItemCount();
  late SqfliteDBHelper _sqfliteDBHelper;
  Logs _log = Logs();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  // DateFormat timeFormat = DateFormat("hh:mm:ss aaa");
  DateFormat timeFormat = DateFormat("HH:mm:ss");
  List<ItemCount> _items = [];
  DateTime selectedDate = DateTime.now();
  final validCharacters = RegExp(r'^[0-9]+$');
  bool _loading = true;
  // DateTime selectedDate =
  //     DateTime.parse("0000-00-00"); //-0001-11-30 00:00:00.000
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != selectedDate)
      setState(() {
        selectedDate = picked!;
      });
  }

  @override
  void initState() {
    // _sqfliteDBHelper = SqfliteDBHelper.instance;
    scanBarcodeNormal();
    // getUnits();
    // if (mounted) setState(() {});
    // btnSaveEnabled = false;
    // itemCode = "Unknown";
    // itemDescription = "Unknown";
    // itemUOM = "Unknown";
    // if (mounted) setState(() {});
    // myFocusNodeBarcode = FocusNode();
    // myFocusNodeQty = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          leading : IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () async {
              await _refreshItemList();
              if (_items.length > 0) {
                customLogicalModal(
                    context,
                    Text("Are you finished scanning this area? Click YES to tag this area FINISHED. Setting this area to FINISHED will auto lock the area. Continue?"),
                        () => Navigator.pop(context), () async {
                  var dtls = "[FINISHED][Audit tag rack (${GlobalVariables.currentBusinessUnit}/${GlobalVariables.currentDepartment}/${GlobalVariables.currentSection}/${GlobalVariables.currentRackDesc}) to FINISHED]";
                  GlobalVariables.isAuditLogged = false;
                  await scanAuditModal(context, _sqfliteDBHelper, dtls);
                  if (GlobalVariables.isAuditLogged == true) {
                    var user = await _sqfliteDBHelper
                        .selectU(GlobalVariables.logEmpNo);
                    var value = true;
                    var done = true;
                    await _sqfliteDBHelper.updateUserAssignAreaWhere(
                      "locked = '" +
                          value.toString() +
                          "' , done = '" +
                          done.toString() +
                          "'",
                      "emp_no = '${user[0]['emp_no']}' AND location_id = '${GlobalVariables.currentLocationID}'",
                    );
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  }
                });
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          title: Row(
            children: [
              Flexible(
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    GlobalVariables.currentBusinessUnit +
                        "/" +
                        GlobalVariables.currentDepartment +
                        "/" +
                        GlobalVariables.currentSection +
                        "/" +
                        GlobalVariables.currentRackDesc,
                    maxLines: 2,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(CupertinoIcons.doc_plaintext),
              color: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemScannedListScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(CupertinoIcons.barcode_viewfinder),
              color: Colors.red,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ItemNotFoundScanScreen()),
                );
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children:<Widget> [
                  IconButton(
                      onPressed: () {
                        Navigator.push(
                            context,
                            PageTransition(
                                type: PageTransitionType.fade,
                                child: ScanItemBarcode()
                              // child: SearchProductsBarcode()
                            ));
                      },
                      icon: Icon(CupertinoIcons.barcode_viewfinder,
                          color: Colors.red)),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, right: 20.0),
                    child: TextButton(
                        onPressed: () {
                          selectedDate = DateTime.now();
                          barcodeController.clear();
                          qtyController.clear();
                          itemCode = "Unknown";
                          itemDescription = "Unknown";
                          itemUOM = "Unknown";
                          myFocusNodeBarcode.requestFocus();
                          btnSaveEnabled = false;
                          if (mounted) setState(() {});
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => BarcodeInputSearchScreen()),
                          ).then((value) {
                            if (value == true) {
                              barcodeController.text =
                                  GlobalVariables.searchItemBarcode;
                              searchItem(barcodeController.text);
                              print(barcodeController.text);
                              myFocusNodeQty.requestFocus();
                              if (mounted) setState(() {});
                            }
                          });
                        },
                        child: Text("Barcode Input")),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  autofocus: true,
                  focusNode: myFocusNodeBarcode,
                  style: TextStyle(fontSize: 50),
                  textAlign: TextAlign.center,
                  controller: barcodeController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8.0), //here your padding
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  onChanged: (value){
                    if(validCharacters.hasMatch(value)==false){
                      barcodeController.clear();
                    }
                  },
                  onFieldSubmitted: (value) {
                    searchItem(value);
                  },
                  // onChanged: (value){
                  //   if(value.isEmpty){
                  //     itemCode = 'Unknown';
                  //     itemDescription = 'Unknown';
                  //     itemUOM = 'Unknown';
                  //     if (mounted) setState(() {});
                  //   }else{
                  //     searchInputtedItem(value);
                  //   }
                  //     // myFocusNodeQty.requestFocus();
                  // },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Itemcode: ",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$itemCode",
                          style: TextStyle(fontSize: 25, color: Colors.black))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Description: ",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$itemDescription",
                          style: TextStyle(fontSize: 25, color: Colors.black))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Unit of Measure: ",
                          style: TextStyle(
                              fontSize: 25,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$itemUOM",
                          style: TextStyle(fontSize: 25, color: Colors.black))
                    ],
                  ),
                ),
              ),
              GlobalVariables.countType != 'ANNUAL' &&
                  GlobalVariables.enableExpiry == true
                  ? Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  children: [
                    Text("Expiry Date: ",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.blue),
                        onPressed: () => _selectDate(context),
                        child: Text(
                          selectedDate.toString() != "-0001-11-30 00:00:00.000" ? "${DateFormat('MMMM dd, yyyy').format(selectedDate)}" : "0000-00-00",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              )
                  : SizedBox(),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  children: [
                    Text("Quantity: ",
                        style: TextStyle(
                            fontSize: 25,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                    Container(
                      width: MediaQuery.of(context).size.width / 3,
                      child: TextFormField(
                        controller: qtyController,
                        focusNode: myFocusNodeQty,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 50),
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.all(8.0), //here your padding
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        onChanged: (value) {
                          print(validCharacters.hasMatch(value));
                          if(value.isEmpty){
                            btnSaveEnabled=false;
                          }
                          //RegExp(r'^[a-zA-Z0-9_\-=@,\.;]+$')
                          if(value.contains('.') || value.characters.first=='0' || validCharacters.hasMatch(value)==false){
                            qtyController.clear();
                            btnSaveEnabled = false;
                            if (mounted) setState(() {});
                          }
                          if (barcodeController.text.isNotEmpty &&
                              qtyController.text.isNotEmpty) {
                            if(qtyController.text.length<7){
                              btnSaveEnabled = true;
                              if (mounted) setState(() {});
                            }else{
                              instantMsgModal(
                                  context,
                                  Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: Colors.red,
                                    size: 40,
                                  ),
                                  Text("Quantity is substantial. Please input below 7 digits amount."));
                              qtyController.clear();
                              btnSaveEnabled = false;
                              if (mounted) setState(() {});
                            }
                            //  if (mounted) setState(() {});
                          } else {
                            btnSaveEnabled = false;
                            if (mounted) setState(() {});
                          }
                        },
                        onFieldSubmitted: (value){
                          qtyController.clear();
                          btnSaveEnabled=false;
                          if(mounted) setState(() {
                          });
                        },
                      ),
                    ),
                    Spacer(),
                    MaterialButton(
                      child: Row(
                        children: [
                          Icon(CupertinoIcons.delete_left, color: Colors.red),
                          Text(" Clear Fields", style: TextStyle(color: Colors.red, fontSize: 25)),
                        ],
                      ),
                      onPressed: () {
                        selectedDate = DateTime.now();
                        barcodeController.clear();
                        qtyController.clear();
                        itemCode = "Unknown";
                        itemDescription = "Unknown";
                        itemUOM = "Unknown";
                        myFocusNodeBarcode.requestFocus();
                        btnSaveEnabled = false;
                        if (mounted) setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, top: 8, bottom: 8.0),
                child: MaterialButton(
                  height: MediaQuery.of(context).size.height / 15,
                  minWidth: MediaQuery.of(context).size.width,
                  color: btnSaveEnabled ? Colors.green : Colors.grey[300],
                  child: Text("SAVE",
                      style: TextStyle(color: Colors.white, fontSize: 25)),
                  onPressed: () async {
                    if (btnSaveEnabled == true) {
                      if(itemCode=="Unknown" && itemDescription=="Unknown" && itemUOM=="Unknown" ){
                        instantMsgModal(
                            context,
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: Colors.red,
                              size: 40,
                            ),
                            Text("Error! Please click 'Done' button before saving."));
                      }else{
                        if (selectedDate.toString() !=
                            "-0001-11-30 00:00:00.000") {
                          var dtls = "[LOGIN] Audit scan ID to save item.";
                          GlobalVariables.isAuditLogged = false;
                          await scanAuditModal(context, _sqfliteDBHelper, dtls);
                          if (GlobalVariables.isAuditLogged == true) {
                            //     DateFormat dateFormat1 =
                            //     DateFormat("yyyy-MM-dd hh:mm:ss aaa");
                            DateFormat dateFormat1 = DateFormat("yyyy-MM-dd HH:mm:ss");
                            String dt = dateFormat1.format(DateTime.now());
                            _itemCount.barcode = barcodeController.text.trim();
                            _itemCount.itemcode = itemCode;
                            _itemCount.description = itemDescription;
                            _itemCount.uom = itemUOM;
                            _itemCount.qty = qtyController.text.trim();
                            _itemCount.conqty = (int.parse(qtyController.text.trim()) * convQty).toString();
                            _itemCount.location = GlobalVariables.currentBusinessUnit;
                            _itemCount.bu = GlobalVariables.currentDepartment;
                            _itemCount.area = GlobalVariables.currentSection;
                            _itemCount.rackno = GlobalVariables.currentRackDesc;
                            _itemCount.dateTimeCreated = dtItemScanned;
                            _itemCount.dateTimeSaved = dt;
                            _itemCount.empNo = GlobalVariables.logEmpNo;
                            _itemCount.exported = '';
                            GlobalVariables.countType != 'ANNUAL' && GlobalVariables.enableExpiry == true
                                ? _itemCount.expiry = selectedDate.toString()
                                : _itemCount.expiry = "0000-00-00";
                            _itemCount.locationid = GlobalVariables.currentLocationID;
                            await _sqfliteDBHelper.insertItemCount(_itemCount);
                            _log.date = dateFormat.format(DateTime.now());
                            _log.time = timeFormat.format(DateTime.now());
                            _log.device =
                            "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                            _log.user = "${GlobalVariables.logFullName}[Inventory Clerk]";
                            _log.empid = GlobalVariables.logEmpNo;
                            _log.details =
                            "[ADD][${GlobalVariables.logFullName} add item (barcode: ${barcodeController.text.trim()} description: $itemDescription) with qty of ${qtyController.text.trim()} $itemUOM to rack (${GlobalVariables.currentBusinessUnit}/${GlobalVariables.currentDepartment}/${GlobalVariables.currentSection}/${GlobalVariables.currentRackDesc})]";
                            await _sqfliteDBHelper.insertLog(_log);
                            myFocusNodeBarcode.requestFocus();
                            GlobalVariables.prevBarCode = barcodeController.text.trim();
                            GlobalVariables.prevItemCode = itemCode;
                            GlobalVariables.prevItemDesc = itemDescription;
                            GlobalVariables.prevItemUOM = itemUOM;
                            GlobalVariables.prevExpiry = DateFormat('MMMM dd, yyyy').format(selectedDate);
                            GlobalVariables.prevQty = qtyController.text.trim();
                            GlobalVariables.prevDTCreated = dt;
                            barcodeController.clear();
                            qtyController.clear();
                            itemCode = "Unknown";
                            itemDescription = "Unknown";
                            itemUOM = "Unknown";
                            selectedDate = DateTime.now();
                            btnSaveEnabled = false;
                            if (mounted) setState(() {});
                          }
                        } else {
                          instantMsgModal(
                              context,
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                              Text("Invalid Expiry Date."));
                        }
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: MediaQuery.of(context).size.height / 5.8,
                  width: MediaQuery.of(context).size.width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Row(
                          children: [
                            Text("PREVIOUS ITEM SAVED\n",
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(
                                "Date & Time: " +
                                    GlobalVariables.prevDTCreated +
                                    "\n",
                                style: TextStyle(
                                    fontSize: 15, color: Colors.white)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text("Barcode: " + GlobalVariables.prevBarCode,
                            style:
                            TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text("Itemcode: " + GlobalVariables.prevItemCode,
                            style:
                            TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Description: " + GlobalVariables.prevItemDesc,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Unit of Measure: " + GlobalVariables.prevItemUOM,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Expiry Date: " + GlobalVariables.prevExpiry,
                          style: TextStyle(fontSize: 15, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text("Quantity: " + GlobalVariables.prevQty,
                            style:
                            TextStyle(fontSize: 15, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  _refreshItemList() async {
    List<ItemCount> x = await _sqfliteDBHelper.fetchItemCountWhere(
        "empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}'");
    _items = x;
    if (mounted) setState(() {});
  }
  searchItem(String value) async {
    print(GlobalVariables.byCategory);
    print(GlobalVariables.byVendor);
//------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//
    if (GlobalVariables.byCategory == true &&
        GlobalVariables.byVendor == true) {
      print('//------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//');
      var x = await _sqfliteDBHelper.selectItemWhereCatVen(value,
          "AND ggroup IN (${GlobalVariables.categories}) AND vendor_name IN (${GlobalVariables.vendors})");
      if (x.length > 0) {
        itemCode = x[0]['item_code'];
        itemDescription = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeQty.requestFocus();
      } else {
        itemNotFoundModal(
            context,
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.red,
              size: 40,
            ),
            Text(
                "Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to category ${GlobalVariables.categories} 3.) Item is not belong to vendor ${GlobalVariables.vendors}"));
        itemCode = "Unknown";
        itemDescription = "Unknown";
        itemUOM = 'Unknown';
        barcodeController.clear();
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        qtyController.clear();
      }
    }
//------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//
//------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//
    if (GlobalVariables.byCategory == false &&
        GlobalVariables.byVendor == false) {
      print('//------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//');
      var x = await _sqfliteDBHelper.selectItemWhere(value);
      print('VALUE : $value');
      if (x.length > 0) {
        itemCode = x[0]['item_code'];
        itemDescription = x[0]['extended_desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeQty.requestFocus();
      } else {
        showAlertDialog();
        // itemNotFoundModal(
        //     context,
        //     Icon(
        //       CupertinoIcons.exclamationmark_circle,
        //       color: Colors.red,
        //       size: 40,
        //     ),
        //     Text("Item not found. Reason(s): 1.) Barcode not registered"));
        itemCode = "Unknown";
        itemDescription = "Unknown";
        itemUOM = 'Unknown';
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        barcodeController.clear();
        qtyController.clear();
      }
    }
//------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//
//------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//
    if (GlobalVariables.byCategory == true &&
        GlobalVariables.byVendor == false) {
      print('//------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//');
      var x = await _sqfliteDBHelper.selectItemWhereCatVen(
          value, "AND ggroup IN (${GlobalVariables.categories})");
      if (x.length > 0) {
        itemCode = x[0]['item_code'];
        itemDescription = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeQty.requestFocus();
      } else {
        itemNotFoundModal(
            context,
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.red,
              size: 40,
            ),
            Text(
                "Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to category ${GlobalVariables.categories}"));
        itemCode = "Unknown";
        itemDescription = "Unknown";
        itemUOM = 'Unknown';
        barcodeController.clear();
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        qtyController.clear();
      }
    }
//------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//
//------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//
    if (GlobalVariables.byCategory == false &&
        GlobalVariables.byVendor == true) {
      print('//------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//');
      var x = await _sqfliteDBHelper.selectItemWhereCatVen(
          value, "AND vendor_name IN (${GlobalVariables.vendors})");
      if (x.length > 0) {
        itemCode = x[0]['item_code'];
        itemDescription = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeQty.requestFocus();
      } else {
        print(x);
        itemNotFoundModal(
            context,
            Icon(
              CupertinoIcons.exclamationmark_circle,
              color: Colors.red,
              size: 40,
            ),
            Text(
                "Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to vendor ${GlobalVariables.vendors}"));
        itemCode = "Unknown";
        itemDescription = "Unknown";
        itemUOM = 'Unknown';
        barcodeController.clear();
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        qtyController.clear();
      }
    }
//------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//
  }
  getUnits() async {
    units = await _sqfliteDBHelper.selectUnitsAll();
    List<ItemNotFound> x = await _sqfliteDBHelper.fetchItemNotFoundWhere(
        "location = '${GlobalVariables.currentLocationID}'");
    itemNotFound = x;
    _loading = false;
    if (mounted) setState(() {});
  }
  showAlertDialog(){
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: new Text("Item not found!"),
          content: new Text("Would you like to add the item to not found list?"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Yes"),
              onPressed: () async{
                await saveNotFoundBarcode(context, _sqfliteDBHelper, units);
                Navigator.of(context).pop();
              },
            ),
            new TextButton  (
              child: new Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> scanBarcodeNormal() async {
    String barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
          '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      print(barcodeScanRes);
    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    barcode = barcodeScanRes;
    initLoad = false;
    // GlobalVariables.searchProduct = [];
    if (mounted) setState(() {});
    // print(barcode);
    // await loadOffset();
  }
  //Future<bool>
  searchInputtedItem(String data)async{
    var x = await _sqfliteDBHelper.selectItemWhere(data);
    if (x.length > 0) {
      itemCode = x[0]['item_code'];
      itemDescription = x[0]['desc'];
      itemUOM = x[0]['uom'];
      dtItemScanned = dateFormat.format(DateTime.now()) + " " + timeFormat.format(DateTime.now());
      convQty = int.parse(x[0]['conversion_qty']);
      if (mounted) setState(() {});
      //  return Future<bool>.value(true);
    }else{
      itemCode = 'Unknown';
      itemDescription = 'Unknown';
      itemUOM = 'Unknown';
      if (mounted) setState(() {});
      //   return Future<bool>.value(false);
    }
  }

  bool validateCredentials(value){
    RegExp _regExp = RegExp(r'^[0-9]+$');
    if(_regExp.hasMatch(value)){
      print('TRUE NI SIYA');
      print(_regExp.hasMatch(value));
      return true;
    }
    else{
      print('FALSE NI SIYA');
      return false;
    }

  }


//   searchInputtedItem(String value) async {
//     print(GlobalVariables.byCategory);
//     print(GlobalVariables.byVendor);
// //------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//
//     if (GlobalVariables.byCategory == true &&
//         GlobalVariables.byVendor == true) {
//       print('//------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//');
//       var x = await _sqfliteDBHelper.selectItemWhereCatVen(value,
//           "AND ggroup IN (${GlobalVariables.categories}) AND vendor_name IN (${GlobalVariables.vendors})");
//       if (x.length > 0) {
//         itemCode = x[0]['item_code'];
//         itemDescription = x[0]['desc'];
//         itemUOM = x[0]['uom'];
//         dtItemScanned = dateFormat.format(DateTime.now()) +
//             " " +
//             timeFormat.format(DateTime.now());
//         convQty = int.parse(x[0]['conversion_qty']);
//         if (mounted) setState(() {});
//         myFocusNodeQty.requestFocus();
//       } else {
//         // itemNotFoundModal(
//         //     context,
//         //     Icon(
//         //       CupertinoIcons.exclamationmark_circle,
//         //       color: Colors.red,
//         //       size: 40,
//         //     ),
//         //     Text("Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to category ${GlobalVariables.categories} 3.) Item is not belong to vendor ${GlobalVariables.vendors}"));
//         itemCode = "Unknown";
//         itemDescription = "Unknown";
//         itemUOM = 'Unknown';
//         barcodeController.clear();
//         if (mounted) setState(() {});
//         myFocusNodeBarcode.requestFocus();
//         qtyController.clear();
//       }
//     }
// //------BY CATEGORY == TRUE AND BY VENDOR = TRUE------//
// //------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//
//     if (GlobalVariables.byCategory == false &&
//         GlobalVariables.byVendor == false) {
//       print('//------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//');
//       var x = await _sqfliteDBHelper.selectItemWhere(value);
//       print('VALUE : $value');
//       if (x.length > 0) {
//         itemCode = x[0]['item_code'];
//         itemDescription = x[0]['desc'];
//         itemUOM = x[0]['uom'];
//         dtItemScanned = dateFormat.format(DateTime.now()) +
//             " " +
//             timeFormat.format(DateTime.now());
//         convQty = int.parse(x[0]['conversion_qty']);
//         if (mounted) setState(() {});
//         myFocusNodeQty.requestFocus();
//       } else {
//        // showAlertDialog();
//         // itemNotFoundModal(
//         //     context,
//         //     Icon(
//         //       CupertinoIcons.exclamationmark_circle,
//         //       color: Colors.red,
//         //       size: 40,
//         //     ),
//         //     Text("Item not found. Reason(s): 1.) Barcode not registered"));
//         itemCode = "Unknown";
//         itemDescription = "Unknown";
//         itemUOM = 'Unknown';
//         barcodeController.clear();
//         if (mounted) setState(() {});
//         myFocusNodeBarcode.requestFocus();
//         qtyController.clear();
//       }
//     }
// //------BY CATEGORY == FALSE AND BY VENDOR = FALSE------//
// //------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//
//     if (GlobalVariables.byCategory == true &&
//         GlobalVariables.byVendor == false) {
//       print('//------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//');
//       var x = await _sqfliteDBHelper.selectItemWhereCatVen(
//           value, "AND ggroup IN (${GlobalVariables.categories})");
//       if (x.length > 0) {
//         itemCode = x[0]['item_code'];
//         itemDescription = x[0]['desc'];
//         itemUOM = x[0]['uom'];
//         dtItemScanned = dateFormat.format(DateTime.now()) +
//             " " +
//             timeFormat.format(DateTime.now());
//         convQty = int.parse(x[0]['conversion_qty']);
//         if (mounted) setState(() {});
//         myFocusNodeQty.requestFocus();
//       } else {
//         itemNotFoundModal(
//             context,
//             Icon(
//               CupertinoIcons.exclamationmark_circle,
//               color: Colors.red,
//               size: 40,
//             ),
//             Text(
//                 "Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to category ${GlobalVariables.categories}"));
//         itemCode = "Unknown";
//         itemDescription = "Unknown";
//         itemUOM = 'Unknown';
//         barcodeController.clear();
//         if (mounted) setState(() {});
//         myFocusNodeBarcode.requestFocus();
//         qtyController.clear();
//       }
//     }
// //------BY CATEGORY == TRUE AND BY VENDOR = FALSE------//
// //------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//
//     if (GlobalVariables.byCategory == false &&
//         GlobalVariables.byVendor == true) {
//       print('//------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//');
//       var x = await _sqfliteDBHelper.selectItemWhereCatVen(
//           value, "AND vendor_name IN (${GlobalVariables.vendors})");
//       if (x.length > 0) {
//         itemCode = x[0]['item_code'];
//         itemDescription = x[0]['desc'];
//         itemUOM = x[0]['uom'];
//         dtItemScanned = dateFormat.format(DateTime.now()) +
//             " " +
//             timeFormat.format(DateTime.now());
//         convQty = int.parse(x[0]['conversion_qty']);
//         if (mounted) setState(() {});
//         myFocusNodeQty.requestFocus();
//       } else {
//         print(x);
//         itemNotFoundModal(
//             context,
//             Icon(
//               CupertinoIcons.exclamationmark_circle,
//               color: Colors.red,
//               size: 40,
//             ),
//             Text(
//                 "Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to vendor ${GlobalVariables.vendors}"));
//         itemCode = "Unknown";
//         itemDescription = "Unknown";
//         itemUOM = 'Unknown';
//         barcodeController.clear();
//         if (mounted) setState(() {});
//         myFocusNodeBarcode.requestFocus();
//         qtyController.clear();
//       }
//     }
// //------BY CATEGORY == FALSE AND BY VENDOR = TRUE------//
//   }
}
