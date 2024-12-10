import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

import '../../db/models/itemNotFoundModel.dart';
import '../../widget/saveNotFoundBarcode.dart';
import '../../widget/saveNotFoundItemModal.dart';

class ItemScanningScreen extends StatefulWidget {
  const ItemScanningScreen({Key? key}) : super(key: key);
  @override
  _ItemScanningScreenState createState() => _ItemScanningScreenState();
}
class _ItemScanningScreenState extends State<ItemScanningScreen> {
  late FocusNode myFocusNodeBarcode;
  late FocusNode myFocusNodeLotno;
  // late FocusNode myFocusNodeBatno;
  late FocusNode myFocusNodeQty;
  final barcodeController = TextEditingController();
  final lotnoController = TextEditingController();
  // final batnoController = TextEditingController();
  final qtyController = TextEditingController();
  final auditIDController = TextEditingController();
  List units = [];
  List<ItemNotFound> itemNotFound = [];
  bool btnSaveEnabled = false;
  String itemCode = "";
  String itemDescription = "";
  String desc = "";
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
  List<ItemNotFound> _nf = [];
  // DateTime selectedDate = DateTime.now();
  DateTime? selectedDate;
  final validCharacters = RegExp(r'^[0-9]+$');
  bool _loading = true;
  // DateTime selectedDate =
  //     DateTime.parse("0000-00-00"); //-0001-11-30 00:00:00.000

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(), // Use DateTime.now() if selectedDate is null
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  bool resetSelectedDate() {
    setState(() {
      selectedDate = null;
    });
    return true;
  }

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    getUnits();
    if (mounted) setState(() {});
    btnSaveEnabled = false;
    itemCode = "Unknown";
    itemDescription = "Unknown";
    desc = "Unknown";
    itemUOM = "Unknown";
    if (mounted) setState(() {});
    myFocusNodeBarcode = FocusNode();
    myFocusNodeLotno = FocusNode();
    // myFocusNodeBatno = FocusNode();
    myFocusNodeQty = FocusNode();
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
              await _refreshNFList();
              print("sud nis NF $_nf");
              if (_items.length > 0 || _nf.length > 0 ) {
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
                GlobalVariables.ableEditDelete = true;
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
                GlobalVariables.ableEditDelete = true;
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
              SizedBox(height: 3.0),
              Row(
                children:<Widget> [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                             text: "Input/Scan Barcode: ",
                             style: TextStyle(
                             fontSize: 20,
                             color: Colors.black,
                             fontWeight: FontWeight.bold)
                          ),
                        ],
                      )
                    )
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
                    myFocusNodeQty.requestFocus();
                    searchItem(value);
                  },
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
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$itemCode",
                          style: TextStyle(fontSize: 20, color: Colors.black))
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Description: ",
                          style: TextStyle(
                              fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$itemDescription",
                          style: TextStyle(fontSize: 20, color: Colors.black))
                    ],
                  ),
                ),
              ),
              itemDescription != desc && desc != "" && desc !=  "Unknown"?
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Description2: ",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$desc",
                          style: TextStyle(fontSize: 20, color: Colors.black))
                    ],
                  ),
                ),
              ):
              SizedBox(height: 3.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                          text: "Unit of Measure: ",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                      TextSpan(
                          text: "$itemUOM",
                          style: TextStyle(fontSize: 20, color: Colors.black))
                    ],
                  ),
                ),
              ),
              SizedBox(height: 3.0),
                // Padding(
                //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                //   child: Row(
                //       children: [
                //       Text("Lot/Batch Number: ",
                //       style: TextStyle(
                //           fontSize: 20,
                //           color: Colors.blue,
                //           fontWeight: FontWeight.bold)),
                //   Container(
                //     width: MediaQuery.of(context).size.width / 4,
                //     child: TextFormField(
                //       textAlign: TextAlign.center,
                //       controller: lotnoController,
                //       focusNode: myFocusNodeLotno,
                //       style: TextStyle(fontSize: 23),
                //       decoration: InputDecoration(
                //         contentPadding:
                //         EdgeInsets.all(8.0), //here your padding
                //         border: OutlineInputBorder(
                //             borderRadius: BorderRadius.circular(3)),
                //       ),
                //       // onChanged: (value) {
                //         // print(validCharacters.hasMatch(value));
                //         // if (barcodeController.text.isNotEmpty &&
                //         //     lotnoController.text.isNotEmpty) {
                //         //     if (mounted) setState(() {});
                //         // } else {
                //         //   btnSaveEnabled = false;
                //         //   if (mounted) setState(() {});
                //         // }
                //       // },
                //       onFieldSubmitted: (value){
                //         myFocusNodeQty.requestFocus();
                //         btnSaveEnabled=false;
                //         if(mounted) setState(() {
                //         });
                //       },
                //         )
                //       )
                //     ]
                //   )
                // ),
              // SizedBox(height: 3.0),
              // Padding(
              //     padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              //     child: Row(
              //         children: [
              //           Text("Batch Number:  ",
              //               style: TextStyle(
              //                   fontSize: 20,
              //                   color: Colors.blue,
              //                   fontWeight: FontWeight.bold)),
              //           Container(
              //               width: MediaQuery.of(context).size.width / 5,
              //               child: TextFormField(
              //                 controller: batnoController,
              //                 focusNode: myFocusNodeBatno,
              //                 style: TextStyle(fontSize: 23),
              //                 decoration: InputDecoration(
              //                   contentPadding:
              //                   EdgeInsets.all(8.0), //here your padding
              //                   border: OutlineInputBorder(
              //                       borderRadius: BorderRadius.circular(3)),
              //                 ),
              //                 onChanged: (value) {
              //                   print(validCharacters.hasMatch(value));
              //                   if(value.isEmpty){
              //                     btnSaveEnabled=false;
              //                   }
              //                   if (barcodeController.text.isNotEmpty &&
              //                       batnoController.text.isNotEmpty) {
              //                     if (mounted) setState(() {});
              //                   } else {
              //                     btnSaveEnabled = false;
              //                     if (mounted) setState(() {});
              //                   }
              //                 },
              //                 onFieldSubmitted: (value){
              //                   myFocusNodeQty.requestFocus();
              //                   btnSaveEnabled=false;
              //                   if(mounted) setState(() {
              //                   });
              //                 },
              //               )
              //           )
              //         ]
              //     )
              // ),
              // SizedBox(height: 2.0),
              // GlobalVariables.countType == 'ANNUAL'
              // ? Padding(
              //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
              //   child: Row(
              //     children: [
              //       Text(
              //         "Expiry Date:    ",
              //         style: TextStyle(
              //           fontSize: 20,
              //           color: Colors.blue,
              //           fontWeight: FontWeight.bold,
              //         ),
              //       ),
              //       Container(
              //         width: MediaQuery.of(context).size.width / 3.5,
              //         child: ElevatedButton(
              //           style: ElevatedButton.styleFrom(
              //             backgroundColor: Colors.blue,
              //           ),
              //           onPressed: () => _selectDate(context),
              //           child: Text(
              //             selectedDate != null
              //                 ? "${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
              //                 : "Select Date", // Show "Select Date" if no date is selected
              //             style: TextStyle(fontSize: 16, color: Colors.white),
              //           ),
              //         ),
              //       ),
              //         Spacer(),
              //         MaterialButton(
              //           onPressed: () {
              //             resetSelectedDate();
              //           },
              //           child: Row(
              //             children: [
              //               Icon(CupertinoIcons.delete_left, color: Colors.red),
              //               Text(" Clear Expiry Date", style: TextStyle(color: Colors.red, fontSize: 18)),
              //             ],
              //           ),
              //         ),
              //     ],
              //   ),
              // )
              // : SizedBox(height: 5.0),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Row(
                  children: [
                    Text("Quantity:                   ",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                    Container(
                      width: MediaQuery.of(context).size.width / 5,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        controller: qtyController,
                        focusNode: myFocusNodeQty,
                        keyboardType: TextInputType.phone,
                        style: TextStyle(fontSize: 23),
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
                          Icon(CupertinoIcons.delete_simple, color: Colors.red),
                          Text(" Clear All Fields", style: TextStyle(color: Colors.red, fontSize: 25)),
                        ],
                      ),
                      onPressed: () {
                        barcodeController.clear();
                        qtyController.clear();
                        lotnoController.clear();
                        // batnoController.clear();
                        itemCode = "Unknown";
                        itemDescription = "Unknown";
                        desc = "Unknown";
                        itemUOM = "Unknown";
                        resetSelectedDate();
                        print(resetSelectedDate());
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
                      if (itemCode == "Unknown" &&
                          itemDescription == "Unknown" &&
                          itemUOM == "Unknown") {
                        instantMsgModal(
                            context,
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: Colors.red,
                              size: 40,
                            ),
                            Text(
                                "Error! Please click 'Done' button before saving."));
                      } else {
                        if (selectedDate.toString() !=
                            "-0001-11-30 00:00:00.000") {
                          var dtls = "[LOGIN] Audit scan ID to save item.";
                          GlobalVariables.isAuditLogged = false;
                          customLogicalModal(
                              context,
                              Text("Are you sure you want to save this item?"),
                                  () =>
                                  Navigator.pop(context),
                                  () async {
                                Navigator.pop(context);
                                await scanAuditModal(context, _sqfliteDBHelper, dtls);
                                if (GlobalVariables.isAuditLogged == true) {
                                  DateFormat dateFormat1 = DateFormat("yyyy-MM-dd HH:mm:ss");
                                  String dt = dateFormat1.format(DateTime.now());
                                  _itemCount.barcode = barcodeController.text.trim();
                                  _itemCount.itemcode = itemCode;
                                  _itemCount.description = itemDescription;
                                  _itemCount.desc = desc;
                                  _itemCount.uom = itemUOM;
                                  String lotno = lotnoController.text.trim().toString().toUpperCase();

                                  if (lotno.isNotEmpty) {
                                    _itemCount.lotno = lotno;
                                  } else {
                                    _itemCount.lotno = null;
                                  }

                                  // _itemCount.lotno = lotnoController.text.trim().toString().toUpperCase();
                                  // _itemCount.batno = batnoController.text.trim().toString().toUpperCase();
                                  // _itemCount.expiry = GlobalVariables.countType == 'ANNUAL' ? selectedDate?.toString() : null;
                                  _itemCount.expiry = GlobalVariables.countType == 'ANNUAL'
                                      ? selectedDate != null
                                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                      : null
                                      : null;
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
                                  _itemCount.locationid = GlobalVariables.currentLocationID;

                                  await _sqfliteDBHelper.insertItemCount(_itemCount);
                                  _log.date = dateFormat.format(DateTime.now());
                                  _log.time = timeFormat.format(DateTime.now());
                                  _log.device = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
                                  _log.user = "${GlobalVariables.logFullName}[Inventory Clerk]";
                                  _log.empid = GlobalVariables.logEmpNo;
                                  _log.details = "[ADD][${GlobalVariables.logFullName} add item (barcode: ${barcodeController.text.trim()} description: $itemDescription) with qty of ${qtyController.text.trim()} $itemUOM to rack (${GlobalVariables.currentBusinessUnit}/${GlobalVariables.currentDepartment}/${GlobalVariables.currentSection}/${GlobalVariables.currentRackDesc})]";

                                  await _sqfliteDBHelper.insertLog(_log);
                                  myFocusNodeBarcode.requestFocus();
                                  GlobalVariables.prevBarCode = barcodeController.text.trim();
                                  GlobalVariables.prevItemCode = itemCode;
                                  GlobalVariables.prevItemDesc = itemDescription;
                                  GlobalVariables.prevDesc = desc;
                                  GlobalVariables.prevItemUOM = itemUOM;
                                  GlobalVariables.prevLotno = lotnoController.text.isNotEmpty
                                      ? lotnoController.text.trim().toUpperCase()
                                      : "null";
                                  print("ang prevlot ky: ");
                                  print(GlobalVariables.prevLotno);
                                  // GlobalVariables.prevBatno = batnoController.text.trim().toUpperCase();
                                  // GlobalVariables.prevExpiry = DateFormat('MMMM dd, yyyy').format(selectedDate!);
                                  GlobalVariables.prevExpiry = selectedDate != null
                                      ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                      : "null";
                                  GlobalVariables.prevQty = qtyController.text.trim();
                                  GlobalVariables.prevDTCreated = dt;
                                  barcodeController.clear();
                                  lotnoController.clear();
                                  // batnoController.clear();
                                  qtyController.clear();
                                  itemCode = "Unknown";
                                  itemDescription = "Unknown";
                                  desc = "Unknown";
                                  itemUOM = "Unknown";
                                  resetSelectedDate;
                                  print(resetSelectedDate());
                                  btnSaveEnabled = false;
                                  if (mounted) setState(() {});
                                  Fluttertoast.showToast(
                                      msg: 'Barcode successfully saved.',
                                      toastLength: Toast.LENGTH_LONG,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.black54,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                }
                                // else {
                                //   instantMsgModal(
                                //       context,
                                //       Icon(
                                //         CupertinoIcons.exclamationmark_circle,
                                //         color: Colors.red,
                                //         size: 40,
                                //       ),
                                //       Text("Invalid Expiry Date."));
                                // }
                              }
                          );
                        }
                      }
                    }
                  }
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blueGrey,
                      borderRadius: BorderRadius.all(Radius.circular(10))),
                  height: MediaQuery.of(context).size.height / 5,
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
                                    fontSize: 14,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Spacer(),
                            Text(
                                "Date & Time: " +
                                    GlobalVariables.prevDTCreated +
                                    "\n",
                                style: TextStyle(
                                    fontSize: 14, color: Colors.white)),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text("Barcode: " + GlobalVariables.prevBarCode,
                            style:
                                TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text("Itemcode: " + GlobalVariables.prevItemCode,
                            style:
                                TextStyle(fontSize: 13, color: Colors.white)),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Description: " + GlobalVariables.prevItemDesc,
                          style: TextStyle(fontSize: 13, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Description2: " + GlobalVariables.prevDesc,
                          style: TextStyle(fontSize: 13, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text(
                          "Unit of Measure: " + GlobalVariables.prevItemUOM,
                          style: TextStyle(fontSize: 13, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      //   child: Text("Lot/Batch Number: " + GlobalVariables.prevLotno,
                      //     style: TextStyle(fontSize: 13, color: Colors.white),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      //   child: Text("Batch Number: " + GlobalVariables.prevBatno,
                      //     style: TextStyle(fontSize: 13, color: Colors.white),
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                      //   child: Text("Expiry Date: " + GlobalVariables.prevExpiry,
                      //     style: TextStyle(fontSize: 13, color: Colors.white),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Text("Quantity: " + GlobalVariables.prevQty,
                            style: TextStyle(fontSize: 13, color: Colors.white)),
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

  _refreshNFList() async {
    List<ItemNotFound> y = await _sqfliteDBHelper.fetchNFCountWhere(
        "empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}'");
    _nf = y;
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
        itemDescription = x[0]['extended_desc'];
        desc = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) + " " + timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeLotno.requestFocus();
        // myFocusNodeQty.requestFocus();
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
        desc = "Unknown";
        itemUOM = 'Unknown';
        barcodeController.clear();
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        lotnoController.clear();
        // batnoController.clear();
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
        desc = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeLotno.requestFocus();
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
        desc = "Unknown";
        itemUOM = 'Unknown';
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        barcodeController.clear();
        lotnoController.clear();
        // batnoController.clear();
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
        itemDescription = x[0]['extended_desc'];
        desc = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeLotno.requestFocus();
        // myFocusNodeQty.requestFocus();
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
        desc = "Unknown";
        itemUOM = 'Unknown';
        barcodeController.clear();
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        lotnoController.clear();
        // batnoController.clear();
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
        itemDescription = x[0]['extended_desc'];
        desc = x[0]['desc'];
        itemUOM = x[0]['uom'];
        dtItemScanned = dateFormat.format(DateTime.now()) +
            " " +
            timeFormat.format(DateTime.now());
        convQty = int.parse(x[0]['conversion_qty']);
        if (mounted) setState(() {});
        myFocusNodeLotno.requestFocus();
        // myFocusNodeQty.requestFocus();
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
        desc = "Unknown";
        itemUOM = 'Unknown';
        barcodeController.clear();
        if (mounted) setState(() {});
        myFocusNodeBarcode.requestFocus();
        lotnoController.clear();
        // batnoController.clear();
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

    //Future<bool>
    searchInputtedItem(String data)async{
    var x = await _sqfliteDBHelper.selectItemWhere(data);
    if (x.length > 0) {
      itemCode = x[0]['item_code'];
      itemDescription = x[0]['extended_desc'];
      desc = x[0]['desc'];
      itemUOM = x[0]['uom'];
      dtItemScanned = dateFormat.format(DateTime.now()) + " " + timeFormat.format(DateTime.now());
      convQty = int.parse(x[0]['conversion_qty']);
      if (mounted) setState(() {});
  //  return Future<bool>.value(true);
    }else{
      itemCode = 'Unknown';
      itemDescription = 'Unknown';
      desc = 'Unknown';
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
