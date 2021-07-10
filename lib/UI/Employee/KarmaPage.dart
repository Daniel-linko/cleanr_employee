import 'package:cleanr_employee/Model/Employee.dart';
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
    return Column(children: [
      ListTile(
          leading: Text("Karma"),
          trailing: CircularPercentIndicator(
              radius: 50.0,
              lineWidth: 5.0,
              percent: .3,
              center: Text("2/6"),
              progressColor: Colors.green)),
      ListTile(
        leading: Text("Work Rating"),
        trailing: RatingBar(
          itemSize: 20,
          initialRating: 3.5,
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
      ListTile(
        leading: Text("Relationship Rating"),
        trailing: RatingBar(
          itemSize: 20,
          initialRating: 3.0,
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
      ListTile(leading:Text("Client evaluations"),trailing:Text("12"))
    ]);
  }
}

/*
SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height*0.5,
        child: Stepper(
              currentStep: 1,
          type: StepperType.horizontal,
             steps: [Step(title:Text("Registered"),content: Text("Some Stats"),state: StepState.complete),
               Step(title:Text("Recommended"),content: Text("Some Stats"),state: StepState.editing),
              Step(title:Text("Hired"),content: Text("Some Stats"),state:StepState.editing)],
          controlsBuilder: (BuildContext context,
              {VoidCallback ?onStepContinue, VoidCallback ?onStepCancel}) =>
              Container(),
            ),
 */
