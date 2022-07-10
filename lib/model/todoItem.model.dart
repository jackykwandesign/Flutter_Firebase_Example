import 'package:cloud_firestore/cloud_firestore.dart';

abstract class JsonModel {
  JsonModel();
  String id = '';
}

class TodoItem implements JsonModel {
  @override
  String id;

  String name;
  bool isFinished;
  DateTime? createAt = DateTime.now();
  DateTime? updateAt = DateTime.now();

  TodoItem(
      {this.id = "",
      required this.name,
      this.isFinished = false,
      this.createAt,
      this.updateAt});

  @override
  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['id'],
      name: json['name'],
      isFinished: json['isFinished'],
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
      'isFinished': isFinished,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
