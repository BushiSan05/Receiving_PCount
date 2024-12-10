import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/bodySize.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:physicalcountv2/widget/scanAuditModal.dart';

import 'customLogicalModal.dart';

updateNotFoundItemModal(
    BuildContext context,
    SqfliteDBHelper db,
    String details,
    String id,
    String barcode,
    String inputted_desc,
    String uom,
    // String lotno,
    // String batno,
    // String expiry,
    String qty,
    List units) {
  late FocusNode myFocusNodeDesc;
  late FocusNode myFocusNodeLotno;
  // late FocusNode myFocusNodeBatno;
  late FocusNode myFocusNodeQty;
  myFocusNodeLotno = FocusNode();
  myFocusNodeDesc = FocusNode();
  // myFocusNodeBatno = FocusNode();
  myFocusNodeQty = FocusNode();

  final lotnoController = TextEditingController();
  final descController = TextEditingController();
  // final batnoController = TextEditingController();
  final qtyController = TextEditingController();
  DateTime? selectedDate;

  myFocusNodeDesc.requestFocus();
  // ItemNotFound _itemNotFound = ItemNotFound();

  var _uom = units;
  String _selectedUom = uom;
  descController.text = inputted_desc;
  // lotnoController.text = lotno;
  qtyController.text = qty;
  final validCharacters = RegExp(r'^[0-9]+$');
  var _uomm = [];
  units.forEach((element) {
    _uomm.add(element['uom']);
  });

  DateTime? resetSelectedDate(DateTime? currentSelectedDate) {
    return null; // Resetting the date to null
  }

  // try {
  //   if (expiry != null) {
  //     selectedDate = DateTime.parse(expiry);
  //   }
  // } catch (e) {
  //   print('error 1');
  // }
  if (selectedDate != null) {
  } else {
  }


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      selectedDate = picked;
    }
  }



  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setModalState) {
          return Container(
            height: BodySize.hghth / 1.1,
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
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: "Barcode: ",
                              style: TextStyle(
                                  fontSize: 23,
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: "$barcode",
                              style:
                                  TextStyle(fontSize: 23, color: Colors.black))
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: Text("Inputted Description",
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Container(
                      child: TextFormField(
                        focusNode: myFocusNodeDesc,
                        controller: descController,
                        style: TextStyle(fontSize: 25),
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.all(8.0), //here your padding
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        onFieldSubmitted: (value) {
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
                    child: DropdownSearch<dynamic>(
                      items: _uomm,
                      showSearchBox: true,
                      selectedItem: _selectedUom,
                      onChanged: (val) {
                        _selectedUom = val.toString();
                        setModalState(() {});
                      },
                    ),
                  ),
                  SizedBox(height: 10.0),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //   child: Text("Lot/Batch Number",
                  //       style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold)),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 20.0, right: 20.0, bottom: 10.0),
                  //   child: Container(
                  //     width: BodySize.wdth / 3,
                  //     child: TextFormField(
                  //       textAlign: TextAlign.center,
                  //       focusNode: myFocusNodeLotno,
                  //       controller: lotnoController,
                  //       style: TextStyle(fontSize: 25),
                  //       decoration: InputDecoration(
                  //         contentPadding:
                  //         EdgeInsets.all(8.0), //here your padding
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(3)),
                  //       ),
                  //       onFieldSubmitted: (value) {
                  //         myFocusNodeQty.requestFocus();
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //   child: Text("Batch Number",
                  //       style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold)),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //       left: 20.0, right: 20.0, bottom: 10.0),
                  //   child: Container(
                  //     width: BodySize.wdth / 2,
                  //     child: TextFormField(
                  //       // autofocus: true,
                  //       focusNode: myFocusNodeBatno,
                  //       controller: batnoController,
                  //       style: TextStyle(fontSize: 25),
                  //       // keyboardType: TextInputType.number,
                  //       decoration: InputDecoration(
                  //         contentPadding:
                  //         EdgeInsets.all(8.0), //here your padding
                  //         border: OutlineInputBorder(
                  //             borderRadius: BorderRadius.circular(3)),
                  //       ),
                  //       onFieldSubmitted: (value) {
                  //         myFocusNodeQty.requestFocus();
                  //       },
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //   child: Text("Expiry Date",
                  //       style: TextStyle(
                  //           fontSize: 18,
                  //           color: Colors.blue,
                  //           fontWeight: FontWeight.bold)),
                  // ),
                  // Row(
                  // children: [
                  //  Padding(
                  //   padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                  //    child: Container(
                  //       width: MediaQuery.of(context).size.width / 3,
                  //       child: ElevatedButton(
                  //         style: ElevatedButton.styleFrom(
                  //             backgroundColor: Colors.blue),
                  //         onPressed: () async {
                  //           _selectDate(context);
                  //           setModalState(() {});
                  //         },
                  //         child: Text(
                  //           selectedDate != null
                  //               ? "${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                  //               : "Select Date", // Show "Select Date" if no date is selected
                  //           style: TextStyle(fontSize: 20, color: Colors.white),
                  //         ),
                  //       ),
                  //     ),
                  // ),
                  // Spacer(),
                  // MaterialButton(
                  //         onPressed: () {
                  //           customLogicalModal(
                  //             context,
                  //             Text(
                  //                 "Are you sure you want to clear the date?"),
                  //                 () =>
                  //                 Navigator.pop(context),
                  //                 () async {
                  //               Navigator.pop(context);
                  //               selectedDate = resetSelectedDate(selectedDate);
                  //             },
                  //           );
                  //         },
                  //         child: Row(
                  //           children: [
                  //             Icon(CupertinoIcons.delete_left,
                  //                 color: Colors.red),
                  //             Text(" Clear Expiry Date",
                  //                 style: TextStyle(
                  //                     color: Colors.red, fontSize: 18)),
                  //           ],
                  //         )
                  //     ),
                  //   ]
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
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0, bottom: 10.0),
                    child: Container(
                      width: BodySize.wdth / 4,
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        autofocus: true,
                        focusNode: myFocusNodeQty,
                        style: TextStyle(fontSize: 18),
                        controller: qtyController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          contentPadding:
                              EdgeInsets.all(8.0), //here your padding
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(3)),
                        ),
                        onFieldSubmitted: (value) {
                          qtyController.clear();
                        },
                        // onChanged: (value) {
                        //   if(value.characters.first =='0' || validCharacters.hasMatch(value)==false){
                        //     qtyController.clear();
                        //   }
                        //   if (qtyController.text.isNotEmpty) {
                        //     setModalState(() {});
                        //   } else {
                        //     setModalState(() {});
                        //   }
                        // },
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        left: 20.0, right: 20.0),
                    child: MaterialButton(
                      height: MediaQuery.of(context).size.height / 15,
                      minWidth: MediaQuery.of(context).size.width,
                      color: Colors.green,
                      child: Text("UPDATE",
                          style: TextStyle(color: Colors.white, fontSize: 20)),
                      onPressed: () async {
                        GlobalVariables.isAuditLogged = false;
                        if (GlobalVariables.isAuditLogged == false && qtyController.text.isEmpty) {
                          instantMsgModal(
                              context,
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                              Text("ERROR! Please input quantity!"));
                        }else{
                          await scanAuditModal(context, db, details);
                        }
                        if (GlobalVariables.isAuditLogged == true && qtyController.text.isNotEmpty){

                          // String? formattedExpiryDate = selectedDate != null
                          //     ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                          //     : null;
                          print("mao ni edited desc ${descController.text.trim()}");

                          await db.updateItemNotFoundWhere(int.parse(id),
                              'uom = "${_selectedUom.trim()}", ' +
                              'inputted_description = "${descController.text.trim()}", ' +
                                  // (lotnoController.text.trim().isNotEmpty
                                  //     ? "lot_number = '${lotnoController.text.trim().toUpperCase()}',"
                                  //     : "lot_number = NULL,") +
                              // 'batch_number = "${batnoController.text.trim()}", '
                              // "expiry = ${formattedExpiryDate != null
                              //         ? "'$formattedExpiryDate'"
                              //         : 'NULL'},"
                              'qty = "${qtyController.text.trim()}"');
                          Navigator.pop(context);
                          Fluttertoast.showToast(msg: 'Successfully Edited!',
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black54,
                              textColor: Colors.white,
                              fontSize: 16.0);
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
