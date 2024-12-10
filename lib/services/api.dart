import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:physicalcountv2/services/app_update.dart';
import 'package:physicalcountv2/services/server_url.dart';
import "package:http/http.dart" as http;
import 'package:physicalcountv2/values/globalVariables.dart';
import 'package:retry/retry.dart';

Future checkIfConnectedToNetwork() async {
  try {
    // var url = Uri.parse(ServerUrl.urlCI + "mapi/getItemMasterfileCount");
    //  final response = await http.get(url).timeout(const Duration(seconds: 20));
    //  if (response.statusCode == 00) {
    //    return 'success';
    //  } else if (response.statusCode >= 400 || response.statusCode <= 499) {
    //    GlobalVariables.httpError =
    //        "Error: Client issued a malformed or illegal request.";
    //    return 'error';
    //  } else if (response.statusCode >= 500 || response.statusCode <= 599) {
    //    GlobalVariables.httpError = "Error: Internal server error.";
    //    return 'error';
    //  }
  } on TimeoutException {
    GlobalVariables.httpError =
    "Connection timed out. Please check internet connection or proxy server configurations.";
    return 'errornet';
  } on SocketException {
    GlobalVariables.httpError =
    "Connection timed out. Please check internet connection or proxy server configurations.";
    return 'errornet';
  } on HttpException {
    GlobalVariables.httpError =
    "Error: An HTTP error eccured. Please try again later.";
    return 'error';
  } on FormatException {
    GlobalVariables.httpError =
    "Error: Format exception error occured. Please try again later.";
    return 'error';
  }
}


Future checkConnection() async {
  try {
    var url = Uri.parse(ServerUrl.urlCI + "mapi/checkConnection");
    final response = await http.get(url).timeout(const Duration(seconds: 20));
    if (response.statusCode == 200) {
      return 'connected';
    } else if (response.statusCode >= 400 || response.statusCode <= 499) {
      GlobalVariables.httpError =
      "Error: Client issued a malformed or illegal request.";
      return 'error';
    } else if (response.statusCode >= 500 || response.statusCode <= 599) {
      GlobalVariables.httpError = "Error: Internal server error.";
      return 'error';
    }
  } on TimeoutException {
    GlobalVariables.httpError =
    "Connection timed out. Please check internet connection or proxy server configurations.";
    return 'errornet';
  } on SocketException {
    GlobalVariables.httpError =
    "Connection timed out. Please check internet connection or proxy server configurations.";
    return 'errornet';
  } on HttpException {
    GlobalVariables.httpError =
    "Error: An HTTP error occurred. Please try again later.";
    return 'error';
  } on FormatException {
    GlobalVariables.httpError =
    "Error: Format exception error occurred. Please try again later.";
    return 'error';
  }
}



Future getUserMasterfile() async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getUserMasterfile");
  final response = await retry(
          () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future checkUpdate(String version)async{
  var url = Uri.parse(AppUpdateVersion.urlCICheckUpdate + "mapi/CheckUpdate");
  final response = await retry(
          () => http.post(url, headers: {
        "Accept": "Application/json"
      }, body: {
        'version': version,
      }));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}


Future getAdmin(String haveFilter, String filters) async {

  var url = Uri.parse(AppUpdateVersion.urlCICheckUpdate + "mapi/getAdmin");
  final response = await retry(
          () => http.post(url, headers: {
        "Accept": "Application/json"
      }, body: {
        'haveFilter': haveFilter,
        'filters': filters,
      }));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future getAuditMasterfile() async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getAuditMasterifle");
  final response = await retry(
          () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future getLocationMasterfile() async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getLocationMasterfile");
  final response = await retry(
          () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future getItemMasterfileCount() async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getItemMasterfileCount");
  final response = await retry(
          () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future getUnit(String haveFilter, String filters) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getUnit");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'haveFilter': haveFilter,
    'filters': filters,
  }));
  var convertedDataToJson = jsonDecode(response.body);
  print('convertedDataToJson $convertedDataToJson');
  return convertedDataToJson;
}

Future getItemMasterfileOffset(String offset) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getItemMasterfileOffset");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'offset': offset,
  }));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}
//ffffgfg
// Future getFilteredItemMasterfile() async {
//   var url = Uri.parse(ServerUrl.urlCI + "mapi/getFilteredItemMasterfile");
//   final response = await retry(
//           () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));
//   print('Response status: ${response.statusCode}');
//   print('Response body: ${response.body}');
//
//   // Attempt to decode only if response is valid JSON
//   try {
//     var convertedDataToJson = jsonDecode(response.body);
//     return convertedDataToJson;
//   } catch (e) {
//     print('Error decoding JSON: $e');
//     return null;
//   }
// }

Future getFilteredItemMasterfile() async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getFilteredItemMasterfile");
  final response = await retry(
          () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  // Attempt to decode the response
  try {
    var convertedDataToJson = jsonDecode(response.body);

    // Check if the response contains an error
    if (convertedDataToJson is Map<String, dynamic> && convertedDataToJson['status'] == 'error') {
      print('Error: ${convertedDataToJson['message']}');
      Fluttertoast.showToast(msg: "ERROR!\n"
          "No location found on database.\n"
          "Please set up location first.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black54,
          textColor: Colors.white,
          fontSize: 16.0);
      return null;  // or handle the error message as needed
    }

    // If response is a list, return it
    if (convertedDataToJson is List) {
      return convertedDataToJson;
    }

    // Unexpected response format
    print('Unexpected response format: ${convertedDataToJson}');
    return null;
  } catch (e) {
    print('Error decoding JSON: $e');
    return null;
  }
}


Future syncItem(List items, String usersignature, String auditorsignature) async {
  print("ACTUAL COUNT API");
  print("LOCATION ID :: ${GlobalVariables.currentLocationID}");
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertCountDataList");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'items': json.encode(items),
    'user_signature': usersignature,
    'audit_signature': auditorsignature,
    'empno': GlobalVariables.logEmpNo,
    // 'locationid': GlobalVariables.currentLocationID,
    // 'rackdesc' : GlobalVariables.currentRackDesc,
  }));
  print("Item ACTUAL count RESPONSE2 STATUS CODE :: ${response.body}");
  GlobalVariables.statusCode = response.statusCode;
  var convertedDataToJson = jsonDecode(response.body);
  print("Item ACTUAL RESPONSE2 :: $convertedDataToJson");
  print("location ni ${GlobalVariables.currentLocationID}");
  return convertedDataToJson;
}

Future syncItem_adv(List items, String usersignature, String auditorsignature) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertAdvanceCount");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'items': json.encode(items),
    'empno': GlobalVariables.logEmpNo,
    'user_signature': usersignature,
    'audit_signature': auditorsignature,
    'locationid': GlobalVariables.currentLocationID,
  }));
  print("Item advance count RESPONSE2 STATUS CODE :: ${response.statusCode}");
  GlobalVariables.statusCode = response.statusCode;
  print("Item RESPONSE :: ${response.body}");
  var convertedDataToJson = jsonDecode(response.body);
  print("Item advance RESPONSE2 :: $convertedDataToJson");
  return convertedDataToJson;
}

Future syncItem_freegoods(List items, String usersignature, String auditorsignature) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertFreeGoodsCount");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'items': json.encode(items),
    'empno': GlobalVariables.logEmpNo,
    'user_signature': usersignature,
    'audit_signature': auditorsignature,
    'locationid': GlobalVariables.currentLocationID,
  }));
  GlobalVariables.statusCode = response.statusCode;
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future syncNfItem(List nfItems, String userSignature, String auditSignature) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertNFItemList");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'nfitems': json.encode(nfItems),
    'user_signature': userSignature,
    'audit_signature': auditSignature,
    'empno': GlobalVariables.logEmpNo,
    'locationid': GlobalVariables.currentLocationID,
  }));
  GlobalVariables.statusCode = response.statusCode;
  var convertedDataToJson = jsonDecode(response .body);
  print("location ni ${GlobalVariables.currentLocationID}");
  return convertedDataToJson;
}

Future syncNfItem_freegoods(List nfItems, String userSignature, String auditSignature) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertNFFreeGoods");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'nfitems': json.encode(nfItems),
    'user_signature': userSignature,
    'audit_signature': auditSignature,
  }));
  GlobalVariables.statusCode = response.statusCode;
  var convertedDataToJson = jsonDecode(response .body);
  return convertedDataToJson;
}

Future syncNfItem_adv(List nfItems, String userSignature, String auditSignature) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertNFAdvanceCount");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'nfitems': json.encode(nfItems),
    'user_signature': userSignature,
    'audit_signature': auditSignature,
  }));
  print("Item RESPONSE2 STATUS CODE :: ${response.statusCode}");
  GlobalVariables.statusCode = response.statusCode;
  print("RESPONSE :: ${response.body}");
  var convertedDataToJson = jsonDecode(response.body);
  print("RESPONSE2 :: $convertedDataToJson");
  return convertedDataToJson;
}

Future syncAuditTrail(List logs) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/insertAuditTrail");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'logs': json.encode(logs),
  }));
  GlobalVariables.statusCode = response.statusCode;
  print("AUDIT RESPONSE :: ${response.body}");
  var convertedDataToJson = jsonDecode(response.body);
  print("AUDIT RESPONSE :: $convertedDataToJson");
  return convertedDataToJson;
}

Future getAllUsers() async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/getAllUsers" );
  final response = await retry(
          () => http.post(url, headers: {"Accept": "Application/json"}, body: {}));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future updateSignature(
    String locationid, String userSig, String auditSig) async {
  var url = Uri.parse(ServerUrl.urlCI + "mapi/updateSignature");
  final response = await retry(() => http.post(url, headers: {
    "Accept": "Application/json"
  }, body: {
    'location_id': locationid,
    'user_sig': userSig,
    'audit_sig': auditSig,
  }));
  var convertedDataToJson = jsonDecode(response.body);
  return convertedDataToJson;
}

Future getServer() async{
  var url = Uri.parse(ServerUrl.urlCI + "mapi/updateSignature");
}




