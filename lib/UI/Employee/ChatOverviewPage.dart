import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/Model/Client.dart';
import 'package:clean_r/Model/ClientContactModel.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/Base/MessageBadge.dart';
import 'package:clean_r/UI/Base/NullWidget.dart';
import 'package:clean_r/UI/ClientOnBoarding/ChatPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'ClientOverviewPage.dart';

class ChatOverviewPage extends StatelessWidget {
  final CleanRUser user;

  const ChatOverviewPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> clients =
        FirebaseFirestore.instance.collection("Clients");

    return Scaffold(
      appBar: AppBar(
          title: Logo(),
          centerTitle: true,
          actions: [MessageBadge(user: user, messagePath: user.messagePath())]),
      body: CleanRSkin.wrapInFrame(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: StreamBuilder(
              stream: clients.get().asStream(),
              builder: (context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  return Text(
                      "ChatOverviewPage: error : " + snapshot.error.toString());
                } else if (snapshot.hasData) {
                  List<Widget> children = snapshot.data!.docs.map<Widget>(
                      (DocumentSnapshot<Map<String, dynamic>> document) {
                    CollectionReference messages = FirebaseFirestore.instance
                        .collection(document.reference.path + "/messages");

                    var messagePath = document.reference.path + "/messages";

                    Client chatClient =
                        new Client(document.id, document.data()!, context);
                    if (chatClient.isArchived)
                      return NullWidget(); // will be removed from list
                    else
                      return createUIFromChatClient(
                          messages, messagePath, chatClient);
                  }).toList();
                  //remove null (archived clients) elements from list
                  children.removeWhere((element) => element is NullWidget);

                  return ListView(
                    children: children,
                  );
                } else
                  return Text("Loading messages");
              }),
        ),
      ),
    );
  }

  FutureBuilder<QuerySnapshot> createUIFromChatClient(
      CollectionReference messages, String messagePath, Client chatClient) {
    return FutureBuilder<QuerySnapshot>(
        future: messages.get(),
        builder: (context, messagesSnapshot) {
          if (messagesSnapshot.hasError) {
            return Text("createUIFromChatClient : error :" +
                messagesSnapshot.error.toString());
          } else if (messagesSnapshot.hasData) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ChatPage(user, messagePath);
                  }),
                );
              },
              onLongPress: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return ClientOverviewPage(client: chatClient);
                  }),
                );
              },
              child: Card(
                elevation: 14,
                child: createUIFromMessagesAndClientContact(
                    chatClient, context, messagesSnapshot.data!.size),
              ),
            );
          } else {
            return Text("Loading");
          }
        });
  }

  StreamBuilder<Iterable<ClientContactModel>>
      createUIFromMessagesAndClientContact(
          Client chatClient, BuildContext context, int nbMessages) {
    return StreamBuilder<Iterable<ClientContactModel>>(
        stream: chatClient.contactModelStream(context),
        builder: (context, clientContactSnapshot) {
          if (clientContactSnapshot.hasError) {
            return Text("createUIFromMessagesAndClientContact: error : " +
                clientContactSnapshot.error.toString());
          } else if (clientContactSnapshot.hasData) {
            ClientContactModel clientContactModel =
                clientContactSnapshot.data!.first;
            String? firstName = clientContactModel.firstNameAttribute!.value;
            if (firstName == null) {
              firstName = "<No First Name>";
            }
            String? lastName = clientContactModel.lastNameAttribute!.value;
            if (lastName == null) {
              lastName = "<No Last Name>";
            }

            String clientName = firstName +
                " " +
                lastName +
                " " +
                clientContactModel.client.clientID;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                        child: Text(
                      clientName,
                      textScaleFactor: 1,
                    )),
                    Expanded(
                        child: Text(
                      nbMessages.toString(),
                      textAlign: TextAlign.right,
                      textScaleFactor: 1,
                    )),
                  ]),
            );
          } else {
            return Text("Loading Client Contact Model");
          }
        });
  }
}
