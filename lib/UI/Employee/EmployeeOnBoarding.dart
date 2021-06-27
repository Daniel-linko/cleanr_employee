import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/ClientOnBoarding/WelcomePage.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/EmployeeInformationForm.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmployeeOnBoarding extends StatefulWidget {
  final String employeeID;
  final String currentPage;
  final UserInfo? firebaseUser;


  const EmployeeOnBoarding(this.employeeID, this.currentPage, this.firebaseUser)
      : super(key: null);

  @override
  _EmployeeOnBoardingState createState() =>
      new _EmployeeOnBoardingState(employeeID, currentPage, firebaseUser);
}

class _EmployeeOnBoardingState extends State<EmployeeOnBoarding> {
  final String employeeID;
  final UserInfo? firebaseUser;
  ValueNotifier<String> firstRun = new ValueNotifier<String>("WelcomePage");

  int choice = 0;
  bool complete = false;

  initState() {
    super.initState();
    complete = false;
  }

  _EmployeeOnBoardingState(this.employeeID, String currentPage, this.firebaseUser) {
    this.firstRun.value = currentPage;
  }

  @override
  Widget build(BuildContext context) {
    return buildFirestormStream(employeeID, context);
  }

  StreamBuilder<Employee> buildFirestormStream(
      String employeeID, BuildContext context) {
    var employeeCollection = FirebaseFirestore.instance.collection('Employees');
    employeeCollection
        .doc(employeeID.toString())
        .set({'Employee ID': employeeID}, SetOptions(merge: true));

    return StreamBuilder<Employee>(
        key: ValueKey(employeeID),
        stream: FirebaseFirestore.instance
            .doc("Employees/" + employeeID)
            .snapshots()
            .map((d) => Employee(employeeID, d.data()!, context)),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return Center(
              child: Text(
                snapshot.error.toString(),
                textScaleFactor: 1.5,
              ),
            );

          if (!snapshot.hasData)
            return Center(
              child: Text(
                AppLocalizations.of(context).translate("RemoteLoading"),
                textScaleFactor: 1.5,
              ),
            );

          return GestureDetector(
              child: ValueListenableBuilder(
                  valueListenable: firstRun,
                  builder: (context, String currentPage, child) {
                    if (currentPage=="WelcomePage") {
                      return WelcomePage(snapshot.data!, firstRun,"EmployeeInformationPage", false,
                          "https://cleanr.ai/welcome_employees");
                    } else
                      return Scaffold(
                        key: ValueKey(employeeID),
                        appBar: AppBar(
                            title: Logo(),
                            centerTitle: false,
                            actions: CleanRSkin.createAppBarActions(
                                context, snapshot.data!, false, "https://cleanr.ai/welcome_employees")),
                        body: EmployeeInformationForm(
                          employee: snapshot.data!,
                          firebaseUser: firebaseUser,
                        ),
                      );
                  }),
              onTap: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              });
        });
  }
}
