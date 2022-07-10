import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';

List<UserProfile> sortUserProfilesById(UserProfile userA, UserProfile userB) {
  List<UserProfile> userProfiles = [userA, userB];
  userProfiles.sort((a, b) => a.userId.compareTo(b.userId));
  return userProfiles;
}

class UserProfile implements JsonModel {
  @override
  String id;
  String userId;
  String name;
  String nameLowerCaseNoSpace;
  String? photoURL;
  DateTime? createAt = DateTime.now();
  DateTime? updateAt = DateTime.now();

  UserProfile({
    this.id = "",
    required this.userId,
    required this.name,
    required this.nameLowerCaseNoSpace,
    this.photoURL,
    this.createAt,
    this.updateAt,
  });

  @override
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      nameLowerCaseNoSpace: json['nameLowerCaseNoSpace'],
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
      'nameLowerCase': nameLowerCaseNoSpace,
      'userId': userId,
      'photoURL': photoURL,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
