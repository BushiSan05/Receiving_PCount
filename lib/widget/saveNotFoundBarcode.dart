import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemNotFoundModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/bodySize.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/scanAuditModal.dart';

import 'customLogicalModal.dart';
import 'instantMsgModal.dart';

saveNotFoundBarcode(BuildContext context, SqfliteDBHelper db, List units) {
  late FocusNode myFocusNodeBarcode;
  late FocusNode myFocusNodeDesc;
  late FocusNode myFocusNodeLotno;
  // late FocusNode myFocusNodeBatno;
  late FocusNode myFocusNodeQty;

  myFocusNodeBarcode = FocusNode();
  myFocusNodeDesc = FocusNode();
  myFocusNodeLotno = FocusNode();
  // myFocusNodeBatno = FocusNode();
  myFocusNodeQty = FocusNode();

  final barcodeController = TextEditingController();
  final descController = TextEditingController();
  final lotnoController = TextEditingController();
  // final batnoController = TextEditingController();
  final qtyController = TextEditingController();

  bool btnSaveEnabled = false;

  ItemNotFound _itemNotFound = ItemNotFound();
  List itemNotFound;
  // var _uom = ["MALE", "FEMALE"];
  var _uom = units;
  var _uomm = [];
  var barcode_itemcode = ['Barcode','Item Code'];
  late FocusNode _node;
  var selected='';
  final validCharacters = RegExp(r'^[0-9]+$');
  DateTime? selectedDate;


  DateTime? resetSelectedDate(DateTime? currentSelectedDate) {
    return null; // Resetting the date to null
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(), // Use DateTime.now() if selectedDate is null
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null)
      {
        selectedDate = picked;
    }
  }



  units.forEach((element) {
    _uomm.add(element['uom']);
  });
  String _selectedUom = _uom[0]['uom'];
  void save()async{
    DateFormat dateFormat1 =
    DateFormat("yyyy-MM-dd hh:mm:ss aaa");
    String dt = dateFormat1.format(DateTime.now());
    _itemNotFound.barcode =
        barcodeController.text.trim();
    _itemNotFound.uom = _selectedUom.trim();
    // _itemNotFound.lotno = lotnoController.text.trim();
    // _itemNotFound.batno = batnoController.text.trim();
    _itemNotFound.qty = qtyController.text.trim();
    DateTime? selectedDate;
    _itemNotFound.location =
        GlobalVariables.currentLocationID;
    _itemNotFound.exported = 'false';
    _itemNotFound.dateTimeCreated = dt;
    //ADDED ATTRIBUTES TO NOT FOUND TABLE
    _itemNotFound.businessUnit=GlobalVariables.currentBusinessUnit;
    _itemNotFound.department=GlobalVariables.currentDepartment;
    _itemNotFound.section=GlobalVariables.currentSection;
    _itemNotFound.empno=GlobalVariables.logEmpNo;
    _itemNotFound.rack_desc=GlobalVariables.currentRackDesc;
    _itemNotFound.description='barcode';
    await db.insertItemNotFound(_itemNotFound);
    myFocusNodeBarcode.requestFocus();
    barcodeController.clear();
    qtyController.clear();
    btnSaveEnabled = false;
    // setModalState(() {});
    var rs = await db.selectItemNotFoundWhere(
        GlobalVariables.currentLocationID);
    print(rs);
  }
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: BodySize.hghth / 1.3,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    topLeft: Radius.circular(10))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 360.0),
                    child: Text("Barcode",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                  ),
                  //01000006481
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: TextFormField(
                      autofocus: true,
                      focusNode: myFocusNodeBarcode,
                      style: TextStyle(fontSize: 30),
                      textAlign: TextAlign.center,
                      controller: barcodeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(8.0), //here your padding
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(3)),
                      ),
                      onFieldSubmitted: (value) async {
                        myFocusNodeDesc.requestFocus();
                        var res=await db.validateBarcode(value);
                        itemNotFound=res;
                        if(itemNotFound.isNotEmpty){
                          instantMsgModal(
                              context,
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                              Text("Item is in the masterfile."));
                          barcodeController.clear();
                          btnSaveEnabled = false;
                        }
                      },
                      //SCAN NOT FOUND BARCODE
                      onChanged: (value) async {
                        if(validCharacters.hasMatch(value)==false){
                          myFocusNodeDesc.requestFocus();
                          barcodeController.clear();
                          instantMsgModal(
                              context,
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                              Text("ERROR! Please input number only!"));
                        }
                        if(value.isEmpty || _selectedUom=='' || qtyController.text.isEmpty){
                          btnSaveEnabled=false;
                          setModalState(() {});
                        }else{
                          btnSaveEnabled=true;
                          setModalState(() {});
                        }
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Description",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),

                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Container(
                      child: TextFormField(
                        autofocus: true,
                        focusNode: myFocusNodeDesc,
                        style: TextStyle(fontSize: 20),
                        controller: descController,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.all(8.0), //here your padding
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        onFieldSubmitted: (value) {
                          if (barcodeController.text.isNotEmpty)
                          btnSaveEnabled=false;
                          myFocusNodeQty.requestFocus();
                        },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Unit of Measure",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0),
                    child: Container(
                      width: BodySize.wdth / 2,
                      height: 50.0,
                    child: DropdownSearch<dynamic>(
                      items: _uomm,
                      showSearchBox: true,
                      selectedItem: _selectedUom,
                      onChanged: (val) {
                        _selectedUom = val.toString();
                        if(barcodeController.text.isEmpty || val=='' || qtyController.text.isEmpty){
                          btnSaveEnabled=false;
                          setModalState(() {});
                        }else{
                          btnSaveEnabled=true;
                          _selectedUom = val.toString();
                          setModalState(() {});
                        }
                        setModalState(() {});
                      },
                    ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //   child: Text("Lot/Batch Number",
                  //       style: TextStyle(
                  //           fontSize: 20,
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold)),
                  //
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 20.0, right: 20.0, bottom: 10.0),
                  //   child: Container(
                  //     width: BodySize.wdth / 3,
                  //     child: TextFormField(
                  //       textAlign: TextAlign.center,
                  //       autofocus: true,
                  //       focusNode: myFocusNodeLotno,
                  //       style: TextStyle(fontSize: 20),
                  //       controller: lotnoController,
                  //       // keyboardType: TextInputType.number,
                  //       decoration: InputDecoration(
                  //         contentPadding:
                  //         EdgeInsets.all(8.0), //here your padding
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(3)),
                  //       ),
                  //       onFieldSubmitted: (value) {
                  //         if (barcodeController.text.isNotEmpty &&
                  //             // lotnumController.text.isNotEmpty &&
                  //             _selectedUom!='')
                  //         myFocusNodeQty.requestFocus();
                  //         btnSaveEnabled=false;
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //   child: Text("Batch Number",
                  //       style: TextStyle(
                  //           fontSize: 20,
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold)),
                  //
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 20.0, right: 20.0, bottom: 10.0),
                  //   child: Container(
                  //     width: BodySize.wdth / 2,
                  //     child: TextFormField(
                  //       autofocus: true,
                  //       focusNode: myFocusNodeBatno,
                  //       style: TextStyle(fontSize: 20),
                  //       controller: batnoController,
                  //       // keyboardType: TextInputType.number,
                  //       decoration: InputDecoration(
                  //         contentPadding:
                  //         EdgeInsets.all(8.0), //here your padding
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(3)),
                  //       ),
                  //       onFieldSubmitted: (value) {
                  //         if (barcodeController.text.isNotEmpty &&
                  //             // lotnumController.text.isNotEmpty &&
                  //             _selectedUom!='')
                  //           myFocusNodeQty.requestFocus();
                  //         btnSaveEnabled=false;
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //   child: Text("Expiry Date",
                  //       style: TextStyle(
                  //           fontSize: 20,
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold)),
                  //          ),
                  // SizedBox(height: 3.0),
                  // Row(
                  //   children: [
                  //       Container(
                  //         padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                  //         width: MediaQuery.of(context).size.width / 1.8,
                  //         child: ElevatedButton(
                  //           style: ElevatedButton.styleFrom(
                  //             fixedSize: Size(20, 50),
                  //             backgroundColor: Colors.blue,
                  //           ),
                  //           onPressed: () => _selectDate(context),
                  //           child: Text(
                  //             selectedDate != null
                  //                 ? "${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                  //                 : "Select Date", // Show "Select Date" if no date is selected
                  //             style: TextStyle(fontSize: 25, color: Colors.white),
                  //           ),
                  //         ),
                  //       ),
                  // Spacer(),
                  // MaterialButton(
                  //     onPressed: () {
                  //       customLogicalModal(
                  //         context,
                  //         Text(
                  //             "Are you sure you want to clear the date?"),
                  //             () =>
                  //             Navigator.pop(context),
                  //             () async {
                  //           Navigator.pop(context);
                  //           selectedDate = resetSelectedDate(selectedDate);
                  //         },
                  //       );
                  //     },
                  //     child: Row(
                  //       children: [
                  //         Icon(CupertinoIcons.delete_left,
                  //             color: Colors.red),
                  //         Text(" Clear Expiry Date",
                  //             style: TextStyle(
                  //                 color: Colors.red, fontSize: 18)),
                  //       ],
                  //     )
                  //   ),
                  //  ]
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Quantity",
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),

                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, bottom: 10.0),
                    child: Container(
                      width: BodySize.wdth / 3,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        autofocus: true,
                        focusNode: myFocusNodeQty,
                        style: TextStyle(fontSize: 20),
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.all(8.0), //here your padding
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        onFieldSubmitted: (value) {
                          lotnoController.clear();
                          // batnoController.clear();
                          qtyController.clear();
                          btnSaveEnabled=false;
                        },
                        onChanged: (value) {
                          if(value.isEmpty){
                            btnSaveEnabled = false;
                            setModalState(() {});
                          }
                          if(value.characters.first=='0' || validCharacters.hasMatch(value)==false){
                            qtyController.clear();
                            btnSaveEnabled = false;
                            setModalState(() {});
                          }
                          if (barcodeController.text.isNotEmpty && descController.text.isNotEmpty &&
                              qtyController.text.isNotEmpty && _selectedUom!='') {
                            btnSaveEnabled = true;
                            setModalState(() {});
                          } else {
                            btnSaveEnabled = false;
                            setModalState(() {});
                          }
                        },
                      ),
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
                          var dtls = "[LOGIN][Audit scan ID to save item.";
                          GlobalVariables.isAuditLogged = false;
                          if(qtyController.text.isEmpty){
                            instantMsgModal(
                                context,
                                Icon(
                                  CupertinoIcons.exclamationmark_circle,
                                  color: Colors.red,
                                  size: 40,
                                ),
                                Text("ERROR! Please input quantity!"));
                          }else{
                            await scanAuditModal(context, db, dtls);
                          }
                          if (GlobalVariables.isAuditLogged == true) {
                            // if(barcodeController.text.length<=6){
                            //   //save item code
                            // }
                            // if(barcodeController.text.length>6){
                            //   //save barcode
                            //   save();
                            //   setModalState(() {});
                            // }
                            DateFormat dateFormat1 = DateFormat("yyyy-MM-dd hh:mm:ss aaa");
                            String dt = dateFormat1.format(DateTime.now());
                            _itemNotFound.barcode = barcodeController.text.trim();
                            _itemNotFound.inputted_desc = descController.text.trim();
                            _itemNotFound.itemcode='00000';
                            _itemNotFound.uom = _selectedUom.trim();
                            // _itemNotFound.lotno = lotnoController.text.isNotEmpty
                            //     ? lotnoController.text.trim().toUpperCase()
                            //     : null;
                            // _itemNotFound.batno = batnoController.text.trim();
                            // _itemNotFound.expiry = selectedDate != null
                            //     ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                            //     : null;
                            _itemNotFound.qty = qtyController.text.trim();
                            _itemNotFound.location = GlobalVariables.currentLocationID;
                            _itemNotFound.exported = 'false';
                            _itemNotFound.dateTimeCreated = dt;
                            //ADDED ATTRIBUTES TO NOT FOUND TABLE
                            _itemNotFound.businessUnit=GlobalVariables.currentBusinessUnit;
                            _itemNotFound.department=GlobalVariables.currentDepartment;
                            _itemNotFound.section=GlobalVariables.currentSection;
                            _itemNotFound.empno=GlobalVariables.logEmpNo;
                            _itemNotFound.rack_desc=GlobalVariables.currentRackDesc;
                            _itemNotFound.description='barcode';
                            await db.insertItemNotFound(_itemNotFound);
                            myFocusNodeBarcode.requestFocus();
                            descController.clear();
                            barcodeController.clear();
                            lotnoController.clear();
                            // batnoController.clear();
                            selectedDate = resetSelectedDate(selectedDate);
                            qtyController.clear();
                            btnSaveEnabled = false;
                            setModalState(() {});
                            var rs = await db.selectItemNotFoundWhere(
                                GlobalVariables.currentLocationID);
                            print(rs);
                            Fluttertoast.showToast(msg: 'Barcode added to not found items.',
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.black54,
                                textColor: Colors.white,
                                fontSize: 16.0);
                            Navigator.of(context).pop();
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
