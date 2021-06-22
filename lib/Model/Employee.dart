import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/Base/DataChangeObserver.dart';
import 'package:clean_r/Model/Base/ModelObject.dart';
import 'package:clean_r/Model/ClientContactModel.dart';
import 'package:clean_r/Model/HomeDescription/HomeModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';

import 'EmployeeInformationModel.dart';

class Employee extends ModelObject implements DataChangeObserver, CleanRUser {
  // field names
  static const String _employeeInformationModelCollectionField =
      'EmployeeInformationInfos';
  static const String _messagesCollectionField = 'messages';
  static const String isArchivedField = 'isArchived';

  //Fields
  final String employeeID;
  EmployeeInformationModel? employeeInformationModel;
  bool isArchived = false;

  String messagesCollectionPath() {
    return path() + '/' + _messagesCollectionField;
  }

  String employeeInformationModelCollectionPath() {
    return path() + '/' + _employeeInformationModelCollectionField;
  }

  Employee(this.employeeID, Map<String, dynamic> map, BuildContext context)
      : super.fromMap(map) {
    if (map[isArchivedField] == null) {
      isArchived = false;
    } else {
      isArchived = map[isArchivedField];
    }

    CollectionReference employeeInformationModelCollectionReference =
        FirebaseFirestore.instance
            .collection(employeeInformationModelCollectionPath());
    DocumentReference clientContactModelReference =
        employeeInformationModelCollectionReference.doc("1");
    clientContactModelReference
        .set({"Access Timestamp": timestamp}, SetOptions(merge: true));
  }

  @override
  void addToMap(Map<String, dynamic> map) {
    // TODO: implement addToMap
  }

  void unarchive() {
    DocumentReference clientDocumentReference =
        FirebaseFirestore.instance.doc(path());
    clientDocumentReference
        .set({Employee.isArchivedField: false}, SetOptions(merge: true));
  }

  @override
  void notifyDataChange() {
    if (employeeInformationModel != null) {
      CollectionReference employeeInformationModelCollectionReference =
          FirebaseFirestore.instance
              .collection(employeeInformationModelCollectionPath());
      DocumentReference clientContactReference =
          employeeInformationModelCollectionReference.doc("1");
      clientContactReference.set(
          employeeInformationModel!.toMap(), SetOptions(merge: true));
    }
  }

  @override
  String path() {
    return "Employees/" + employeeID;
  }

  Stream<Iterable<EmployeeInformationModel>> employeeInformationModelStream(
      BuildContext context) {
    CollectionReference clientContactModelCollectionReference =
        FirebaseFirestore.instance
            .collection(employeeInformationModelCollectionPath());
    Stream<QuerySnapshot> collectionStream =
        clientContactModelCollectionReference.snapshots();
    Stream<List<DocumentSnapshot>> documents =
        collectionStream.map((event) => event.docs);

    return documents.map((event) => event.map((e) {
          employeeInformationModel = EmployeeInformationModel.fromMap(
              this, e.data() as Map<String, dynamic>);
          return employeeInformationModel!;
        }));
  }

  void sendMessageToCompany(String message) {
    String messageStoragePath = messagesCollectionPath();
    ChatUser user = ChatUser(uid: employeeID, avatar: avatar());

    var messageDocumentReference = FirebaseFirestore.instance
        .collection(messageStoragePath)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        messageDocumentReference,
        ChatMessage(text: message, createdAt: DateTime.now(), user: user)
            .toJson(),
      );
    });
  }

  void sendMessageToClient(String message) {
    String messageStoragePath = messagesCollectionPath();
    ChatUser user = ChatUser(uid: "clean'r", avatar: avatar());

    var messageDocumentReference = FirebaseFirestore.instance
        .collection(messageStoragePath)
        .doc(DateTime.now().millisecondsSinceEpoch.toString());

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        messageDocumentReference,
        ChatMessage(text: message, createdAt: DateTime.now(), user: user)
            .toJson(),
      );
    });
  }

  @override
  Stream<Iterable<ClientContactModel>> clientContactModelStream(
      BuildContext context) {
    // TODO: implement clientContactModelStream
    throw UnimplementedError();
  }

  @override
  Stream<Iterable<HomeModel>> homeModelStream(BuildContext context) {
    // TODO: implement homeModelStream
    throw UnimplementedError();
  }

  @override
  String messagePath() {
    return "Employees/" + userID() + "/messages";
  }

  @override
  String? avatar() {
    return null;
  }

  @override
  bool isEmployee() {
    return true;
  }

  @override
  String userID() {
    return employeeID;
  }
}
