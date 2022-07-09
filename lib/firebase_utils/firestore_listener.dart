import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';
import 'package:flutter/material.dart';

Future<void> firestoreListener(FirebaseFirestore db, String collection,
    List<JsonModel> dataArray, void Function(void Function()) setState) async {
  db.collection(collection).snapshots().listen((event) {
    for (var change in event.docChanges) {
      switch (change.type) {
        case DocumentChangeType.added:
          int foundIndex =
              dataArray.indexWhere((element) => element.id == change.doc.id);
          if (foundIndex == -1) {
            setState(() {
              dataArray.add(TodoItem.fromJson(
                  {...?change.doc.data(), "id": change.doc.id}));
            });
          }
          debugPrint("New ${dataArray.runtimeType} Item: ${change.doc.data()}");
          break;
        case DocumentChangeType.modified:
          int foundIndex =
              dataArray.indexWhere((element) => element.id == change.doc.id);
          if (foundIndex != -1) {
            setState(() {
              dataArray[foundIndex] = TodoItem.fromJson(
                  {...?change.doc.data(), "id": change.doc.id});
            });
          }
          debugPrint("Modified ${dataArray.runtimeType}: ${change.doc.data()}");
          break;
        case DocumentChangeType.removed:
          int foundIndex =
              dataArray.indexWhere((element) => element.id == change.doc.id);
          if (foundIndex != -1) {
            setState(() {
              dataArray.removeAt(foundIndex);
            });
          }
          debugPrint("Removed ${dataArray.runtimeType}: ${change.doc.data()}");
          break;
      }
    }
  });
}
