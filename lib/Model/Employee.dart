import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/Base/DataChangeObserver.dart';
import 'package:clean_r/Model/Base/ContactModel.dart';
import 'package:clean_r/Model/Base/ModelObject.dart';
import 'package:clean_r/Model/HomeDescription/HomeModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat/dash_chat.dart';
import 'package:flutter/cupertino.dart';

import 'EmployeeContactModel.dart';

class Employee extends ModelObject implements DataChangeObserver, CleanRUser {
  // field names
  static const String _employeeInformationModelCollectionField =
      'EmployeeInformationInfos';
  static const String _messagesCollectionField = 'messages';
  static const String isArchivedDBField = 'isArchived';
  static const String _isSuperEmployeeDBField = 'isSuperEmployee';

  //Fields
  final String employeeID;
  EmployeeContactModel? employeeInformationModel;
  bool isArchived = false;
  bool _isSuperEmployee = false;

  String messagesCollectionPath() {
    return path() + '/' + _messagesCollectionField;
  }

  String employeeInformationModelCollectionPath() {
    return path() + '/' + _employeeInformationModelCollectionField;
  }

  Employee(this.employeeID, Map<String, dynamic> map, BuildContext context)
      : super.fromMap(map) {
    if (map[isArchivedDBField] == null) {
      isArchived = false;
    } else {
      isArchived = map[isArchivedDBField];
    }
    if (map[_isSuperEmployeeDBField] == null) {
      _isSuperEmployee = false;
    } else {
      _isSuperEmployee = map[_isSuperEmployeeDBField];
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
    DocumentReference employeeInformationDocumentReference =
        FirebaseFirestore.instance.doc(path());
    employeeInformationDocumentReference
        .set({Employee.isArchivedDBField: false}, SetOptions(merge: true));
  }

  @override
  void notifyDataChange() {
    if (employeeInformationModel != null) {
      CollectionReference employeeInformationModelCollectionReference =
          FirebaseFirestore.instance
              .collection(employeeInformationModelCollectionPath());
      DocumentReference employeeInformationReference =
          employeeInformationModelCollectionReference.doc("1");
      employeeInformationReference.set(
          employeeInformationModel!.toMap(), SetOptions(merge: true));
    }
  }

  @override
  String path() {
    return "Employees/" + employeeID;
  }

  Stream<Iterable<EmployeeContactModel>> employeeContactModelStream(
      BuildContext context) {
    CollectionReference amployeeInformationModelCollectionReference =
        FirebaseFirestore.instance
            .collection(employeeInformationModelCollectionPath());
    Stream<QuerySnapshot> collectionStream =
        amployeeInformationModelCollectionReference.snapshots();
    Stream<List<DocumentSnapshot>> documents =
        collectionStream.map((event) => event.docs);

    return documents.map((event) => event.map((e) {
          employeeInformationModel = EmployeeContactModel.fromMap(
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
  Stream<Iterable<ContactModel>> contactModelStream(BuildContext context) {
    return employeeContactModelStream(context);
  }

  @override
  Stream<Iterable<HomeModel>> homeModelStream(BuildContext context) {
    throw UnimplementedError(); // TODO : refactor to remove this weird dependency
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

  @override
  bool isSuperEmployee() {
    return _isSuperEmployee;
  }

  String employeeClientRatingsPath() {
    return "EmployeeRatings/$employeeID/ClientRatings";
  }
}
