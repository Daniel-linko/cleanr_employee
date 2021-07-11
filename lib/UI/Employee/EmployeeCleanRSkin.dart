import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/ClientOnBoarding/ChatPage.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/ClientRatingsOverviewPage.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/EmployeeInformationForm.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/EmployeeSharingPage.dart';
import 'package:cleanr_employee/main.dart';
import 'package:flutter/material.dart';

import 'ChatOverviewPage.dart';

class EmployeeCleanRSkin {
  static Widget createEmployeeAppDrawer(
      BuildContext context, Employee employee) {
    return CleanRSkin.createDrawer(
        createEmployeeAppDrawerContent(context, employee));
  }

  static List<Widget> createEmployeeAppDrawerContent(
      BuildContext context, Employee employee) {
    List<DrawerItem> drawerItems =
        createEmployeeAppDrawerItems(context, employee);
    return CleanRSkin.populateDrawerContent(context, drawerItems);
  }

  static List<DrawerItem> createEmployeeAppDrawerItems(
      BuildContext context, Employee employee) {
    List<DrawerItem> drawerItems = List<DrawerItem>.empty(growable: true);
    drawerItems.add(DrawerItem(Icons.person, "PersonalInformation", () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
            appBar: AppBar(
              title: Logo(),
              centerTitle: false,
            ),
            body: EmployeeInformationForm(
                employee: employee, firebaseUser: null, currentPage: null));
      }));
    }));
    drawerItems.add(DrawerItem(Icons.star, "Client Ratings", () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ClientRatingsOverviewPage(employee: employee);
      }));
    }));
    drawerItems.add(DrawerItem(Icons.email, "Messages", () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return ChatPage(employee, employee.messagePath());
      }));
    }));
    drawerItems.add(DrawerItem(Icons.share, "Share More!", () {
      Navigator.push(context, MaterialPageRoute(builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Logo(),
            centerTitle: false,
          ),
          body: EmployeeSharingPage(employee, currentPage),
        );
      }));
    }));

    return drawerItems;
  }

  static List<Widget> createEmployeeSpecificAdditionalButtons(
      BuildContext context, CleanRUser user) {
    List<Widget> additionalButtons = List<Widget>.empty(growable: true);
    if (user.isSuperEmployee()) {
      additionalButtons.insert(
          0,
          IconButton(
            icon: Icon(Icons.message),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatOverviewPage(user: user);
              }));
            },
          ));
    }
    return additionalButtons;
  }
}
