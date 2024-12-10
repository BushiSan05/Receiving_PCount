import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:physicalcountv2/main.dart';
import 'package:physicalcountv2/values/assets.dart';
import 'package:physicalcountv2/values/bodySize.dart';

class NointernetScreen extends StatelessWidget {
  const NointernetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                  child: Lottie.asset(Assets.lottienointernet,
                      height: BodySize.hghth / 2)),
              MaterialButton(
                color: Colors.blue,
                child: Text(
                  "Retry",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => logOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  logOut(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (BuildContext context) => PhysicalCount(),
        ),
        (Route route) => false);
  }
}
