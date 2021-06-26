import 'package:clean_r/Model/Base/EnumAttribute.dart';
import 'package:clean_r/UI/Base/BooleanAttributeFormField.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/EnumAttributeFormField.dart';
import 'package:clean_r/UI/Base/NumericAttributeFormField.dart';
import 'package:clean_r/UI/Base/TextBasedAttributeFormField.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/Model/EmployeeInformationModel.dart';
import 'package:cleanr_employee/UI/Employee/PermitType.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmployeeInformationForm extends StatefulWidget {
  final Employee employee;
  final UserInfo? firebaseUser;

  const EmployeeInformationForm(
      {Key? key, required this.employee, required this.firebaseUser})
      : super(key: key);

  @override
  State<EmployeeInformationForm> createState() {
    return EmployeeInformationFormState(employee, firebaseUser);
  }
}

class EmployeeInformationFormState extends State<EmployeeInformationForm> {
  final Employee employee;
  ValueKey? formKey;
  final UserInfo? firebaseUser;

  void initState() {
    super.initState();
    formKey = ValueKey(employee.employeeID);
  }

  EmployeeInformationFormState(this.employee, this.firebaseUser);

  @override
  Widget build(BuildContext context) {
    return CleanRSkin.wrapInFrame(
        createUIFromEmployeeInformation(context, firebaseUser));
  }

  StreamBuilder<Iterable<EmployeeInformationModel>>
      createUIFromEmployeeInformation(
          BuildContext context, UserInfo? firebaseUser) {
    return StreamBuilder(
        stream: employee.employeeInformationModelStream(context),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<Widget> employeeInformationFields = List.empty(growable: true);
            snapshot.data!
                .forEach((EmployeeInformationModel employeeInformationModel) {
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.firstNameAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.lastNameAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.emailAttribute!));
              employeeInformationFields.add(TextBasedAttributeFormField(
                  employeeInformationModel.zipCodeAttribute!));
              employeeInformationFields.add(BooleanAttributeFormField(
                  attribute: employeeInformationModel.ironingSkill!));
              employeeInformationFields.add(NumericAttributeFormField(
                  employeeInformationModel.minWeeklyHours!));
              employeeInformationFields.add(NumericAttributeFormField(
                  employeeInformationModel.maxWeeklyHours!));
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
