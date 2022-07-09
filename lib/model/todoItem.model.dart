import 'package:cloud_firestore/cloud_firestore.dart';

class TodoItem {
  String id;
  String name;
  bool isFinished = false;
  DateTime createAt = DateTime.now();
  DateTime updateAt = DateTime.now();

  TodoItem({
    this.id = "",
    required this.name,
  });

  TodoItem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        isFinished = json['isFinished'],
        createAt = json['createAt'] == null
            ? DateTime.now()
            : DateTime.parse(json['createAt'].toDate().toString()),
        updateAt = json['updateAt'] == null
            ? DateTime.now()
            : DateTime.parse(json['updateAt'].toDate().toString());

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'isFinished': isFinished,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
