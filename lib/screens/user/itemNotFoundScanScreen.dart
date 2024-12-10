import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemNotFoundModel.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/customLogicalModal.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:physicalcountv2/widget/saveNotFoundItemModal.dart';
import 'package:physicalcountv2/widget/scanAuditModal.dart';
import 'package:physicalcountv2/widget/updateNotFoundItemModal.dart';

import '../../widget/saveNotFoundBarcode.dart';

class ItemNotFoundScanScreen extends StatefulWidget {
  const ItemNotFoundScanScreen({Key? key}) : super(key: key);

  @override
  _ItemNotFoundScanScreenState createState() => _ItemNotFoundScanScreenState();
}

class _ItemNotFoundScanScreenState extends State<ItemNotFoundScanScreen> {
  late SqfliteDBHelper _sqfliteDBHelper;
  final _textController = TextEditingController();
  List units = [];
  List notSyncNFItems =[];
  List _notSyncNF = [];
  List nfItemSearched=[];
  List<ItemNotFound> itemNotFound = [];
  Logs _log = Logs();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm:ss aaa");
  bool _loading = true;
  bool _listStat = false;
  bool ableEditDelete = false;
  String formatDate(String? dateStr) {
    if (dateStr == null) {
      return "null";
    }

    try {
      final parsedDate = DateTime.parse(dateStr);
      return DateFormat('yyyy-MM-dd').format(parsedDate);
    } catch (e) {
      // Handle the parsing error, e.g., log it or return a default value.
      return "null";
    }
  }


  @override
  void initState() {
    ableEditDelete = GlobalVariables.ableEditDelete;
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});
    getUnits();
    super.initState();
  }

  Future _onSearch(value) async{
    _listStat = true;
    List nfItemSearched = await _sqfliteDBHelper.searchNfItems(value.toString().trim());
    notSyncNFItems = nfItemSearched;
    print('NOT FOUND: ${notSyncNFItems.length} ');
    print("VALUE : $value");
    if(notSyncNFItems.isEmpty){
      showDialog(context: context, builder: (BuildContext context){
        return CupertinoAlertDialog(
          title: new Text("Item not found!"),
          actions: <Widget>[
            new TextButton(
              child: new Text("Close"),
              onPressed: (){
                _refreshItemList();
                Navigator.of(context).pop();
              },
            )
          ],
        );
      }
      );
    }else{
      setState((){
        _notSyncNF = nfItemSearched;
      });
    }
  }


  void sortItemsByDateTimeSavedDesc() {
    itemNotFound.sort((a, b) => b.dateTimeCreated!.compareTo(a.dateTimeCreated!));
  }


  @override
  Widget build(BuildContext context) {

    if (itemNotFound.isNotEmpty) {
      sortItemsByDateTimeSavedDesc();
    }

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          leading: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () => Navigator.of(context).pop()),
          title: Row(
            children: [
              Flexible(
                child: Material(
                  type: MaterialType.transparency,
                  child: Text(
                    "List of not found item on this location",
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
              icon: Icon(CupertinoIcons.search),
              color: Colors.red,
              onPressed: () async {
                _refreshItemList();
                showDialog(
                  context: context, builder: (BuildContext context){
                  return CupertinoAlertDialog( title: new Text("Search Item"),
                    content: new CupertinoTextField(
                      onSubmitted: (value){
                        _onSearch(value);
                        Navigator.of(context).pop();
                        _textController.clear();
                      },
                      keyboardType: TextInputType.number,
                      controller: _textController,
                      autofocus: true,
                    ),
                    actions:<Widget> [new TextButton(
                        child: new Text("Search"),
                        onPressed: (){
                          _onSearch(_textController.text);
                          Navigator.of(context).pop();
                          _textController.clear();
                        }
                    ),
                      new TextButton(onPressed: (){
                        Navigator.of(context).pop();
                      }, child: new Text("Close"))
                    ],
                  );
                },
                );
              },
            ),
          ],

        ),
        body: Column(
          children: [
            _loading
                ? loading()
                : itemNotFound.length > 0
                ? Expanded(
                   child: Scrollbar(
//=========================================S E A R C H  N O T  F O U N D  I T E M S================================================//
                child: _listStat == true
                    ? ListView.builder(
                  itemCount: _notSyncNF.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Datetime Scanned: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text: "${_notSyncNF[index]['datetimecreated']}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "${_notSyncNF[index]['description']}: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text: "${_notSyncNF[index]['barcode']}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Inputted Description: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text: "${_notSyncNF[index]['inputted_description']}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Unit of Measure: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text:
                                      "${_notSyncNF[index]['uom']}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            // RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //           text: "Lot/Batch Number: ",
                            //           style: TextStyle(
                            //               fontSize: 15,
                            //               color: Colors.blue,
                            //               fontWeight:
                            //               FontWeight.bold)),
                            //       TextSpan(
                            //           text: "${_notSyncNF[index]['lot_number']}",
                            //           style: TextStyle(
                            //               fontSize: 15,
                            //               color: Colors.black))
                            //     ],
                            //   ),
                            // ),
                            // RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //           text: "Batch Number: ",
                            //           style: TextStyle(
                            //               fontSize: 15,
                            //               color: Colors.blue,
                            //               fontWeight:
                            //               FontWeight.bold)),
                            //       TextSpan(
                            //           text: "${_notSyncNF[index]['batch_number']}",
                            //           style: TextStyle(
                            //               fontSize: 15,
                            //               color: Colors.black))
                            //     ],
                            //   ),
                            // ),
                            // GlobalVariables.countType == 'ANNUAL'
                            //     ? RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //           text: "Expiry Date: ",
                            //           style: TextStyle(fontSize: 15,
                            //               color: Colors.blue,
                            //               fontWeight: FontWeight.bold)
                            //       ),
                            //       TextSpan(
                            //         text: _notSyncNF[index]['expiry']!= null
                            //             ? _notSyncNF[index]['expiry']! // Assuming _items[index].expiry is a String
                            //             : "null",
                            //         style: TextStyle(
                            //           fontSize: 15,
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // )
                            //     : SizedBox(),
                            RichText( text: TextSpan(
                              children: [
                                TextSpan(
                                    text: "Quantity: ",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.blue,
                                        fontWeight:
                                        FontWeight.bold)),
                                TextSpan(
                                    text: "${_notSyncNF[index]['qty']}",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black))
                              ],
                            ),
                            ),
                            ableEditDelete ?
                            Row(
                              children: [
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.yellow[700]),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.pencil),
                                        Text("Edit"),
                                      ],
                                    ),
                                    onPressed: () async {
                                      if (_notSyncNF[index]['exported']==
                                          'false') {
                                        customLogicalModal(
                                          context,
                                          Text("Are you sure you want to edit this item?"),
                                              () => Navigator.pop(context),
                                              () async {
                                            Navigator.pop(context);
                                            await updateNotFoundItemModal(
                                              context,
                                              _sqfliteDBHelper,
                                              "[Update][Audit scan ID to update scanned item quantity.]",
                                              _notSyncNF[index]['id'].toString(),
                                              _notSyncNF[index]['barcode'].toString(),
                                              _notSyncNF[index]['inputted_description'].toString(),
                                              _notSyncNF[index]['uom'].toString(),
                                              // _notSyncNF[index]['lot_number'].toString(),
                                              // _notSyncNF[index]['batch_number'].toString(),
                                              // _notSyncNF[index]['expiry'].toString(),
                                              _notSyncNF[index]['qty'].toString(),
                                              units,
                                            );
                                            _refreshItemList();
                                          },
                                        );
                                      } else {
                                        instantMsgModal(
                                            context,
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            Text(
                                                "This item is already synced, you cannot edit synced item."));
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.trash),
                                        Text("Delete"),
                                      ],
                                    ),
                                    onPressed: () async {
                                      if (_notSyncNF[index]['exported']==
                                          'false') {
                                        customLogicalModal(
                                          context,
                                          Text(
                                              "Are you sure you want to delete this item?"), () => Navigator.pop(context),
                                              () async {
                                            Navigator.pop(context);
                                            var dtls = "[LOGIN][Audit scan ID to delete not found item.]";
                                            GlobalVariables.isAuditLogged = false;
                                            await scanAuditModal(context, _sqfliteDBHelper, dtls);
                                            if (GlobalVariables.isAuditLogged == true) {
                                              //delte code here
                                              delete(_notSyncNF[index]['id'], index);
                                            }
                                          },
                                        );
                                      } else {
                                        instantMsgModal(
                                            context,
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            Text("This item is already synced, you cannot remove synced item."));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                                : SizedBox(),
                            Row(
                              children: [
                                Spacer(),
                                Icon(
                                  _notSyncNF[index]['exported'] == 'true' ? CupertinoIcons.checkmark_alt_circle_fill
                                      : CupertinoIcons.info_circle_fill,
                                  color:
                                  _notSyncNF[index]['exported'] == 'true'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                Text(
                                    _notSyncNF[index]['exported'] == 'true'
                                        ? "Synced to Server Database"
                                        : "Not synced to Server Database",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black))
                              ],
                            ),
                            SizedBox(height: 5),
                            Divider(),
                          ],
                        ),
                      ),
                    );
                  },
                )
                //=============================================E N D =========================================================================================//

                    : ListView.builder(
                  itemCount: itemNotFound.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(
                          left: 20.0, right: 20.0),
                      child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Datetime Scanned: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text: "${itemNotFound[index].dateTimeCreated!}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "${itemNotFound[index].description}: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text: itemNotFound[index].description == 'barcode' ?
                                      "${itemNotFound[index].barcode}" : "${itemNotFound[index].itemcode} ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Inputted Description: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text: "${itemNotFound[index].inputted_desc}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Unit of Measure: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text:
                                      "${itemNotFound[index].uom}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            // RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //           text: "Lot/Batch Number: ",
                            //           style: TextStyle(
                            //               fontSize: 15,
                            //               color: Colors.blue,
                            //               fontWeight:
                            //               FontWeight.bold)),
                            //       TextSpan(
                            //           text: itemNotFound[index].lotno != null
                            //               ? itemNotFound[index].lotno
                            //               : "null",
                            //           style: TextStyle(
                            //               fontSize: 15,
                            //               color: Colors.black))
                            //     ],
                            //   ),
                            // ),
                            // RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //           text: "Batch Number: ",
                            //           style: TextStyle(
                            //               fontSize: 14,
                            //               color: Colors.blue,
                            //               fontWeight:
                            //               FontWeight.bold)),
                            //       TextSpan(
                            //           text: "${itemNotFound[index].batno!}",
                            //           style: TextStyle(
                            //               fontSize: 14,
                            //               color: Colors.black))
                            //     ],
                            //   ),
                            // ),
                            // GlobalVariables.countType == 'ANNUAL'
                            //     ? RichText(
                            //   text: TextSpan(
                            //     children: [
                            //       TextSpan(
                            //         text: "Expiry Date: ",
                            //         style: TextStyle(
                            //           fontSize: 15,
                            //           color: Colors.blue,
                            //           fontWeight: FontWeight.bold,
                            //         ),
                            //       ),
                            //       TextSpan(
                            //         text: itemNotFound[index].expiry != null
                            //             ? formatDate(itemNotFound[index].expiry)
                            //             : "null",
                            //         style: TextStyle(
                            //           fontSize: 15,
                            //           color: Colors.black,
                            //         ),
                            //       ),
                            //
                            //     ],
                            //   ),
                            // )
                            //     : SizedBox(),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: "Quantity: ",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.blue,
                                          fontWeight:
                                          FontWeight.bold)),
                                  TextSpan(
                                      text:
                                      "${itemNotFound[index].qty}",
                                      style: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black))
                                ],
                              ),
                            ),
                            ableEditDelete ?
                            Row(
                              children: [
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.yellow[700]),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.pencil),
                                        Text("Edit"),
                                      ],
                                    ),
                                    onPressed: () async {
                                      if (itemNotFound[index]
                                          .exported !=
                                          'EXPORTED') {
                                        customLogicalModal(
                                          context,
                                          Text("Are you sure you want to edit this item?"),
                                              () => Navigator.pop(context),
                                              () async {
                                            Navigator.pop(context);
                                            await updateNotFoundItemModal(
                                              context,
                                              _sqfliteDBHelper,
                                              "[Update][Audit scan ID to update scanned item quantity.]",
                                              itemNotFound[index].id!.toString(),
                                              itemNotFound[index].barcode!,
                                              itemNotFound[index].inputted_desc ?? '',
                                              itemNotFound[index].uom!,
                                              // itemNotFound[index].lotno ?? '',
                                              // itemNotFound[index].batno!,
                                              // itemNotFound[index].expiry ?? '',
                                              itemNotFound[index].qty!,
                                              units,
                                            );
                                            _refreshItemList();
                                          },
                                        );
                                      } else {
                                        instantMsgModal(
                                            context,
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            Text(
                                                "This item is already synced, you cannot edit synced item."));
                                      }
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      right: 8.0),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        primary: Colors.red),
                                    child: Row(
                                      children: [
                                        Icon(CupertinoIcons.trash),
                                        Text("Delete"),
                                      ],
                                    ),
                                    onPressed: () async {
                                      if (itemNotFound[index]
                                          .exported !=
                                          'EXPORTED') {
                                        customLogicalModal(
                                          context,
                                          Text(
                                              "Are you sure you want to delete this item?"), () => Navigator.pop(context),
                                              () async {
                                            Navigator.pop(context);
                                            var dtls = "[LOGIN][Audit scan ID to delete not found item.]";
                                            GlobalVariables.isAuditLogged = false;
                                            await scanAuditModal(context, _sqfliteDBHelper, dtls);
                                            if (GlobalVariables.isAuditLogged == true) {
                                              //delte code here
                                              delete(itemNotFound[index].id!, index);
                                            }
                                          },
                                        );
                                      } else {
                                        instantMsgModal(
                                            context,
                                            Icon(
                                              CupertinoIcons
                                                  .exclamationmark_circle,
                                              color: Colors.red,
                                              size: 40,
                                            ),
                                            Text("This item is already synced, you cannot remove synced item."));
                                      }
                                    },
                                  ),
                                ),
                              ],
                            )
                                : SizedBox(),
                            Row(
                              children: [
                                Spacer(),
                                Icon(
                                  itemNotFound[index].exported == 'EXPORTED' ? CupertinoIcons.checkmark_alt_circle_fill
                                      : CupertinoIcons.info_circle_fill,
                                  color:
                                  itemNotFound[index].exported == 'EXPORTED'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                Text(
                                    itemNotFound[index].exported == 'EXPORTED'
                                        ? "Synced to Server Database"
                                        : "Not synced to Server Database",
                                    style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black))
                              ],
                            ),
                            SizedBox(height: 5),
                            Divider(),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            )
                : Center(
              child: Column(
                children: [
                  Icon(
                    CupertinoIcons.doc,
                    size: 100,
                    color: Colors.grey,
                  ),
                  Text(
                    "Oops...It's empty in here!",
                    style:
                    TextStyle(fontSize: 25, color: Colors.grey),
                  )
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: () async {
            await saveNotFoundBarcode(context, _sqfliteDBHelper, units);
            _refreshItemList();
          },
          child: Icon(CupertinoIcons.plus),
          foregroundColor: Colors.red,
        ),
      ),
    );
  }
  Widget loading() {
    return Expanded(
      child: Column(
        children: [
          Spacer(),
          Center(child: CircularProgressIndicator()),
          Spacer(),
        ],
      ),
    );
  }

  getUnits() async {
    units = await _sqfliteDBHelper.selectUnitsAll();
    List<ItemNotFound> x = await _sqfliteDBHelper.fetchItemNotFoundWhere(
        "location = '${GlobalVariables.currentLocationID}' AND exported != 'EXPORTED' ");
    itemNotFound = x;
    _loading = false;
    if (mounted) setState(() {});
  }

  _refreshItemList() async {
    List<ItemNotFound> x = await _sqfliteDBHelper.fetchItemNotFoundWhere(
        "empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}' AND location = '${GlobalVariables.currentLocationID}' AND exported != 'EXPORTED'");
    // itemNotFound = x;
    if (mounted) setState(() { itemNotFound = x;});
  }

  delete(int id, int index) async {
    await _sqfliteDBHelper.deleteItemNotFound(id);
    _refreshItemList();
    //logs
    _log.date = dateFormat.format(DateTime.now());
    _log.time = timeFormat.format(DateTime.now());
    _log.device =
    "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
    _log.user = "USER";
    _log.empid = GlobalVariables.logEmpNo;
    _log.details =
    "[DELETE][Delete item (barcode: ${itemNotFound[index].barcode} unit: ${itemNotFound[index].uom} qty: ${itemNotFound[index].qty})]";
    await _sqfliteDBHelper.insertLog(_log);
  }
}
