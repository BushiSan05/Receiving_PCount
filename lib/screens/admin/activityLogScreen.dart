import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:physicalcountv2/db/models/logsModel.dart';
import 'package:physicalcountv2/db/sqfLite_dbHelper.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({Key? key}) : super(key: key);

  @override
  _ActivityLogScreenState createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {
  late SqfliteDBHelper _sqfliteDBHelper;
  List<Logs> _logs = [];

  bool _loading = true;

  @override
  void initState() {
    _sqfliteDBHelper = SqfliteDBHelper.instance;
    if (mounted) setState(() {});

    _refreshLogList();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            "Activity Log",
            style: TextStyle(color: Colors.blue),
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
                : _logs.length > 0
                    ? Expanded(
                        child: Scrollbar(
                          child: ListView.builder(
                            itemCount: _logs.length,
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
                                      Row(
                                        children: [
                                          Icon(CupertinoIcons.calendar,
                                              color: Colors.blue),
                                          Text(
                                              DateFormat("EEEE MMMM, dd, yyyy")
                                                  .format(DateTime.parse(
                                                      _logs[index].date!)),
                                              style: TextStyle(fontSize: 20)),
                                          Text("     "),
                                          Icon(CupertinoIcons.alarm,
                                              color: Colors.red),
                                          Text(_logs[index].time!,
                                              style: TextStyle(fontSize: 20)),
                                        ],
                                      ),
                                      Text(_logs[index].details!),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text("User: " + _logs[index].user!),
                                          Text("Employee ID: " +
                                              _logs[index].empid!),
                                          Text("Device: " +
                                              _logs[index].device!),
                                        ],
                                      ),
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

  _refreshLogList() async {
    List<Logs> x = await _sqfliteDBHelper.fetchLogs();
    if (mounted)
      setState(() {
        _logs = x;
        _loading = false;
      });
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
}
