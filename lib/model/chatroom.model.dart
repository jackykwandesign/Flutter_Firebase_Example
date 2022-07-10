import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';
import 'package:flutter/cupertino.dart';

class Chatroom implements JsonModel {
  @override
  String id;
  List<String> userIds;
  List<String> userPhotosURLs;
  DateTime? createAt = DateTime.now();
  DateTime? updateAt = DateTime.now();

  Chatroom(
      {this.id = "",
      required this.userIds,
      required this.userPhotosURLs,
      this.createAt,
      this.updateAt});

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userIds': userIds,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
