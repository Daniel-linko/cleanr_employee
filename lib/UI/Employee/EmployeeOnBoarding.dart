import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/Base/NullWidget.dart';
import 'package:clean_r/UI/ClientOnBoarding/WelcomePage.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/UI/Employee/EmployeeCleanRSkin.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/EmployeeInformationForm.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/EmployeeSharingPage.dart';
import 'package:cleanr_employee/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmployeeOnBoarding extends StatefulWidget {
  final ValueNotifier<String> currentPage;
  final String employeeID;
  final String currentPageName;
  final UserInfo? firebaseUser;

  const EmployeeOnBoarding(this.employeeID, this.currentPageName, this.firebaseUser, this.currentPage)
      : super(key: null);

  @override
  _EmployeeOnBoardingState createState() =>
      new _EmployeeOnBoardingState(employeeID, currentPageName, firebaseUser, currentPage);
}

class _EmployeeOnBoardingState extends State<EmployeeOnBoarding> {
  final ValueNotifier<String> currentPage;
  final String employeeID;
  final UserInfo? firebaseUser;

  int choice = 0;
  bool complete = false;

  initState() {
    super.initState();
    complete = false;
  }

  _EmployeeOnBoardingState(this.employeeID, String cp, this.firebaseUser, this.currentPage) {
    this.currentPage.value = cp;
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
          Employee employee = snapshot.data!;

          return GestureDetector(
              child: ValueListenableBuilder(
                  valueListenable: currentPage,
                  builder: (context, String cp, child) {
                    switch(cp) {
                      case WelcomePageName :
                        {
                          return WelcomePage(
                              snapshot.data!,
                              currentPage,
                              EmployeeInformationPageName,
                              false,
                              "https://cleanr.ai/welcome_employees");
                        }
                      case EmployeeInformationPageName:
                        return Scaffold(
                          key: ValueKey(employeeID),
                          drawer: EmployeeCleanRSkin.createEmployeeAppDrawer(
                              context, employee),
                          appBar: AppBar(
                              title: Logo(),
                              centerTitle: false,
                              actions: CleanRSkin.createAppBarActions(
                                  context,
                                  employee,
                                  false,
                                  "https://cleanr.ai/welcome_employees")),
                          body: EmployeeInformationForm(
                            employee: employee,
                            firebaseUser: firebaseUser,
                            currentPage: currentPage,
                          ),
                        );
                      case EmployeeSharingPageName :
                        return Scaffold(
                          key: ValueKey(employeeID),
                          appBar: AppBar(
                              title: Logo(),
                              centerTitle: false,
                              actions: CleanRSkin.createAppBarActions(
                                  context,
                                  snapshot.data!,
                                  false,
                                  "https://cleanr.ai/welcome_employees")),
                          body: EmployeeSharingPage(
                              snapshot.data!, currentPage),
                        );
                      default :
                        assert(false);
                        return NullWidget();
                    }
                  }),
              onTap: () {
                SystemChannels.textInput.invokeMethod('TextInput.hide');
              });
        });
  }
}
