import 'package:clean_r/Model/Employees/EmployeeRating.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:cleanr_employee/Model/Employee.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ClientRatingsOverviewPage extends StatelessWidget {
  final Employee employee;

  const ClientRatingsOverviewPage({Key? key, required this.employee})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    CollectionReference<Map<String, dynamic>> clientRatings = FirebaseFirestore
        .instance
        .collection("EmployeeRatings")
        .doc(employee.employeeID)
        .collection("ClientRatings");

    List<Widget> tiles = List<Widget>.empty(growable: true);
    return Scaffold(
      appBar: AppBar(
        title: Logo(),
        centerTitle: false,
      ),
      body: StreamBuilder(
          stream: clientRatings.get().asStream(),
          builder: (context,
              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                  allRatingsSnapshot) {
            if (allRatingsSnapshot.hasData && allRatingsSnapshot.data != null) {
              print("After allRatingsSnapshot.hasData");
              print("Number of docs:" +
                  allRatingsSnapshot.data!.docs.length.toString());
              allRatingsSnapshot.data!.docs.forEach(
                  (DocumentSnapshot<Map<String, dynamic>>
                      employeeRatingsDocument) {
                if (employeeRatingsDocument.data() != null) {
                  EmployeeRating employeeRating =
                      EmployeeRating.fromMap(employeeRatingsDocument.data()!);
                  tiles.add(
                      createClientTileFromClientRatingDocument(employeeRating));
                }
              });
              print("Tiles:" + tiles.length.toString());
              return ListView(
                children: tiles,
              );
            } else {
              return Text("Loading...");
            }
          }),
    );
  }

  Widget createClientTileFromClientRatingDocument(
      EmployeeRating employeeRating) {
    return ListTile(
      leading: Text(employeeRating.clientDisplayName.value!),
      trailing: RatingBar(
        itemSize: 20,
        initialRating: employeeRating.ratingWorkQuality!.value!,
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
    );
  }
}
