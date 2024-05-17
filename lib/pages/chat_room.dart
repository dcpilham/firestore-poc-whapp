import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firestore_poc_whapp/components/chat_bubble.dart';
import 'package:firestore_poc_whapp/constants/user_type.dart';
import 'package:firestore_poc_whapp/dto/chat.dart';
import 'package:firestore_poc_whapp/dto/chat_room.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ChatRoomArguments {
  String orderId;
  UserType userType;

  ChatRoomArguments(this.orderId, this.userType);
}

class ChatRoom extends StatefulWidget {
  static const String routeName = "/chat-room";
  final ChatRoomArguments args;

  ChatRoom(this.args);

  @override
  State<StatefulWidget> createState() {
    return _ChatRoomState();
  }
}

class _ChatRoomState extends State<ChatRoom> {
  TextEditingController _chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("orders")
            .doc(widget.args.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ChatRoomDTO chatRoomDTO = ChatRoomDTO.fromFirestore(snapshot.data);
            String recipient = UserType.customer == widget.args.userType
                ? chatRoomDTO.courier.name
                : chatRoomDTO.customer.name;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.tealAccent,
                title: Text(recipient ?? ""),
              ),
              body: Column(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection("orders")
                              .doc(widget.args.orderId)
                              .collection("chats")
                              .orderBy("createdAt", descending: true)
                              .snapshots(),
                          builder: (context, snapshot) {
                            final currentUserId =
                            UserType.courier == widget.args.userType
                                ? chatRoomDTO.courier?.id
                                : chatRoomDTO.customer?.id;
                            if (snapshot.hasData) {
                              final chats = snapshot.data.docs
                                  .map((e) => ChatDTO.fromFirestore(e))
                                  .toList();
                              return ListView.builder(
                                  shrinkWrap: true,
                                  reverse: true,
                                  itemCount: chats?.length,
                                  itemBuilder: (e, index) =>
                                      ChatBubble(chats[index], currentUserId));
                            }
                            return Container();
                          }),
                    ),
                  ),
                  Container(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Expanded(
                            child: TextField(
                              controller: _chatController,
                            )),
                        IconButton(
                            onPressed: () => _sendDataToFireStore(chatRoomDTO),
                            icon: const Icon(
                              Icons.send,
                              color: Colors.green,
                            ))
                      ],
                    ),
                  )
                ],
              ),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error.toString());
            return Text("ERROR");
          }
          return const Center(
            child: CircularProgressIndicator()
          );
        });
  }

  _sendDataToFireStore(ChatRoomDTO chatRoomDTO) {
    if (_chatController.text.isEmpty) {
      return;
    }
    Map<String, dynamic> data = {
      "senderUserId": UserType.courier == widget.args.userType ? chatRoomDTO.courier?.id : chatRoomDTO.customer?.id,
      "message": _chatController.text,
      "createdAt": Timestamp.now()
    };
    FirebaseFirestore.instance.collection("orders")
        .doc(widget.args.orderId)
        .collection("chats")
        .add(data);
    setState(() {
      _chatController.text = "";
    });
  }
}
