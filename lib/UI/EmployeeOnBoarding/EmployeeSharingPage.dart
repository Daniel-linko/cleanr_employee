import 'package:clean_r/Base/Sharing.dart';
import 'package:clean_r/UI/Base/SharingPage.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:flutter/cupertino.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:flutter/material.dart';

class EmployeeSharingPage extends StatelessWidget {
  final Employee employee;
  final ValueNotifier<String> currentPage;

  const EmployeeSharingPage(this.employee, this.currentPage) : super(key: null);

  Widget linkButton(
      BuildContext context, String textTag,String androidPackage,String iosPackage,String iosAppStoreID,String shareDefaultTextTag, String shareDefaultSubjectTag,String shareDescriptionTag, String linkType) {
    String displayName="Undefined";
    if(employee.employeeInformationModel?.firstNameAttribute?.value!=null)
      displayName=employee.employeeInformationModel?.firstNameAttribute?.value??"Undefined";
    if(employee.employeeInformationModel?.lastNameAttribute?.value!=null)
      displayName=displayName+" " +(employee.employeeInformationModel?.lastNameAttribute?.value??"");

    return FutureBuilder<Uri>(
      future:Sharing.createDynamicLink(
          employee.userID(),
          androidPackage,
          iosPackage,
          iosAppStoreID,linkType,displayName),
      builder: (context, shortLink) {
        //if (shortLink.hasData) {
        return Padding(
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
                shareDefaultSubjectTag: shareDefaultSubjectTag,
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
      );/*} else {
          return Center(
            child: Material(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(AppLocalizations.of(context)
                    .translate("LoadingEmployeeSharing")),
              ),
            ),
          );
        }*/
        },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CleanRSkin.wrapInFrame(
          ListView(children: [
            Text(AppLocalizations.of(context)
                .translate("EmployeeSharePageThanks"),style: CleanRSkin.pageHeaderStyle,
                textAlign: TextAlign.justify),
            linkButton(context, "EmployeeShareWithColleague",'com.linkonomics.clean_r_employee','com.linkonomics.cleanrEmployees','1574085365',"Employee2EmployeeShareDefaultText","Employee2EmployeeShareDefaultSubject","Employee2EmployeeShareDescription","referral"),
            linkButton(context, "EmployeeShareWithEmployer",'com.linkonomics.clean_r','com.linkonomics.cleanr-app','1556709592',"Employee2EmployerShareDefaultText","Employee2EmployerShareDefaultSubject","Employee2EmployerShareDescription","referral"),
            linkButton(context, "EmployeeAskRecommendation",'com.linkonomics.clean_r','com.linkonomics.cleanr-app','1556709592',"EmployeeAskRecommendationDefaultText","EmployeeAskRecommendationDefaultSubject","EmployeeAskRecommendationDescription","recommendation"),
          ]),
        );
  }
}
