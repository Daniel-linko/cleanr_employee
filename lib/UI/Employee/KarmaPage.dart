import 'package:clean_r/Model/Employees/EmployeeRating.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/Base/NullWidget.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/Model/EmployeeContactModel.dart';
import 'package:cleanr_employee/UI/EmployeeOnBoarding/EmployeeSharingPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:percent_indicator/percent_indicator.dart';

class KarmaPage extends StatelessWidget {
  final Employee employee;
  final ValueNotifier<String> currentPage;

  const KarmaPage({Key? key, required this.employee, required this.currentPage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> ratings = FirebaseFirestore
        .instance
        .collection(employee.employeeClientRatingsPath());
    CollectionReference<Map<String, dynamic>> clientReferralAcceptance =
        FirebaseFirestore.instance
            .collection(employee.clientReferralAcceptancePath());
    CollectionReference<Map<String, dynamic>> employeeReferralAcceptance =
        FirebaseFirestore.instance
            .collection(employee.employeeReferralAcceptancePath());
    return StreamBuilder(
      stream: employeeReferralAcceptance.get().asStream(),
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasData) {
          double nbEmployeeReferralsAccepted =
              (snapshot.data != null ? snapshot.data!.docs.length : 0)
                  .toDouble();
          return StreamBuilder<Iterable<EmployeeContactModel>>(
              stream: employee.employeeContactModelStream(context),
              builder: (context,
                  AsyncSnapshot<Iterable<EmployeeContactModel>> snapshot) {
                if (snapshot.hasData) {
                  EmployeeContactModel? contactModel;
                  if (snapshot.data != null) {
                    contactModel = snapshot.data!.first;
                  }
                  return StreamBuilder(
                    stream: clientReferralAcceptance.get().asStream(),
                    builder: (context,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.hasData) {
                        double nbClientReferralsAccepted =
                            (snapshot.data != null
                                    ? snapshot.data!.docs.length
                                    : 0)
                                .toDouble();
                        return StreamBuilder(
                            stream: ratings.get().asStream(),
                            builder: (context,
                                AsyncSnapshot<
                                        QuerySnapshot<Map<String, dynamic>>>
                                    snapshot) {
                              if (snapshot.hasData) {
                                double nbRatings = 0.0;
                                double workQualityRating = 0.0;
                                double relationshipQualityRating = 0.0;
                                if (snapshot.data != null) {
                                  nbRatings =
                                      snapshot.data!.docs.length.toDouble();
                                  Iterable<EmployeeRating> ratings =
                                      snapshot.data!.docs.map((e) =>
                                          EmployeeRating.fromMap(e.data()));
                                  ratings.forEach((element) {
                                    workQualityRating +=
                                        element.ratingWorkQuality.value;
                                    relationshipQualityRating +=
                                        element.ratingRelationshipQuality.value;
                                  });
                                  workQualityRating /= nbRatings;
                                  relationshipQualityRating /= nbRatings;
                                }

                                double karmaScore =
                                    contactModelScore(contactModel) +
                                        workQualityRating / 5.0 +
                                        relationshipQualityRating / 5.0 -
                                        normalizeInfiniteToOne(nbRatings) -
                                        normalizeInfiniteToOne(
                                            nbClientReferralsAccepted) -
                                        normalizeInfiniteToOne(
                                            nbEmployeeReferralsAccepted);

                                return ListView(children: [
                                  Text(""),
                                  ListTile(
                                      leading: Text("Karma",
                                          style: TextStyle(fontSize: 16)),
                                      trailing: CircularPercentIndicator(
                                          radius: 50.0,
                                          lineWidth: 5.0,
                                          percent: karmaScore / 7,
                                          center: Text(
                                              karmaScore.toStringAsFixed(1) +
                                                  "/7"),
                                          progressColor: Colors.green)),
                                  ListTile(
                                    leading: Text(
                                        "Employee Information Filled Out",
                                        style: TextStyle(fontSize: 16)),
                                    trailing: AbsorbPointer(
                                        child: contactModel != null &&
                                                contactModel.isComplete()
                                            ? Icon(
                                                Icons.check,
                                                color: Colors.green,
                                              )
                                            : Icon(
                                                IconData(0x2717,
                                                    fontFamily:
                                                        'MaterialIcons'),
                                                color: Colors.red)),
                                  ),
                                  ListTile(
                                    leading: Text(
                                        AppLocalizations.of(context)
                                            .translate("WorkRating"),
                                        style: TextStyle(fontSize: 16)),
                                    trailing: AbsorbPointer(
                                      child: RatingBar(
                                        itemSize: 20,
                                        initialRating: workQualityRating,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        ratingWidget: RatingWidget(
                                          full: Icon(Icons.star),
                                          half: Icon(Icons.star_half),
                                          empty: Icon(Icons.star_border),
                                        ),
                                        onRatingUpdate: (value) {},
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                    leading: Text(
                                        AppLocalizations.of(context)
                                            .translate("RelationshipRating"),
                                        style: TextStyle(fontSize: 16)),
                                    trailing: AbsorbPointer(
                                      child: RatingBar(
                                        itemSize: 20,
                                        initialRating:
                                            relationshipQualityRating,
                                        direction: Axis.horizontal,
                                        allowHalfRating: true,
                                        itemCount: 5,
                                        ratingWidget: RatingWidget(
                                          full: Icon(Icons.star),
                                          half: Icon(Icons.star_half),
                                          empty: Icon(Icons.star_border),
                                        ),
                                        onRatingUpdate: (value) {},
                                      ),
                                    ),
                                  ),
                                  ListTile(
                                      leading: Text(
                                          AppLocalizations.of(context)
                                              .translate("ClientEvaluations"),
                                          style: TextStyle(fontSize: 16)),
                                      trailing: Text(nbRatings.toString())),
                                  ListTile(
                                      leading: Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  "ClientReferralsAccepted"),
                                          style: TextStyle(fontSize: 16)),
                                      trailing: Text(nbClientReferralsAccepted
                                          .toString())),
                                  ListTile(
                                      leading: Text(
                                          AppLocalizations.of(context)
                                              .translate(
                                                  "EmployeeReferralsAccepted"),
                                          style: TextStyle(fontSize: 16)),
                                      trailing: Text(nbEmployeeReferralsAccepted
                                          .toString())),
                                  Padding(
                                    padding: const EdgeInsets.all(20.0),
                                    child: Text(
                                      AppLocalizations.of(context)
                                          .translate("HowToImproveKarma"),
                                      textAlign: TextAlign.justify,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      child: Text(
                                        AppLocalizations.of(context)
                                            .translate("Share More!"),
                                      ),
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return Scaffold(
                                            appBar: AppBar(
                                              title: Logo(),
                                              centerTitle: false,
                                              actions: [],
                                            ),
                                            body: EmployeeSharingPage(
                                                employee, null),
                                          );
                                        }));
                                      },
                                      style: CleanRSkin.buildDefaultButtonStyle(
                                          context),
                                    ),
                                  ),
                                ]);
                              } else {
                                return NullWidget();
                              }
                            });
                      } else {
                        return NullWidget();
                      }
                    },
                  );
                } else {
                  return NullWidget();
                }
              });
        } else {
          return NullWidget();
        }
      },
    );
  }

  double contactModelScore(EmployeeContactModel? contactModel) {
    return (contactModel != null && contactModel.isComplete() ? 1.0 : 0.0);
  }

  double normalizeInfiniteToOne(double nbRatings) {
    return nbRatings > 0 ? ((0.5 - nbRatings) / nbRatings) : 0;
  }
}
