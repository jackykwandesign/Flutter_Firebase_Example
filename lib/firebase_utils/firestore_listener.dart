import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_me/model/todoItem.model.dart';
import 'package:flutter/material.dart';

Future<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
    getFirestoreListener(
        Stream<QuerySnapshot<Map<String, dynamic>>> snapshots,
        List<JsonModel> dataArray,
        void Function(void Function()) setState,
        Function(Map<String, dynamic>) fromJson) async {
  return snapshots.listen(
    (event) {
      for (var change in event.docChanges) {
        switch (change.type) {
          case DocumentChangeType.added:
            int foundIndex =
                dataArray.indexWhere((element) => element.id == change.doc.id);
            if (foundIndex == -1) {
              debugPrint('NEW ITEM: old length ${dataArray.length}');
              setState(() {
                dataArray.add(
                    fromJson({...?change.doc.data(), "id": change.doc.id}));
              });
              debugPrint('NEW ITEM: new length ${dataArray.length}');
              debugPrint(
                  "New ${dataArray.runtimeType} Item: ${change.doc.data()}");
            }

            break;
          case DocumentChangeType.modified:
            int foundIndex =
                dataArray.indexWhere((element) => element.id == change.doc.id);
            if (foundIndex != -1) {
              setState(() {
                dataArray[foundIndex] =
                    fromJson({...?change.doc.data(), "id": change.doc.id});
              });
              debugPrint(
                  "Modified ${dataArray.runtimeType}: ${change.doc.data()}");
            }

            break;
          case DocumentChangeType.removed:
            int foundIndex =
                dataArray.indexWhere((element) => element.id == change.doc.id);
            if (foundIndex != -1) {
              setState(() {
                dataArray.removeAt(foundIndex);
              });
              debugPrint(
                  "Removed ${dataArray.runtimeType}: ${change.doc.data()}");
            }

            break;
        }
      }
    },
  );
}
