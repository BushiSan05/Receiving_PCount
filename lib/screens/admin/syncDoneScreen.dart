import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:physicalcountv2/values/assets.dart';
import 'package:physicalcountv2/values/bodySize.dart';

class SyncDoneScreen extends StatelessWidget {
  const SyncDoneScreen({Key? key}) : super(key: key);

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
                  child: Lottie.asset(Assets.lottiesuccess,
                      height: BodySize.hghth / 3)),
              Text("Synced successfully."),
              MaterialButton(
                color: Colors.blue,
                child: Text(
                  "Okay",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () => close(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  close(BuildContext context) {
    Navigator.pop(context);
    Navigator.pop(context);
  }
}
