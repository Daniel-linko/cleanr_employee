import 'package:clean_r/Model/Employees/EmployeeRating.dart';
import 'package:clean_r/UI/Base/NullWidget.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cleanr_employee/Model/EmployeeContactModel.dart';
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
    return StreamBuilder<Iterable<EmployeeContactModel>>(
        stream: employee.employeeContactModelStream(context),
        builder:
            (context, AsyncSnapshot<Iterable<EmployeeContactModel>> snapshot) {
          if (snapshot.hasData) {
            EmployeeContactModel? contactModel;
            if (snapshot.data != null) {
              contactModel = snapshot.data!.first;
            }
            return StreamBuilder(
                stream: ratings.get().asStream(),
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasData) {
                    double nbRatings = 0.0;
                    double workQualityRating = 0.0;
                    double relationshipQualityRating = 0.0;
                    if (snapshot.data != null) {
                      nbRatings = snapshot.data!.docs.length.toDouble();
                      Iterable<EmployeeRating> ratings = snapshot.data!.docs
                          .map((e) => EmployeeRating.fromMap(e.data()));
                      ratings.forEach((element) {
                        workQualityRating += element.ratingWorkQuality.value;
                        relationshipQualityRating +=
                            element.ratingRelationshipQuality.value;
                      });
                      workQualityRating /= nbRatings;
                      relationshipQualityRating /= nbRatings;
                    }

                    double karma =
                        (contactModel != null && contactModel.isComplete()
                                ? 1.0
                                : 0.0) +
                            workQualityRating / 5.0 +
                            relationshipQualityRating / 5.0 -
                            (0.5 - nbRatings) / nbRatings;

                    print((0.5 - nbRatings) / nbRatings);
                    print(karma);
                    return Column(children: [
                      Text(""),
                      ListTile(
                          leading:
                              Text("Karma", style: TextStyle(fontSize: 18)),
                          trailing: CircularPercentIndicator(
                              radius: 50.0,
                              lineWidth: 5.0,
                              percent: karma / 5,
                              center: Text("$karma/5"),
                              progressColor: Colors.green)),
                      ListTile(
                        leading: Text("Employee Information Filled Out",
                            style: TextStyle(fontSize: 18)),
                        trailing: AbsorbPointer(
                            child: contactModel != null &&
                                    contactModel.isComplete()
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    IconData(0x2717,
                                        fontFamily: 'MaterialIcons'),
                                    color: Colors.red)),
                      ),
                      ListTile(
                        leading:
                            Text("Work Rating", style: TextStyle(fontSize: 18)),
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
                        leading: Text("Relationship Rating",
                            style: TextStyle(fontSize: 18)),
                        trailing: AbsorbPointer(
                          child: RatingBar(
                            itemSize: 20,
                            initialRating: relationshipQualityRating,
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
                          leading: Text("Client evaluations",
                              style: TextStyle(fontSize: 18)),
                          trailing: Text(nbRatings.toString()))
                    ]);
                  } else
                    return Text("");
                });
          } else {
            return NullWidget();
          }
        });
  }
}
