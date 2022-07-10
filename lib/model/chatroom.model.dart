import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';

class Chatroom implements JsonModel {
  @override
  String id;
  List<String> userIds;
  List<String> userPhotosURLs;
  List<String> userNames;
  DateTime? createAt = DateTime.now();
  DateTime? updateAt = DateTime.now();

  Chatroom({
    this.id = "",
    required this.userIds,
    required this.userPhotosURLs,
    required this.userNames,
    this.createAt,
    this.updateAt,
  });

  factory Chatroom.fromJson(Map<String, dynamic> json) {
    return Chatroom(
      id: json['id'],
      createAt: json['createAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createAt'].toDate().toString()),
      updateAt: json['updateAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['updateAt'].toDate().toString()),
      userIds: json['userIds'] != null ? List.from(json['userIds']) : [],
      userPhotosURLs: json['userPhotosURLs'] != null
          ? List.from(json['userPhotosURLs'])
          : [],
      userNames: json['userNames'] != null ? List.from(json['userNames']) : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'userPhotosURLs': userPhotosURLs,
      'userNames': userNames,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
