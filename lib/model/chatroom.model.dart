import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';

class Chatroom implements JsonModel {
  @override
  String id;
  List<String> userIds;
  List<String> userPhotosURLs;
  DateTime createAt = DateTime.now();
  DateTime updateAt = DateTime.now();

  Chatroom({this.id = "", required this.userIds, required this.userPhotosURLs});

  Chatroom.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        userIds = json['userIds'],
        userPhotosURLs = json['userPhotosURLs'],
        createAt = json['createAt'] == null
            ? DateTime.now()
            : DateTime.parse(json['createAt'].toDate().toString()),
        updateAt = json['updateAt'] == null
            ? DateTime.now()
            : DateTime.parse(json['updateAt'].toDate().toString());

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
