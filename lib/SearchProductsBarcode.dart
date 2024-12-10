// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
// import 'package:intl/intl.dart';
//
// class SearchProductsBarcode extends StatefulWidget {
//   const SearchProductsBarcode({Key? key}) : super(key: key);
//
//   @override
//   _SearchProductsBarcodeState createState() => _SearchProductsBarcodeState();
// }
//
// class _SearchProductsBarcodeState extends State<SearchProductsBarcode> {
//   int offset = 0;
//   var _controller = ScrollController();
//
//   bool initLoad = true;
//
//   String barcode = '';
//
//   @override
//   void initState() {
//     scanBarcodeNormal();
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     // GlobalVariables.searchProduct = [];
//     super.dispose();
//   }
//
//   // Sessiontimer sessionTimer = Sessiontimer();
//   // void handleUserInteraction([_]) {
//   //   if (GlobalVariables.logcustomerCode.isNotEmpty) {
//   //     sessionTimer.initializeTimer(context);
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     var size = MediaQuery.of(context).size;
//     var appBarSize = AppBar().preferredSize.height;
//     var safePadding = MediaQuery.of(context).padding.top;
//     return GestureDetector(
//       behavior: HitTestBehavior.translucent,
//       onTap: handleUserInteraction,
//       onPanDown: handleUserInteraction,
//       child: WillPopScope(
//         onWillPop: () async => false,
//         child: Scaffold(
//           body: Column(
//             children: [
//               Container(height: safePadding, color: brandingColor),
//               Container(
//                 color: brandingColor,
//                 alignment: Alignment.center,
//                 height: appBarSize,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 8.0, top: 8.0, bottom: 8.0),
//                       child: IconButton(
//                           onPressed: () => Navigator.pop(context),
//                           icon: Icon(Icons.arrow_back, color: Colors.white)),
//                     ),
//                     Padding(
//                       padding: const EdgeInsets.only(
//                           left: 8.0, top: 8.0, bottom: 8.0),
//                       child: Container(
//                         height: double.infinity,
//                         decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.all(Radius.circular(5))),
//                         child: Row(
//                           children: [
//                             Padding(
//                                 padding: const EdgeInsets.all(8.0),
//                                 child: Icon(CupertinoIcons.barcode,
//                                     color: Colors.grey)),
//                             Padding(
//                               padding: const EdgeInsets.only(
//                                   right: 8.0, top: 8.0, bottom: 8.0),
//                               child: Text(barcode),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Spacer(),
//                     IconButton(
//                         onPressed: () {
//                           initLoad = true;
//                           if (mounted) setState(() {});
//                           scanBarcodeNormal();
//                         },
//                         icon: Icon(CupertinoIcons.barcode_viewfinder,
//                             color: Colors.white)),
//                     Spacer(),
//                   ],
//                 ),
//               ),
//               initLoad == false
//                   ? GlobalVariables.searchProduct.length > 0
//                   ? Expanded(
//                 child: NotificationListener<
//                     OverscrollIndicatorNotification>(
//                   onNotification: (overscroll) {
//                     overscroll.disallowIndicator();
//                     return false;
//                   },
//                   child: Scrollbar(
//                     child: GridView.builder(
//                       controller: _controller,
//                       padding: EdgeInsets.all(0),
//                       itemCount:
//                       GlobalVariables.searchProduct.length + 1,
//                       gridDelegate:
//                       SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount:
//                           GlobalVariables.axisCount,
//                           mainAxisSpacing: 3.5,
//                           crossAxisSpacing: 3.5,
//                           childAspectRatio:
//                           MediaQuery.of(context).size.width /
//                               (MediaQuery.of(context)
//                                   .size
//                                   .height /
//                                   1.5)),
//                       itemBuilder: (BuildContext context, int index) {
//                         if (index ==
//                             GlobalVariables.searchProduct.length) {
//                           if (offset <=
//                               GlobalVariables.searchProduct.length) {
//                             return Center(
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8),
//                                   child: CircularProgressIndicator(),
//                                 ));
//                           } else if (offset >
//                               GlobalVariables.searchProduct.length) {
//                             return Container(
//                               color: Colors.white,
//                               child: Row(
//                                 mainAxisAlignment:
//                                 MainAxisAlignment.center,
//                                 children: [
//                                   Text("End of List",
//                                       style: TextStyle(
//                                           color: brandingColor)),
//                                 ],
//                               ),
//                             );
//                           }
//                         }
//
//                         return InkWell(
//                           onTap: () {
//                             var code = GlobalVariables
//                                 .searchProduct[index]['itemcode'];
//                             GlobalVariables.productDetails = [];
//
//                             for (int i = 0;
//                             i <
//                                 GlobalVariables
//                                     .searchProduct.length;
//                             i++) {
//                               if (GlobalVariables.searchProduct[i]
//                               ['itemcode'] ==
//                                   code) {
//                                 GlobalVariables.productDetails.add(
//                                     GlobalVariables.searchProduct[i]
//                                     ['units']);
//                               }
//                             }
//                             print(GlobalVariables.productDetails);
//                             productDetails(
//                                 context,
//                                 true,
//                                 GlobalVariables.searchProduct[index]
//                                 ['item_path'],
//                                 GlobalVariables.searchProduct[index]
//                                 ['description'],
//                                 double.parse(GlobalVariables
//                                     .searchProduct[index]
//                                 ['list_price_wtax']),
//                                 GlobalVariables.searchProduct[index]
//                                 ['keywords'],
//                                 GlobalVariables.searchProduct[index]
//                                 ['product_family'],
//                                 false);
//                           },
//                           child: Container(
//                             color: Colors.white,
//                             height: size.height / 3,
//                             child: Column(
//                               crossAxisAlignment:
//                               CrossAxisAlignment.start,
//                               children: [
//                                 Expanded(
//                                   child: Container(
//                                     width: double.infinity,
//                                     color: Colors.white,
//                                     child: CachedNetworkImage(
//                                       imageUrl: ServerUrl.itmImgUrl +
//                                           GlobalVariables
//                                               .searchProduct[
//                                           index]['item_path'],
//                                       placeholder: (context, url) =>
//                                           Center(
//                                               child:
//                                               CircularProgressIndicator()),
//                                       errorWidget: (context, url,
//                                           error) =>
//                                           Icon(Icons.error,
//                                               color:
//                                               Colors.grey[200]),
//                                     ),
//                                   ),
//                                 ),
//                                 Container(
//                                   height: (size.height / 3) / 3,
//                                   child: Column(
//                                     crossAxisAlignment:
//                                     CrossAxisAlignment.start,
//                                     children: [
//                                       Padding(
//                                         padding:
//                                         const EdgeInsets.all(3.0),
//                                         child: Text(
//                                             GlobalVariables
//                                                 .searchProduct[
//                                             index]['description'],
//                                             style: TextStyle(
//                                               fontSize: ScreenUtil()
//                                                   .setSp(13),
//                                             ),
//                                             overflow:
//                                             TextOverflow.ellipsis,
//                                             maxLines: 2),
//                                       ),
//                                       Padding(
//                                         padding:
//                                         const EdgeInsets.only(
//                                             left: 3.0,
//                                             right: 3.0),
//                                         child: Text(
//                                             GlobalVariables
//                                                 .searchProduct[
//                                             index]['uom'],
//                                             style: TextStyle(
//                                               color: Colors.grey,
//                                               fontSize: ScreenUtil()
//                                                   .setSp(13),
//                                             ),
//                                             overflow:
//                                             TextOverflow.ellipsis,
//                                             maxLines: 1),
//                                       ),
//                                       Spacer(),
//                                       Padding(
//                                         padding:
//                                         const EdgeInsets.all(3.0),
//                                         child: Row(
//                                           children: [
//                                             Text(
//                                                 NumberFormat.currency(
//                                                     locale: 'en',
//                                                     symbol: '₱ ')
//                                                     .format(double.parse(
//                                                     GlobalVariables
//                                                         .searchProduct[
//                                                     index]
//                                                     [
//                                                     'list_price_wtax'])),
//                                                 style: TextStyle(
//                                                     fontSize:
//                                                     ScreenUtil()
//                                                         .setSp(
//                                                         13),
//                                                     color:
//                                                     brandingColor),
//                                                 overflow: TextOverflow
//                                                     .ellipsis,
//                                                 maxLines: 1),
//                                             Spacer(),
//                                             Text(
//                                               "${NumberFormat.compact().format(int.parse(GlobalVariables.searchProduct[index]['sold']))} sold",
//                                               style: TextStyle(
//                                                   color: int.parse(GlobalVariables
//                                                       .searchProduct[index]
//                                                   [
//                                                   'sold']) >
//                                                       0
//                                                       ? Colors.grey
//                                                       : Colors.white,
//                                                   fontSize: 12),
//                                             )
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//                   ),
//                 ),
//               )
//                   : loadingProducts()
//                   : SizedBox()
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget loadingProducts() {
//     var size = MediaQuery.of(context).size;
//     return Expanded(
//       child: NotificationListener<OverscrollIndicatorNotification>(
//         onNotification: (overscroll) {
//           overscroll.disallowIndicator();
//           return false;
//         },
//         child: Scrollbar(
//           child: GridView.builder(
//             key: PageStorageKey(0),
//             padding: EdgeInsets.all(0),
//             itemCount: 10,
//             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 mainAxisSpacing: 3.5,
//                 crossAxisSpacing: 3.5,
//                 childAspectRatio: MediaQuery.of(context).size.width /
//                     (MediaQuery.of(context).size.height / 1.5)),
//             itemBuilder: (BuildContext context, int index) {
//               return Container(
//                 color: Colors.white,
//                 height: size.height / 3,
//                 child: Column(
//                   children: [
//                     Spacer(),
//                     Padding(
//                       padding: const EdgeInsets.all(1),
//                       child: Center(
//                         child: CircularProgressIndicator(
//                             valueColor:
//                             AlwaysStoppedAnimation<Color>(Colors.black12)),
//                       ),
//                     ),
//                     Spacer(),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
//
//   loadOffset() async {
//     GlobalVariables.selectedCategoryName = 'ALL PRODUCTS';
//     var p = await getSearchProductsBarcodeOffset(
//         context, barcode, GlobalVariables.selectedCategoryName, offset);
//     List r = p;
//     print("testsetsetsetestsetsetstsetsetsetsett");
//
//     if (r.length > 0) {
//       List offsetP = p;
//       GlobalVariables.searchProduct.addAll(offsetP);
//       offset = offset + 20;
//       if (mounted) setState(() {});
//     } else {
//       if (offset <= GlobalVariables.searchProduct.length) {
//         initLoad = true;
//         offset = 0;
//         GlobalVariables.searchProduct = [];
//         if (mounted) setState(() {});
//         customModal(
//             context,
//             Icon(CupertinoIcons.info_circle, size: 50, color: Colors.blue),
//             Text("No result(s) found for $barcode.",
//                 textAlign: TextAlign.center),
//             true,
//             Icon(
//               CupertinoIcons.checkmark_alt,
//               size: 25,
//               color: Colors.greenAccent,
//             ),
//             '',
//                 () {});
//       }
//     }
//   }
//
//   Future<void> scanBarcodeNormal() async {
//     String barcodeScanRes;
//     // Platform messages may fail, so we use a try/catch PlatformException.
//     try {
//       barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
//           '#ff6666', 'Cancel', true, ScanMode.BARCODE);
//       print(barcodeScanRes);
//     } on PlatformException {
//       barcodeScanRes = 'Failed to get platform version.';
//     }
//
//     // If the widget was removed from the tree while the asynchronous platform
//     // message was in flight, we want to discard the reply rather than calling
//     // setState to update our non-existent appearance.
//     if (!mounted) return;
//
//     barcode = barcodeScanRes;
//     initLoad = false;
//     // GlobalVariables.searchProduct = [];
//     if (mounted) setState(() {});
//     print(barcode);
//     await loadOffset();
//   }
// }
