import 'package:flutter/material.dart';
import 'package:physicalcountv2/values/globalVariables.dart';

class BodySize {
  static double wdth = MediaQuery.of(GlobalVariables.bodyContext).size.width;
  static double hghth = MediaQuery.of(GlobalVariables.bodyContext).size.height;
  static double appBarSizeHght = AppBar().preferredSize.height;
}
