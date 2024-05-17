import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_poc_whapp/dto/chat.dart';
import 'package:firestore_poc_whapp/dto/user.dart';

class ChatRoomDTO {
  UserDTO customer;
  UserDTO courier;
  List<ChatDTO> chats;

  ChatRoomDTO({this.customer, this.courier, this.chats});
  
  factory ChatRoomDTO.fromFirestore(
      DocumentSnapshot snapshot

      ) {
    final data = snapshot;

    return ChatRoomDTO(
      customer: UserDTO(id: data["customer"]["id"], name: data["customer"]["name"]),
      courier: UserDTO(id: data["courier"]["id"], name: data["courier"]["name"]),
    );
  }
}