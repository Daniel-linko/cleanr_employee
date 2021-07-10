import 'package:clean_r/Base/CleanRUser.dart';
import 'package:clean_r/Model/Base/ContactModel.dart';
import 'package:clean_r/Model/Client.dart';
import 'package:clean_r/Model/HomeDescription/HomeModel.dart';
import 'package:clean_r/Model/HomeDescription/LaundryModel.dart';
import 'package:clean_r/Model/HomeDescription/RoomType.dart';
import 'package:clean_r/Model/Interactions/OfferModel.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/UI/Base/Logo.dart';
import 'package:clean_r/UI/Base/NullWidget.dart';
import 'package:clean_r/UI/ClientOnBoarding/ChatPage.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserOverviewPage extends StatelessWidget {
  final CleanRUser user;

  const UserOverviewPage({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Logo(),
        centerTitle: true,
      ),
      body: //CleanRSkin.wrapInFrame(
          Padding(
        padding:
            const EdgeInsets.only(left: 12.0, right: 12, top: 8.0, bottom: 8.0),
        child: ClientOverviewBox(user),
      ),
    );
  }
}

class ClientOverviewBox extends StatefulWidget {
  final CleanRUser user;

  ClientOverviewBox(this.user);

  @override
  _ClientOverviewBoxState createState() => _ClientOverviewBoxState(user);
}

class _ClientOverviewBoxState extends State<ClientOverviewBox> {
  final CleanRUser user;

  _ClientOverviewBoxState(this.user);

  @override
  Widget build(BuildContext context) {
    Client? client;
    if (!user.isEmployee()) {
      client = user as Client;
    }
    return Material(
      elevation: 14,
      borderRadius: BorderRadius.circular(5.0),
      child: ListView(children: [
        Padding(
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
          child: Center(
            child: Text(
              translate("UserSummary"),
              textScaleFactor: 2.5,
            ),
          ),
        ),
        StreamBuilder<Iterable<ContactModel>>(
            stream: user.contactModelStream(context),
            builder: (context, AsyncSnapshot<Iterable<ContactModel>> snapshot) {
              List<Widget> wList = List<Widget>.empty(growable: true);
              wList.add(labelValueRow("Id", user.userID()));
              if (snapshot.hasError) {
                wList.add(Text("Error:" + snapshot.error.toString()));
              } else if (snapshot.hasData) {
                ContactModel contactModel = snapshot.data!.first;
                wList.add(labelValueRow(
                    contactModel.firstNameAttribute!.labelTag(),
                    contactModel.firstNameAttribute!.value == null
                        ? "N/A"
                        : contactModel.firstNameAttribute!.value!));
                wList.add(labelValueRow(
                    contactModel.lastNameAttribute!.labelTag(),
                    contactModel.lastNameAttribute!.value == null
                        ? "N/A"
                        : contactModel.lastNameAttribute!.value!));
                wList.add(labelValueRow(
                    contactModel.phoneNumberAttribute!.labelTag(),
                    contactModel.phoneNumberAttribute!.value == null
                        ? "N/A"
                        : contactModel.phoneNumberAttribute!.value!));
                wList.add(labelValueRow(
                    contactModel.emailAttribute!.labelTag(),
                    contactModel.emailAttribute!.value == null
                        ? "N/A"
                        : contactModel.emailAttribute!.value!));

                wList.add(labelValueRow(
                    "IsEmployee", translate(user.isEmployee() ? "Yes" : "No")));
              }
              return Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                child: Column(children: wList),
              );
            }),
        user.isEmployee()
            ? NullWidget()
            : StreamBuilder<Iterable<HomeModel>>(
                stream: user.homeModelStream(context),
                builder:
                    (context, AsyncSnapshot<Iterable<HomeModel>> snapshot) {
                  List<Widget> wList = List<Widget>.empty(growable: true);
                  if (snapshot.hasError) {
                    wList.add(Text("Error:" + snapshot.error.toString()));
                  } else if (snapshot.hasData) {
                    HomeModel homeModel = snapshot.data!.first;

                    if (client != null) {
                      wList.add(labelValueRow(
                          "OfferAccepted",
                          translate(client.homeModel!.offerIsAccepted
                              ? "Yes"
                              : "No")));

                      //prepare formats for date and time
                      DateFormat dateFormatTime =
                          DateFormat(DateFormat.HOUR_MINUTE);
                      DateFormat dateFormatDate = DateFormat.yMd(
                          AppLocalizations.of(context).locale.toLanguageTag());
                      //clean date of milliseconds if displaying seconds in time format
                      DateTime? cleanTime = client
                                  .homeModel!.offerAcceptedDate ==
                              null
                          ? null
                          : client.homeModel!.offerAcceptedDate!
                              .toDate(); //Timestamp.fromMillisecondsSinceEpoch((widget.client.homeModel.offerAcceptedDate.millisecondsSinceEpoch/1000).round()*1000).toDate();
                      wList.add(labelValueRow(
                          "OfferAcceptDate",
                          client.homeModel!.offerAcceptedDate != null
                              ? dateFormatDate.format(cleanTime!) +
                                  ' ' +
                                  dateFormatTime.format(cleanTime)
                              : "N/A"));
                      wList.add(StreamBuilder<Iterable<OfferModel>>(
                          stream: client.offerModelStream(context),
                          builder: (context, snapshot) {
                            List<Widget> wList =
                                List<Widget>.empty(growable: true);
                            if (snapshot.hasError) {
                              wList.add(
                                  Text("Error:" + snapshot.error.toString()));
                            } else if (snapshot.hasData) {
                              OfferModel? offerModel;
                              if (snapshot.data!.length > 0)
                                offerModel = snapshot.data!.last;
                              if (offerModel != null) {
                                wList.add(labelValueRow("CleaningPrice",
                                    offerModel.cleaningPrice.toString()));
                                wList.add(labelValueRow("LaundryPrice",
                                    offerModel.laundryPrice.toString()));
                              }
                            }
                            return Column(children: wList);
                          }));
                    }

                    wList.add(Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        translate("Rooms"),
                        textScaleFactor: 1.5,
                      ),
                    ));
                    homeModel.roomList!.forEach((room) {
                      if (room.roomType() is BathroomType) {
                        wList.add(Align(
                            alignment: Alignment.centerLeft,
                            child: Text(translate(room.roomTag()) + ": ")));
                        room.equipmentList!.forEach((equipment) {
                          wList.add(Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(translate(equipment.name()) +
                                    ":" +
                                    equipment.countIndication())),
                          ));
                        });
                      } else {
                        wList.add(Align(
                            alignment: Alignment.centerLeft,
                            child: Text(translate(room.roomTag()) +
                                ":" +
                                room.count().toString())));
                      }
                    });
                  }
                  return Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Column(children: wList),
                  );
                },
              ),
        user.isEmployee()
            ? NullWidget()
            : StreamBuilder<Iterable<LaundryModel>>(
                stream: client!.laundryModelStream(context),
                builder: (context, snapshot) {
                  List<Widget> wList = List<Widget>.empty(growable: true);
                  if (snapshot.hasError) {
                    wList.add(Text("Error:" + snapshot.error.toString()));
                  } else if (snapshot.hasData) {
                    LaundryModel laundryModel = snapshot.data!.first;
                    wList.add(Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        translate("Laundry"),
                        textScaleFactor: 1.5,
                      ),
                    ));

                    wList.add(labelValueRow(
                        laundryModel.shirtCount!.labelTag(),
                        laundryModel.shirtCount!.value == null
                            ? "N/A"
                            : laundryModel.shirtCount!.value!
                                .toInt()
                                .toString()));
                    wList.add(labelValueRow(
                        laundryModel.pantsSkirtsCount!.labelTag(),
                        laundryModel.pantsSkirtsCount!.value == null
                            ? "N/A"
                            : laundryModel.pantsSkirtsCount!.value!
                                .toInt()
                                .toString()));
                    wList.add(labelValueRow(
                        laundryModel.jacketCount!.labelTag(),
                        laundryModel.jacketCount!.value == null
                            ? "N/A"
                            : laundryModel.jacketCount!.value!
                                .toInt()
                                .toString()));
                    wList.add(labelValueRow(
                        laundryModel.ironedWeight!.labelTag(),
                        laundryModel.ironedWeight!.value == null
                            ? "N/A"
                            : laundryModel.ironedWeight!.value.toString()));
                    wList.add(labelValueRow(
                        laundryModel.nonIronedWeight!.labelTag(),
                        laundryModel.nonIronedWeight!.value == null
                            ? "N/A"
                            : laundryModel.nonIronedWeight!.value.toString()));
                    wList.add(Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                CleanRSkin.buttonTextColorMSP(context),
                            backgroundColor:
                                CleanRSkin.buttonBackgroundColorMSP(context),
                            shape: MaterialStateProperty.all(StadiumBorder())),
                        child: Text(translate("ChatWithClient")),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              return ChatPage(user, user.messagePath());
                            }),
                          );
                        },
                      ),
                    ));
                    wList.add(Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: ElevatedButton(
                        style: ButtonStyle(
                            foregroundColor:
                                CleanRSkin.buttonTextColorMSP(context),
                            backgroundColor:
                                CleanRSkin.buttonBackgroundColorMSP(context),
                            shape: MaterialStateProperty.all(StadiumBorder())),
                        child: Text(translate("ArchiveClient")),
                        onPressed: () {
                          DocumentReference documentReference =
                              FirebaseFirestore.instance.doc(user.path());
                          documentReference.set(
                              {"isArchived": true}, SetOptions(merge: true));

                          Navigator.pop(context);
                        },
                      ),
                    ));
                  }

                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0),
                    child: Column(children: wList),
                  );
                }),
      ]),
    );
  }

  String translate(String stringToTranslate) {
    String translatedString =
        AppLocalizations.of(context).translate(stringToTranslate);
    if (translatedString.startsWith("Translation missing for key"))
      translatedString = stringToTranslate;
    return translatedString;
  }

  Widget labelValueRow(String labelToTranslate, String value) {
    String translatedLabel =
        AppLocalizations.of(context).translate(labelToTranslate);
    if (translatedLabel.startsWith("Translation missing for key"))
      translatedLabel = labelToTranslate;
    return Row(children: [Text(translatedLabel + ": "), Text(value)]);
  }
}
