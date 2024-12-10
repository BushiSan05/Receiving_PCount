import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:physicalcountv2/services/api.dart';
import 'package:physicalcountv2/widget/instantMsgModal.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'dart:ui' as ui;
import 'dart:convert';

class SignatureCapture extends StatefulWidget {
  const SignatureCapture({Key? key}) : super(key: key);

  @override
  _SignatureCaptureState createState() => _SignatureCaptureState();
}

class _SignatureCaptureState extends State<SignatureCapture> {
  final GlobalKey<SfSignaturePadState> signatureUserGlobalKey = GlobalKey();
  final GlobalKey<SfSignaturePadState> signatureAuditGlobalKey = GlobalKey();
  List _locations = [];
  bool _doneGetUsers = false;
  String _selectedUser = "";
  String _selectedAudit = "";
  int _selectedIndex = -1;
  String _selectedLocation = "";
  bool _showPad = false;
  bool _done = true;

  @override
  void initState() {
    getUsers();
    super.initState();
  }

  getUsers() async {
    _locations = await getAllUsers();
    _doneGetUsers = true;
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 0.0,
        elevation: 0.0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Flexible(
              child: Material(
                type: MaterialType.transparency,
                child: Text(
                  "Signature Uploading [$_selectedLocation]",
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
              onPressed: () {
                _showPad = !_showPad;
                if (mounted) setState(() {});
                if (!_showPad) {
                  _locations = [];
                  _selectedUser = "";
                  _selectedAudit = "";
                  _selectedIndex = -1;
                  _selectedLocation = "";
                  _doneGetUsers = false;
                  if (mounted) setState(() {});
                  getUsers();
                }
              },
              icon: Icon(
                !_showPad
                    ? CupertinoIcons.signature
                    : CupertinoIcons.square_list,
                color: Colors.blue,
              )),
        ],
      ),
      body: Column(
        children: [
          _done ? SizedBox() : LinearProgressIndicator(),
          _doneGetUsers == true
              ? _locations.length == 0
                  ? Center(
                      child: Text("No record found."),
                    )
                  : SizedBox()
              : CircularProgressIndicator(),
          !_showPad
              ? Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: _locations.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          child: ListTile(
                            tileColor: _selectedIndex == index
                                ? Colors.red[100]
                                : null,
                            title: Text(
                                "${_locations[index]["business_unit"]}/${_locations[index]["department"]}/${_locations[index]["section"]}/${_locations[index]["rack_desk"]}"),
                            subtitle: Text(
                                "User: ${_locations[index]["user"]}\nAudit:${_locations[index]["audit"]}"),
                          ),
                          onTap: () {
                            _selectedIndex = index;
                            _selectedUser = _locations[index]["user"];
                            _selectedAudit = _locations[index]["audit"];
                            _selectedLocation = _locations[index]["location_id"];
                            if (mounted) setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                )
              : SizedBox(),
          _showPad
              ? Row(
                  children: [
                    Text(
                      "User Signature",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                        onPressed: () {
                          signatureUserGlobalKey.currentState!.clear();
                        },
                        child: Text("Clear"))
                  ],
                )
              : SizedBox(),
          _showPad
              ? Padding(
                  padding: EdgeInsets.only(right: 8, left: 8),
                  child: Container(
                      child: SfSignaturePad(
                        key: signatureUserGlobalKey,
                        backgroundColor: Colors.white,
                        strokeColor: Colors.black,
                        minimumStrokeWidth: 3.0,
                        maximumStrokeWidth: 6.0,
                        // minimumStrokeWidth: 1.0,
                        // maximumStrokeWidth: 4.0,
                      ),
                      decoration: BoxDecoration(
                        // borderRadius: ,
                          border: Border.all(color: Colors.grey)
                          // border: Border.all(color: Colors.grey)
                      )))
              : SizedBox(),
          _showPad
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${_selectedUser.toUpperCase()}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : SizedBox(),
          _showPad ? Divider() : SizedBox(),
          _showPad
              ? Row(
                  children: [
                    Text(
                      "  Auditor Signature",
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    TextButton(
                      onPressed: () {
                        signatureAuditGlobalKey.currentState!.clear();
                      },
                      child: Text("Clear"),
                    ),
                  ],
                )
              : SizedBox(),
          _showPad
              ? Padding(
                   padding: EdgeInsets.only(right: 8, left: 8),
                  //padding: EdgeInsets.fromLTRB(5, 0, 5, 70),
                  child: Container(
                      child: SfSignaturePad(
                          key: signatureAuditGlobalKey,
                          backgroundColor: Colors.white,
                          strokeColor: Colors.black,
                          minimumStrokeWidth: 3.0,
                          maximumStrokeWidth: 6.0),
                          // height: 100,
                          // width: 100,
                          decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                             //   borderRadius: BorderRadius.all(Radius.circular(100)
                             // ),
                          )))
              : SizedBox(),
          _showPad
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${_selectedAudit.toUpperCase()}",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              : SizedBox(),
          _showPad
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MaterialButton(
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
                            "Upload",
                            style: TextStyle(color: Colors.white, fontSize: 25),
                          ),
                        ],
                      ),
                    ),
                    onPressed: () async {
                      if (_selectedIndex == -1) {
                        instantMsgModal(
                            context,
                            Icon(
                              CupertinoIcons.exclamationmark_circle,
                              color: Colors.red,
                              size: 40,
                            ),
                            Text("No location selected."));
                      } else {
                        final dataUser = await signatureUserGlobalKey
                            .currentState!
                            .toImage(pixelRatio: 3.0);
                        final bytesUser = await dataUser.toByteData(
                            format: ui.ImageByteFormat.png);
                        final dataAudit = await signatureAuditGlobalKey
                            .currentState!
                            .toImage(pixelRatio: 3.0);
                        final bytesAudit = await dataAudit.toByteData(
                            format: ui.ImageByteFormat.png);
                        if (signatureUserGlobalKey.currentState!
                                .toPathList()
                                .length ==
                            0) {
                          instantMsgModal(
                              context,
                              Icon(
                                CupertinoIcons.exclamationmark_circle,
                                color: Colors.red,
                                size: 40,
                              ),
                              Text(
                                  "User signature and Auditor signature are required to signed before syncing."));
                        } else {
                          _done = false;
                          if (mounted) setState(() {});
                          continueSync(
                              base64Encode(bytesUser!.buffer.asUint8List()),
                              base64Encode(bytesAudit!.buffer.asUint8List()));
                        }
                      }
                    },
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  continueSync(String bytesUser, String bytesAudit) async {
    await updateSignature(_selectedLocation, bytesUser, bytesAudit);
    instantMsgModal(
        context,
        Icon(
          CupertinoIcons.checkmark_alt_circle,
          color: Colors.green,
          size: 40,
        ),
        Text("Signature successfully uploaded."));
    _done = true;
    Navigator.pop(context);
    if (mounted) setState(() {});
  }
}
