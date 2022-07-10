import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';

class UserProfile implements JsonModel {
  @override
  String id;

  String name;
  String? photoURL;
  DateTime? createAt = DateTime.now();
  DateTime? updateAt = DateTime.now();

  UserProfile({
    this.id = "",
    required this.name,
    this.photoURL,
    this.createAt,
    this.updateAt,
  });

  @override
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      name: json['name'],
      photoURL: json['photoURL'],
      createAt: json['createAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createAt'].toDate().toString()),
      updateAt: json['updateAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['updateAt'].toDate().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'photoURL': photoURL,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
