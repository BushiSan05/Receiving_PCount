import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemNotFoundModel.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/globalVariables.dart';

class ViewItemNotFoundScanScreen extends StatefulWidget {
  const ViewItemNotFoundScanScreen({Key? key}) : super(key: key);

  @override
  _ViewItemNotFoundScanScreenState createState() =>
      _ViewItemNotFoundScanScreenState();
}

class _ViewItemNotFoundScanScreenState
    extends State<ViewItemNotFoundScanScreen> {
  late SqfliteDBHelper _sqfliteDBHelper;
  List units = [];
  List<ItemNotFound> itemNotFound = [];
  Logs _log = Logs();
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm:ss aaa");
  bool _loading = true;
  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});
    getUnits();
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
        ),
        body: Column(
          children: [
            _loading
                ? loading()
                : itemNotFound.length > 0
                    ? Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
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
                                                text:
                                                    "${itemNotFound[index].dateTimeCreated!}",
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
                                                text:
                                                    "${itemNotFound[index].barcode}",
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
                                      Row(
                                        children: [
                                          Spacer(),
                                          Icon(
                                             itemNotFound[index].exported == 'EXPORTED' ? CupertinoIcons.checkmark_alt_circle_fill : CupertinoIcons.info_circle_fill,
                                            color: itemNotFound[index].exported == 'EXPORTED'
                                                    ? Colors.green
                                                    : Colors.red,
                                          ),
                                          Text(itemNotFound[index].exported == 'EXPORTED' ? "Synced to Server Database" : "Not synced to Server Database",
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
        "location = '${GlobalVariables.currentLocationID}'  AND exported = 'false' ");
    itemNotFound = x;
    _loading = false;
    if (mounted) setState(() {});
  }

  _refreshItemList() async {
    List<ItemNotFound> x = await _sqfliteDBHelper.fetchItemNotFoundWhere(
        "location = '${GlobalVariables.currentLocationID}' AND exported = 'false' ");
    itemNotFound = x;
    if (mounted) setState(() {});
  }

  delete(int id, int index) async {
    await _sqfliteDBHelper.deleteItemNotFound(id);
    _refreshItemList();

    //logs
    _log.date     = dateFormat.format(DateTime.now());
    _log.time     = timeFormat.format(DateTime.now());
    _log.device   = "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
    _log.user     = "${GlobalVariables.logFullName}Inventory Clerk[]";
    _log.empid    = GlobalVariables.logEmpNo;
    _log.details  =  "[DELETE][Delete item (barcode: ${itemNotFound[index].barcode} unit: ${itemNotFound[index].uom} qty: ${itemNotFound[index].qty})]";
    await _sqfliteDBHelper.insertLog(_log);
  }
}
