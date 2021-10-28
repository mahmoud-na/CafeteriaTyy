import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kafeteria_elhana/Pages/LoadingScreen.dart';
import 'package:provider/provider.dart';

import '/Pages/MyCart.dart';
import 'Pages/About.dart';
import 'Pages/CurrentMonthOrderDetail.dart';
import 'Pages/CurrentMonthOrders.dart';
import 'Pages/Home.dart';
import 'Pages/MyProfile.dart';
import 'Pages/PreviousMonthOrderDetail.dart';
import 'Pages/PreviousMonthOrders.dart';
import 'Pages/activation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await firebase_core.Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool entered = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            return MyCart();
          },
        ),
        ChangeNotifierProvider(
          create: (context) {
            return HomeState();
          },
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Cafeteria-T",
        home: LoadingScreen(),
        routes: {
          'HomePage': (context) {
            return Home();
          },
          'LoginScreen': (context) {
            return LoginScreen();
          },
          'MyProfile': (context) {
            return MyProfile();
          },
          'CurrentMonthOrderDetails': (context) {
            return CurrentMonthOrderDetail();
          },
          'CurrentMonthOrders': (context) {
            return CurrentMonthOrders();
          },
          'PreviousMonthOrders': (context) {
            return PreviousMonthOrders();
          },
          'PreviousMonthOrderDetails': (context) {
            return PreviousMonthOrderDetail();
          },
          'About': (context) {
            return About();
          },
          'LoadingScreen': (context) {
            return LoadingScreen();
          },
          'MyApp': (context) {
            return MyApp();
          }
        },
        theme: ThemeData(primarySwatch: Colors.amber),
      ),
    );
    throw UnimplementedError();
  }
}
