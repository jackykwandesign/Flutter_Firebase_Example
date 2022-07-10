import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_flutter_1/model/todoItem.model.dart';

class ChatMessage implements JsonModel {
  @override
  String id;
  String chatroomId;
  String message;
  String sendByUserId;
  DateTime? createAt = DateTime.now();
  DateTime? updateAt = DateTime.now();

  ChatMessage({
    this.id = "",
    required this.chatroomId,
    required this.message,
    required this.sendByUserId,
    this.createAt,
    this.updateAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      chatroomId: json['chatroomId'],
      message: json['message'],
      sendByUserId: json['sendByUserId'],
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
      'message': message,
      'chatroomId': chatroomId,
      'sendByUserId': sendByUserId,
      'createAt': FieldValue.serverTimestamp(),
      'updateAt': FieldValue.serverTimestamp(),
    };
  }
}
