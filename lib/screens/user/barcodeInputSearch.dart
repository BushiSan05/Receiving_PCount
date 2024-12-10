import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';
import 'package:physicalcountv2/values/bodySize.dart';
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:physicalcountv2/widget/itemNofFoundModal.dart';

class BarcodeInputSearchScreen extends StatefulWidget {
  const BarcodeInputSearchScreen({Key? key}) : super(key: key);

  @override
  _BarcodeInputSearchScreenState createState() =>
      _BarcodeInputSearchScreenState();
}

class _BarcodeInputSearchScreenState extends State<BarcodeInputSearchScreen> {
  late FocusNode myFocusNodeBarcode;
  final barcodeController = TextEditingController();
  late SqfliteDBHelper _sqfliteDBHelper;
  List items = [];

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});

    myFocusNodeBarcode = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0.0,
        elevation: 0.0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context, false),
          icon: Icon(Icons.close, color: Colors.red),
        ),
        title: Row(
          children: [
            Flexible(
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "Search Item by Barcode",
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              // height: BodySize.hghth * 0.09,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextFormField(
                  autofocus: true,
                  focusNode: myFocusNodeBarcode,
                  style: TextStyle(fontSize: 50),
                  textAlign: TextAlign.center,
                  controller: barcodeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(8.0), //here your padding
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(3)),
                  ),
                  onFieldSubmitted: (value) {
                    searchItembybarcode(value);
                  },
                ),
              ),
            ),
            Container(
              height: BodySize.hghth * 0.80,
              child: ListView.builder(
                // shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ListTile(
                        tileColor: Colors.lightBlue[50],
                        title: Text(
                          "${items[index]['item_code']}",
                          style: TextStyle(fontSize: 25),
                        ),
                        subtitle: Text(
                          "DESC: ${items[index]['desc']}\nUOM: ${items[index]['uom']}\nVARIANT: ${items[index]['variant_code']}",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                    ),
                    onTap: () {
                      GlobalVariables.searchItemBarcode =
                          items[index]['barcode'];
                      Navigator.pop(context, true);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  searchItembybarcode(String value) async {
    print(value);
    var x = await _sqfliteDBHelper.selectItemWhereItemcode(value);
    if (x.length > 0) {
      items = x;
      print(x);
      if (mounted) setState(() {});
    } else {
      items = [];
      if (mounted) setState(() {});
      itemNotFoundModal(
          context,
          Icon(
            CupertinoIcons.exclamationmark_circle,
            color: Colors.red,
            size: 40,
          ),
          Text(
              "Item not found. Reason(s): 1.) Barcode not registered 2.) Item is not belong to category ${GlobalVariables.categories} 3.) Item is not belong to vendor ${GlobalVariables.vendors}"));
    }
  }
}
