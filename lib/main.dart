import 'package:clean_r/Expressions/Price%20Calculator/ServicePriceCalculator.dart';
import 'package:clean_r/UI/Base/CleanRSkin.dart';
import 'package:clean_r/localization/AppLocalization.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'UI/Employee/EmployeeOnBoarding.dart';

String? deviceToken;
String? firebaseID;
String? oldEmployeeID;
const String WelcomePageName = "WelcomePage";
const String EmployeeInformationPageName = "EmployeeInformationPage";
const String EmployeeSharingPageName = "EmployeeSharingPage";
const String EmployeeKarmaPageName = "EmployeeKarmaPage";
String currentPageName = WelcomePageName;
ValueNotifier<String> currentPage = new ValueNotifier<String>(WelcomePageName);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          // ... app-specific localization delegate[s] here
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          AppLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en', ''), // English, no country code
          const Locale('fr', ''), // French, no country code
          // ... other locales the app supports
        ],
        title: CleanRSkin.appName,
        theme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          brightness: Brightness.light,
          primarySwatch: Colors.lightBlue,
          primaryColor: Colors.white,
          scaffoldBackgroundColor: Colors.white,
          fontFamily: "SF UI Display Regular",
          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        darkTheme: ThemeData(
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          brightness: Brightness.dark,
          accentColor: Colors.blueGrey.shade500,
          primarySwatch: Colors.blueGrey,
          primaryColor: Colors.black,
          scaffoldBackgroundColor: Colors.black,
          fontFamily: "SF UI Display Regular",

          // This makes the visual density adapt to the platform that you run
          // the app on. For desktop platforms, the controls will be smaller and
          // closer together (more dense) than on mobile platforms.
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: Material(
          child: MyHomePage(title: CleanRSkin.appName),
        ));
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  //static final facebookAppEvents = FacebookAppEvents();

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  void initDynamicLinks(String employeeID) async {
    FirebaseDynamicLinks.instance.onLink(
        onSuccess: (PendingDynamicLinkData? dynamicLink) async {
      final Uri? deepLink = dynamicLink?.link;

      if (deepLink != null) {
        print("onLink dynamic link : $deepLink");
        Map<String, String> queryParameters = deepLink.queryParameters;
        queryParameters.forEach((key, value) {
          print("--- key : $key, value : $value");
        });
        storeReferralID(deepLink, employeeID);
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    //MyHomePage.facebookAppEvents.logActivatedApp();
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.

    return FutureBuilder(
      future: Firebase.initializeApp(),
      builder: (context, fireBaseAppSnapshot) {
        if (fireBaseAppSnapshot.hasData) {
          return FutureBuilder<ServicePriceCalculator?>(
              future: ServicePriceCalculator.create(),
              builder: (context, spc) {
                if (spc.hasError) {
                  return Text("SPC Error");
                } else if (spc.connectionState == ConnectionState.done) {
                  return FutureBuilder(
                    future: FirebaseMessaging.instance.requestPermission(
                        sound: true,
                        badge: true,
                        alert: true,
                        provisional: true),
                    builder: (context, settingsSnapshot) {
                      if (settingsSnapshot.hasData) {
                        var settings = settingsSnapshot.data;
                        print("Settings registered: $settings");

                        FirebaseMessaging.instance
                            .getToken()
                            .then((String? token) {
                          assert(token != null);
                          print("Push Messaging token: $token");
                          deviceToken = token!;
                        });

                        return loginAndContinue();
                      } else if (settingsSnapshot.hasError) {
                        return Text("Error requesting messaging permissions");
                      } else {
                        return Text("Requesting messaging permissions");
                      }
                    },
                  );
                } else if (fireBaseAppSnapshot.hasError) {
                  return Text("Error : Firebase.initializeApp() " +
                      fireBaseAppSnapshot.error.toString());
                } else {
                  return Text("Initializing Firebase Application");
                }
              });
        } else
          return Text("");
      },
    );
  }

  Widget loginAndContinue() {
    if (FirebaseAuth.instance.currentUser == null) {
      return FutureBuilder<UserCredential?>(
          future: FirebaseAuth.instance.signInAnonymously(),
          builder: (context, userCredentialSnapshot) {
            if (userCredentialSnapshot.hasError) {
              return Text("Error in signInAnonymously ");
            } else if (!userCredentialSnapshot.hasData) {
              return Text("Loading signInAnonymously Data");
            } else {
              UserCredential userCredential = userCredentialSnapshot.data!;
              firebaseID = userCredential.user!.uid;
              print("got new Anonymous Firebase ID:" + firebaseID!);
              return initializeAuthenticationAndDynamicLinkAndContinue(
                  firebaseID!);
            }
          });
    } else {
      firebaseID = FirebaseAuth.instance.currentUser!.uid;
      print("retrieved employee ID:" + firebaseID!);
      currentPageName = EmployeeKarmaPageName;
      return initializeAuthenticationAndDynamicLinkAndContinue(firebaseID!);
    }
  }

  StreamBuilder<User?> initializeAuthenticationAndDynamicLinkAndContinue(
      String employeeID) {
    this.initDynamicLinks(employeeID);
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, firebaseUserSnapshot) {
          const employeeIDKey = 'employeeID';
          if (firebaseUserSnapshot.connectionState == ConnectionState.waiting) {
            return Text(AppLocalizations.of(context)
                .translate("WaitingOnAuthentication"));
          } else if (firebaseUserSnapshot.hasError) {
            return Text(firebaseUserSnapshot.error.toString());
          } else if (firebaseUserSnapshot.hasData) {
            var firebaseUser = firebaseUserSnapshot.data;
            firebaseID = firebaseUser!.uid;
            List<UserInfo> providerData = firebaseUser.providerData;

            UserInfo? firstInfo;
            if (providerData.isNotEmpty) {
              firstInfo = providerData.first;
            }

            DocumentReference ref =
                FirebaseFirestore.instance.doc("Employees/" + firebaseUser.uid);
            ref.set({'tokenID': deviceToken}, SetOptions(merge: true));
            String employeeID = firebaseUser.uid;
            print("+++++++++++++++ employeeID: " + employeeID);
            Future<SharedPreferences> localSnapshot =
                SharedPreferences.getInstance();
            localSnapshot.then((sn) {
              sn.setString(employeeIDKey, firebaseID!);
            });
            return Material(
                key: ValueKey(employeeID),
                child:
                    initializeDynamicLinksAndContinue(employeeID, firstInfo));
          } else {
            return Scaffold(
              body: Center(
                child: Material(
                  borderRadius: BorderRadius.circular(25),
                  elevation: 14,
                  child: Text("MyHomePage:build : unexpected error"),
                ),
              ),
            );
          }
        });
  }
}

FutureBuilder<PendingDynamicLinkData?> initializeDynamicLinksAndContinue(
    String employeeID, UserInfo? firstInfo) {
  return FutureBuilder<PendingDynamicLinkData?>(
      future: FirebaseDynamicLinks.instance.getInitialLink(),
      builder: (context, initialLink) {
        if (initialLink.hasError) {
          return Text("Error in getInitialLink");
        } else if (initialLink.hasData) {
          final Uri? deepLink = initialLink.data!.link;
          if (deepLink != null) {
            storeReferralID(deepLink, employeeID);
          }
        }
        return EmployeeOnBoarding(
            employeeID, currentPageName, firstInfo, currentPage);
      });
}

void storeReferralID(Uri deepLink, String employeeID) {
  print("Deep Link = $deepLink");
  Map<String, String> queryParameters = deepLink.queryParameters;
  queryParameters.forEach((key, value) {
    print("--- key : $key, value : $value");
  });

  Map<String, String> map = deepLink.queryParameters;
  if (map["uid"] != null) {
    String uid = map["uid"]!;
    String referralPath = "Employees/$employeeID/Referrals";
    var referralReference =
        FirebaseFirestore.instance.collection(referralPath).doc(uid);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        referralReference,
        {"timestamp": DateTime.now().millisecondsSinceEpoch.toString()},
      );
    });

    String referralAcceptedPath = "EmployeeRatings/$uid/EmployeeReferralAcceptance";
    var referralAcceptedReference =
    FirebaseFirestore.instance.collection(referralAcceptedPath).doc(employeeID);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        referralAcceptedReference,
        {"timestamp": DateTime.now().millisecondsSinceEpoch.toString()},
      );
    });

  }
}
