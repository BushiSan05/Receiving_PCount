import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

customLogicalModal(
    BuildContext context, Text msg, VoidCallback noFn, VoidCallback yesFn) {
  var size = MediaQuery.of(context).size;
  return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(10))),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Icon(CupertinoIcons.question_circle,
                        size: 50, color: Colors.blueAccent),
                  ),
                  Padding(
                      padding: const EdgeInsets.only(bottom: 8.0), child: msg),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        InkWell(
                          child: Container(
                            width: size.width / 3,
                            height: size.height / 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Spacer(),
                                Icon(
                                  CupertinoIcons.xmark,
                                  size: 25,
                                  color: Colors.redAccent,
                                ),
                                Text("No"),
                                Spacer(),
                              ],
                            ),
                          ),
                          onTap: noFn,
                        ),
                        InkWell(
                          child: Container(
                            width: size.width / 3,
                            height: size.height / 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Spacer(),
                                Icon(
                                  CupertinoIcons.checkmark_alt,
                                  size: 25,
                                  color: Colors.green,
                                ),
                                Text("Yes"),
                                Spacer(),
                              ],
                            ),
                          ),
                          onTap: yesFn,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      });
}
