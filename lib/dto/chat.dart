import 'package:cloud_firestore/cloud_firestore.dart';

class ChatDTO {
  int senderUserId;
  DateTime createdAt;
  String message;

  ChatDTO({this.senderUserId, this.createdAt, this.message});

  factory ChatDTO.fromFirestore(
      DocumentSnapshot snapshot) {
    final data = snapshot.data();
    return ChatDTO(
        senderUserId: data["senderUserId"],
        createdAt: DateTime.fromMillisecondsSinceEpoch((data["createdAt"] as Timestamp).millisecondsSinceEpoch),
        message: data["message"]
    );
  }
}