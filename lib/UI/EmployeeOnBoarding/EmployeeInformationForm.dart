import 'package:clean_r/Model/Base/EnumAttribute.dart';
import 'package:clean_r/UI/Base/BooleanAttributeFormField.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/EnumAttributeFormField.dart';
import 'package:clean_r/UI/Base/NumericAttributeFormField.dart';
import 'package:clean_r/UI/Base/TextBasedAttributeFormField.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/Model/EmployeeContactModel_.dart';
import 'package:cleanr_employee/UI/Employee/PermitType.dart';
import 'package:cleanr_employee/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeInformationForm extends StatefulWidget {
  final Employee employee;
  final UserInfo? firebaseUser;
  final ValueNotifier<String> currentPage;

  const EmployeeInformationForm(
      {Key? key,
      required this.employee,
      required this.firebaseUser,
      required this.currentPage})
      : super(key: key);

  @override
  State<EmployeeInformationForm> createState() {
    return EmployeeInformationFormState(employee, firebaseUser, currentPage);
  }
}

class EmployeeInformationFormState extends State<EmployeeInformationForm> {
  final Employee employee;
  ValueKey? formKey;
  final UserInfo? firebaseUser;
  final ValueNotifier<String> currentPage;

  void initState() {
    super.initState();
    formKey = ValueKey(employee.employeeID);
  }

  EmployeeInformationFormState(
      this.employee, this.firebaseUser, this.currentPage);

  @override
  Widget build(BuildContext context) {
    return CleanRSkin.wrapInFrame(
        createUIFromEmployeeInformation(context, firebaseUser));
  }

  StreamBuilder<Iterable<EmployeeContactModel>> createUIFromEmployeeInformation(
      BuildContext context, UserInfo? firebaseUser) {
    return StreamBuilder(
        stream: employee.employeeContactModelStream(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> employeeInformationFields = List.empty(growable: true);
            snapshot.data!
                .forEach((EmployeeContactModel employeeInformationModel) {
              employeeInformationFields.add(
                Text(
                  AppLocalizations.of(context)
                      .translate("EmployeeContactInfos"),
                  style: CleanRSkin.pageHeaderStyle,
                  textAlign: TextAlign.justify,
                ),
              );
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.firstNameAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.lastNameAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.emailAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.zipCodeAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.phoneNumberAttribute!));
              if (employeeInformationModel.nationalityPermit == null) {
                employeeInformationModel.nationalityPermit = new EnumAttribute(
                    employeeInformationModel,
                    null,
                    NationalityPermitType("CH"));
              }
              if (employeeInformationModel.nationalityPermit!.value == null) {
                employeeInformationModel.nationalityPermit!.value =
                    NationalityPermitType("CH");
              }
              employeeInformationFields.add(EnumAttributeFormField(
                  employeeInformationModel.nationalityPermit));
              employeeInformationFields.add(BooleanAttributeFormField(
                  attribute: employeeInformationModel.ironingSkill!));
              employeeInformationFields.add(NumericAttributeFormField(
                  employeeInformationModel.minWeeklyHours!));
              employeeInformationFields.add(NumericAttributeFormField(
                  employeeInformationModel.maxWeeklyHours!));

              employeeInformationFields.add(
                ElevatedButton(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
                    child: Text(
                      AppLocalizations.of(context).translate("IApply"),
                      textScaleFactor: CleanRSkin.designRatio(context),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                          fontFamily: CleanRSkin.buttonMainFont(),
                          fontSize: 24,
                          color: CleanRSkin.buttonTextColor(context)),
                    ),
                  ),
                  onPressed: () {
                    currentPage.value = EmployeeSharingPageName;
                  },
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    )),
                    backgroundColor:
                        CleanRSkin.buttonBackgroundColorMSP(context),
                    overlayColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        if (states.contains(MaterialState.disabled))
                          return CleanRSkin.buttonBackgroundColorDisabled(
                              context);
                        else
                          return CleanRSkin.buttonBackgroundColor(
                              context); // Defer to the widget's default.
                      },
                    ),
                  ),
                ),
              );
            });
            return FocusTraversalGroup(
                child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 5.0),
              child: Material(
                  child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ListView(children: employeeInformationFields),
              )),
            ));
          } else {
            return Center(
              child: Material(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(AppLocalizations.of(context)
                      .translate("LoadingEmployeeInformation")),
                ),
              ),
            );
          }
        });
  }
}
