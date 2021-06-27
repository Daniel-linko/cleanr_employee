import 'package:clean_r/Base/Sharing.dart';
import 'package:clean_r/UI/Base/SharingButton.dart';
import 'package:clean_r/UI/Base/SharingPage.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:flutter/material.dart';

class EmployeeSharingPage extends StatelessWidget {
  final Employee employee;
  final ValueNotifier<String> currentPage;

  const EmployeeSharingPage(this.employee, this.currentPage) : super(key: null);

  Widget linkButton(
      BuildContext context, String textTag,String androidPackage,String iosPackage,String iosAppStoreID,String shareDefaultTextTag,String shareDescriptionTag) {
    return FutureBuilder<Uri>(
      future:Sharing.createDynamicLink(
          employee.userID(),
          androidPackage,
          iosPackage,
          iosAppStoreID),
      builder: (context, shortLink) { return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        child: ElevatedButton(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
            child: Text(
              AppLocalizations.of(context).translate(textTag),
              textScaleFactor: CleanRSkin.designRatio(context),
              textAlign: TextAlign.start,
              style: TextStyle(
                  fontFamily: CleanRSkin.buttonMainFont(),
                  fontSize: 24,
                  color: CleanRSkin.buttonTextColor(context)),
            ),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return SharingPage(
                shortLink: shortLink.data!,
                shareDefaultTextTag: shareDefaultTextTag,
                shareDescriptionTag: shareDescriptionTag,
              );
            }));
          },
          style: ButtonStyle(
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5.0),
            )),
            backgroundColor: CleanRSkin.buttonBackgroundColorMSP(context),
            overlayColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.disabled))
                  return CleanRSkin.buttonBackgroundColorDisabled(context);
                else
                  return CleanRSkin.buttonBackgroundColor(
                      context); // Defer to the widget's default.
              },
            ),
          ),
        ),
      );},
    );
  }

  @override
  Widget build(BuildContext context) {
    return CleanRSkin.wrapInFrame(
          ListView(children: [
            Text(AppLocalizations.of(context)
                .translate("EmployeeSharePageThanks")),
            linkButton(context, "EmployeeShareWithColleague",'com.linkonomics.cleanr_employee','com.linkonomics.cleanr-employees','??',"Employee2EmployeeShareDefaultText","Employee2EmployeeShareDescription"),
            linkButton(context, "EmployeeShareWithEmployer",'com.linkonomics.clean_r','com.linkonomics.cleanr-app','1556709592',"Employee2EmployerShareDefaultText","Employee2EmployerShareDescription"),
            linkButton(context, "EmployeeAskRecommendation",'com.linkonomics.clean_r','com.linkonomics.cleanr-app','1556709592',"EmployeeAskRecommendationDefaultText","EmployeeAskRecommendationDescription"),
          ]),
        );
  }
}
