import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/itemCountModel.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/globalVariables.dart';

class ViewItemScannedListScreen extends StatefulWidget {
  const ViewItemScannedListScreen({Key? key}) : super(key: key);

  @override
  _ViewItemScannedListScreenState createState() =>
      _ViewItemScannedListScreenState();
}

class _ViewItemScannedListScreenState extends State<ViewItemScannedListScreen> {
  late SqfliteDBHelper _sqfliteDBHelper;
  Logs _log = Logs();
  List<ItemCount> _items = [];
  List _notSynced = [];
  List _synced = [];

  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("hh:mm:ss aaa");

  bool _loading = true;

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});

    _refreshItemList();

    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          // title: Text(
          //   "List of Scanned Item [ Total: ${_items.length} ] [ Synced: ${_synced.length} ] [ Not Synced: ${_notSynced.length} ]",
          //   maxLines: 2,
          //   style: TextStyle(color: Colors.blue),
          // ),
          title: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: "List of Scanned Item: ",
                    style: TextStyle(
                        color: Colors.blue,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: "[ Total: ${_items.length} ] ",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: "[ Synced: ${_synced.length} ] ",
                    style: TextStyle(
                        color: Colors.green,
                        fontSize: 19,
                        fontWeight: FontWeight.bold)),
                TextSpan(
                    text: "[ Not Synced: ${_notSynced.length} ] ",
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 19,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
          titleSpacing: 0.0,
          elevation: 0.0,
          leading: IconButton(
            icon: Icon(Icons.close, color: Colors.red),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Column(
          children: [
            _loading
                ? loading()
                : _items.length > 0
                    ? Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: _items.length,
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
                                      GlobalVariables.countType != 'ANNUAL' &&
                                              GlobalVariables.enableExpiry ==
                                                  true
                                          ? RichText(
                                              text: TextSpan(
                                                children: [
                                                  TextSpan(
                                                      text:
                                                          "Datetime Scanned: ",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.blue,
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  TextSpan(
                                                      text:
                                                          "${_items[index].dateTimeCreated!}",
                                                      style: TextStyle(
                                                          fontSize: 15,
                                                          color: Colors.black))
                                                ],
                                              ),
                                            )
                                          : SizedBox(),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: "Datetime Saved: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    "${_items[index].dateTimeSaved!}",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black))
                                          ],
                                        ),
                                      ),
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _items[index].description!,
                                              style: TextStyle(fontSize: 25),
                                              // maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                                text: "Barcode: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    "${_items[index].barcode!}",
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
                                                text: "Itemcode: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    "${_items[index].itemcode!}",
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
                                                text: "${_items[index].uom!}",
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
                                                text: "Expiry Date: ",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    "${DateFormat('MMMM dd, yyyy').format(DateTime.parse(_items[index].expiry!))}",
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
                                                text: "${_items[index].qty!}",
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
                                            _items[index].exported == 'EXPORTED'
                                                ? CupertinoIcons
                                                    .checkmark_alt_circle_fill
                                                : CupertinoIcons
                                                    .info_circle_fill,
                                            color: _items[index].exported ==
                                                    'EXPORTED'
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                          Text(
                                              _items[index].exported ==
                                                      'EXPORTED'
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

  _refreshItemList() async {
    List<ItemCount> x = await _sqfliteDBHelper.fetchItemCountWhere(
        "empno = '${GlobalVariables.logEmpNo}' AND business_unit = '${GlobalVariables.currentBusinessUnit}' AND department = '${GlobalVariables.currentDepartment}' AND section  = '${GlobalVariables.currentSection}' AND rack_desc  = '${GlobalVariables.currentRackDesc}' AND location_id = '${GlobalVariables.currentLocationID}' AND exported != 'EXPORTED'");
    _items = x;
    _notSynced = [];
    _synced = [];
    _notSynced = _items.where((element) => element.exported == '').toList();
    _synced =
        _items.where((element) => element.exported == 'EXPORTED').toList();
    _loading = false;
    if (mounted) setState(() {});
  }

  delete(int id, int index) async {
    await _sqfliteDBHelper.deleteItemCountWhere(id);
    _refreshItemList();

    //logs
    _log.date = dateFormat.format(DateTime.now());
    _log.time = timeFormat.format(DateTime.now());
    _log.device =
        "${GlobalVariables.deviceInfo}(${GlobalVariables.readdeviceInfo})";
    _log.user = "USER";
    _log.empid = GlobalVariables.logEmpNo;
    _log.details =
        "[DELETE][Delete item (barcode: ${_items[index].barcode} description: ${_items[index].description})]";
    await _sqfliteDBHelper.insertLog(_log);
  }
}
