import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/Model/Base/ContactModel.dart';
import 'package:clean_r/Model/Client.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/Base/MessageBadge.dart';
import 'package:clean_r/UI/Base/NullWidget.dart';
import 'package:clean_r/UI/ClientOnBoarding/ChatPage.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'UserOverviewPage.dart';

class ChatOverviewPage extends StatelessWidget {
  final CleanRUser user;

  const ChatOverviewPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> clients =
        FirebaseFirestore.instance.collection("Clients");
    CollectionReference<Map<String, dynamic>> employees =
        FirebaseFirestore.instance.collection("Employees");

    return Scaffold(
      appBar: AppBar(
          title: Logo(),
          centerTitle: true,
          actions: [MessageBadge(user: user, messagePath: user.messagePath())]),
      body: CleanRSkin.wrapInFrame(
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(children: [
            Text(
              AppLocalizations.of(context).translate("ClientChats"),
              style: TextStyle(fontSize: 20),
            ),
            StreamBuilder(
                stream: clients.get().asStream(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Text("ChatOverviewPage: error : " +
                        snapshot.error.toString());
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
                        return createUIFromChatUser(
                            messages, messagePath, chatClient);
                    }).toList();
                    //remove null (archived clients) elements from list
                    children.removeWhere((element) => element is NullWidget);

                    return Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: ListView(
                        children: children,
                      ),
                    );
                  } else
                    return Text("Loading messages");
                }),
            Divider(),
            Text(
              AppLocalizations.of(context).translate("EmployeeChats"),
              style: TextStyle(fontSize: 20),
            ),
            StreamBuilder(
                stream: employees.get().asStream(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Text("ChatOverviewPage: error : " +
                        snapshot.error.toString());
                  } else if (snapshot.hasData) {
                    List<Widget> children = snapshot.data!.docs.map<Widget>(
                        (DocumentSnapshot<Map<String, dynamic>> document) {
                      CollectionReference messages = FirebaseFirestore.instance
                          .collection(document.reference.path + "/messages");

                      var messagePath = document.reference.path + "/messages";

                      Employee chatEmployee =
                          new Employee(document.id, document.data()!, context);
                      if (chatEmployee.isArchived)
                        return NullWidget(); // will be removed from list
                      else
                        return createUIFromChatUser(
                            messages, messagePath, chatEmployee);
                    }).toList();
                    //remove null (archived clients) elements from list
                    children.removeWhere((element) => element is NullWidget);

                    return Container(
                      height: MediaQuery.of(context).size.height * 0.35,
                      child: ListView(
                        children: children,
                      ),
                    );
                  } else
                    return Text("Loading messages");
                }),
          ]),
        ),
      ),
    );
  }

  FutureBuilder<QuerySnapshot> createUIFromChatUser(
      CollectionReference messages, String messagePath, CleanRUser chatUser) {
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
                    return UserOverviewPage(user: chatUser);
                  }),
                );
              },
              child: Card(
                elevation: 14,
                child: createUIFromMessagesAndClientContact(
                    chatUser, context, messagesSnapshot.data!.size),
              ),
            );
          } else {
            return Text("Loading");
          }
        });
  }

  StreamBuilder<Iterable<ContactModel>> createUIFromMessagesAndClientContact(
      CleanRUser chatUser, BuildContext context, int nbMessages) {
    return StreamBuilder<Iterable<ContactModel>>(
        stream: chatUser.contactModelStream(context),
        builder: (context, userContactSnapshot) {
          if (userContactSnapshot.hasError) {
            return Text("createUIFromMessagesAndClientContact: error : " +
                userContactSnapshot.error.toString());
          } else if (userContactSnapshot.hasData) {
            ContactModel userContactModel = userContactSnapshot.data!.first;
            String firstName = userContactModel.firstNameAttribute.value;
            if (firstName.isEmpty) {
              firstName = "<No First Name>";
            }
            String lastName = userContactModel.lastNameAttribute.value;
            if (lastName.isEmpty) {
              lastName = "<No Last Name>";
            }

            String clientName = firstName +
                " " +
                lastName +
                " " +
                userContactModel.user().userID();
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
