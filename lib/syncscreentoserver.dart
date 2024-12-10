

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

  class SyncScreen extends StatefulWidget{

      late String passbytesUser;
      late String passbytesAudit;

      SyncScreen({required this.passbytesUser,required this.passbytesAudit}) :super();

    @override
    _SyncScreen createState() => new _SyncScreen();

  }

  class _SyncScreen extends State<SyncScreen>{
    bool checkingNetwork = false;
    bool syncingStatus = false;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(

    );
  }


  }