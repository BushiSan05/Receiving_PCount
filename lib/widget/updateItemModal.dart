import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/bodySize.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/scanAuditModal.dart';
import 'customLogicalModal.dart';
import 'instantMsgModal.dart';

updateItemModal(
    BuildContext context,
    SqfliteDBHelper db,
    String details,
    String id,
    String desc,
    String desc2,
    String barcode,
    String itemcode,
    String uom,
    String lotno,
    // String batno,
    String expiry,
    String qty,
    String conqty) {
  final lotnoController = TextEditingController();
  // final batnoController = TextEditingController();
  final qtyController = TextEditingController();
  lotnoController.text = lotno;
  // batnoController.text = batno;
  qtyController.text = qty;
  late FocusNode myFocusNodeLotno;
  // late FocusNode myFocusNodeBatno;
  late FocusNode myFocusNodeQty;
  myFocusNodeLotno = FocusNode();
  // myFocusNodeBatno = FocusNode();
  myFocusNodeQty = FocusNode();
  myFocusNodeQty.requestFocus();
  // DateTime selectedDate = DateTime.parse(expiry);
  int int_qty =int.parse(qty);
  DateTime? selectedDate;

  DateTime? resetSelectedDate(DateTime? currentSelectedDate) {
    return null; // Resetting the date to null
  }


  try {
    if (expiry != null) {
      selectedDate = DateTime.parse(expiry);
    }
  } catch (e) {
    print('error 1');
  }
  if (selectedDate != null) {
  } else {
  }


  // Future<void> _selectDate(BuildContext context) async {
  //   final DateTime? picked = await showDatePicker(
  //     context: context,
  //     initialDate: selectedDate,
  //     firstDate: DateTime(2015, 8),
  //     lastDate: DateTime(2101),
  //   );
  //   if (picked != selectedDate) selectedDate = picked!;
  // }

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
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          desc,
                          style: TextStyle(fontSize: 25),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  desc != desc2 && desc2 != ""?
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          desc2,
                          style: TextStyle(fontSize: 23),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ):
                  SizedBox(height: 5.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "Barcode: ",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: "$barcode",
                            style: TextStyle(fontSize: 20, color: Colors.black))
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "Itemcode: ",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: "$itemcode",
                            style: TextStyle(fontSize: 20, color: Colors.black))
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                            text: "Unit of Measure: ",
                            style: TextStyle(
                                fontSize: 20,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold)),
                        TextSpan(
                            text: "$uom",
                            style: TextStyle(fontSize: 20, color: Colors.black))
                      ],
                    ),
                  ),
                  SizedBox(height: 5.0),
                      // Row(
                      // children: [
                      //     RichText(
                      //         text: TextSpan(
                      //          children: [
                      //        TextSpan(
                      //            text: "Lot/Batch Number: ",
                      //            style: TextStyle(
                      //            fontSize: 20,
                      //            color: Colors.blue,
                      //            fontWeight: FontWeight.bold)),
                      //              ],
                      //            ),
                      //         ),
                      //     Container(
                      //       width: BodySize.wdth / 4.5,
                      //       child: TextFormField(
                      //         textAlign: TextAlign.center,
                      //         controller: lotnoController,
                      //         focusNode: myFocusNodeLotno,
                      //         // keyboardType: TextInputType.text,
                      //         style: TextStyle(fontSize: 23),
                      //         decoration: InputDecoration(
                      //           contentPadding:
                      //           EdgeInsets.all(7.0), //here your padding
                      //           border: OutlineInputBorder(
                      //               borderRadius: BorderRadius.circular(3)),
                      //         ),
                      //     ),
                      //   ),
                      //   ],
                      // ),
                  // SizedBox(height: 5.0),
                  // Row(
                  //   children: [
                  //     RichText(
                  //       text: TextSpan(
                  //         children: [
                  //           TextSpan(
                  //               text: "Batch Number: ",
                  //               style: TextStyle(
                  //                   fontSize: 20,
                  //                   color: Colors.blue,
                  //                   fontWeight: FontWeight.bold)),
                  //         ],
                  //       ),
                  //     ),
                  //     Container(
                  //       width: BodySize.wdth / 5.5,
                  //       child: TextFormField(
                  //         controller: batnoController,
                  //         focusNode: myFocusNodeBatno,
                  //         // keyboardType: TextInputType.text,
                  //         style: TextStyle(fontSize: 23),
                  //         decoration: InputDecoration(
                  //           contentPadding:
                  //           EdgeInsets.all(7.0), //here your padding
                  //           border: OutlineInputBorder(
                  //               borderRadius: BorderRadius.circular(3)),
                  //         ),
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  // SizedBox(height: 5.0),
                  // GlobalVariables.countType == 'ANNUAL'
                  //     ? Row(
                  //         children: [
                  //           RichText(
                  //             text: TextSpan(
                  //               children: [
                  //                 TextSpan(
                  //                     text: "Expiry Date: ",
                  //                     style: TextStyle(
                  //                         fontSize: 20,
                  //                         color: Colors.blue,
                  //                         fontWeight: FontWeight.bold)),
                  //               ],
                  //             ),
                  //           ),
                  //           Container(
                  //             width: MediaQuery.of(context).size.width / 3,
                  //             child: ElevatedButton(
                  //               style: ElevatedButton.styleFrom(
                  //                   backgroundColor: Colors.blue),
                  //               onPressed: () async {
                  //                 _selectDate(context);
                  //                 setModalState(() {});
                  //               },
                  //               child: Text(
                  //                 selectedDate != null
                  //                     ? "${DateFormat('yyyy-MM-dd').format(selectedDate!)}"
                  //                     : "Select Date", // Show "Select Date" if no date is selected
                  //                 style: TextStyle(fontSize: 18, color: Colors.white),
                  //               ),
                  //             ),
                  //           ),
                  //           Spacer(),
                  //           MaterialButton(
                  //             onPressed: () {
                  //               customLogicalModal(
                  //                 context,
                  //                 Text(
                  //                     "Are you sure you want to clear the date?"),
                  //                     () =>
                  //                     Navigator.pop(context),
                  //                     () async {
                  //                         Navigator.pop(context);
                  //                         selectedDate = resetSelectedDate(selectedDate);
                  //                         },
                  //                       );
                  //                     },
                  //                child: Row(
                  //                   children: [
                  //                     Icon(CupertinoIcons.delete_left,
                  //                         color: Colors.red),
                  //                     Text(" Clear Expiry Date",
                  //                         style: TextStyle(
                  //                             color: Colors.red, fontSize: 18)),
                  //                   ],
                  //                 )
                  //               )
                  //              ],
                  //             )
                  // : SizedBox(height: 8.0),
                  Row(
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                                text: "Quantity:      ",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      Container(
                        width: BodySize.wdth / 9.0,
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          controller: qtyController,
                          focusNode: myFocusNodeQty,
                          keyboardType: TextInputType.number,
                          style: TextStyle(fontSize: 28),
                          decoration: InputDecoration(
                            contentPadding:
                                EdgeInsets.all(8.0), //here your padding
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(3)),
                          ),
                          onChanged: (value) {
                              try {
                                  int parsedValue = int.parse(value);
                                  if (int_qty < parsedValue) {
                                  instantMsgModal(
                                  context,
                              Icon(
                                    CupertinoIcons.exclamationmark_circle,
                                    color: Colors.red,
                                    size: 40,
                                ),
                          Text("ERROR!")
                                );
                                qtyController.text = qty;
                                }
                          } catch (e) {
                                print(qty);
                            // Handle the case where the input value is not a valid integer
                            // You can show an error message or take other appropriate action here.
                                }
                          },
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: ElevatedButton(
                          style:
                              ElevatedButton.styleFrom(primary: Colors.green),
                          child: Row(
                            children: [
                              Icon(CupertinoIcons.arrow_right_square_fill),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 17.0, bottom: 17.0),
                                child: Text("Update",
                                    style: TextStyle(fontSize: 23)),
                              )
                            ],
                          ),
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
                          if (GlobalVariables.isAuditLogged == true && qtyController.text.isNotEmpty) {
                            int conqtyValue = int.parse(conqty);
                            int qtyValue = int.parse(qty);
                            int cqtyValue = int.parse(qtyController.text.trim());
                            double conqtyUpdate = (conqtyValue / qtyValue) * cqtyValue;
                            int conqtyUpdateAsInt = conqtyUpdate.toInt();

                            String? formattedExpiryDate = selectedDate != null
                                ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                                : null;

                            await db.updateItemCountWhere(int.parse(id),
                                "qty = '${qtyController.text.trim()}'," +
                                (lotnoController.text.trim().isNotEmpty
                                  ? "lot_number = '${lotnoController.text.trim().toUpperCase()}',"
                                  : "lot_number = NULL,") +
                                // "lot_number = '${lotnoController.text.trim()}',"
                                // "batch_number = '${batnoController.text.trim()}',"
                                "expiry = ${formattedExpiryDate != null
                                    ? "'$formattedExpiryDate'"
                                    : 'NULL'},"
                                "conqty = $conqtyUpdateAsInt",
                                );
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
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
