import 'package:flutter/material.dart';

itemNotFoundModal(BuildContext context, Icon icon, Text msg) {
  return showModalBottomSheet(
    isDismissible: true,
    enableDrag: true,
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: icon,
              ),
              Padding(
                padding:
                    const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
                child: msg,
              ),
            ],
          ),
        ),
      );
    },
  );
}
