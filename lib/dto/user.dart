import 'package:cloud_firestore/cloud_firestore.dart';

class UserDTO {
  int id;
  String name;

  UserDTO({this.id, this.name});

  factory UserDTO.fromFirestore(
      DocumentSnapshot snapshot
      ) {
    final data = snapshot.data();
    return UserDTO(
      id: data["id"],
      name: data["name"]
    );
  }
}