import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;
import 'package:path_provider/path_provider.dart';

import '../Pages/activation_screen.dart' as activate;
import '../globals.dart' as globals;

bool entered = false;
bool firstTimeOut = true;

Future checkActivationCode(BuildContext context) async {
  if (!entered) {
    entered = true;
    try {
      List _AuthenticationData = [];
      late Directory dir;
      bool _fileExist;
      String fileName = "Auth.json";
      dir = await getApplicationDocumentsDirectory();
      final file = File(dir.path + "/" + fileName);
      // file.delete(); ////////////////////////////////////////////
      _fileExist = await file.exists();
      if (!_fileExist) {
        final String newFileData =
            await rootBundle.loadString('assets/Auth.json');
        final data = await json.decode(newFileData);
        file.writeAsStringSync(json.encode(data));
      }
      final contents = await file.readAsString();
      final data = await json.decode(contents);
      _AuthenticationData = data["Authentication"];
      if (_AuthenticationData[0]["RememberMe"] == "true") {
        activate.auth.userID = _AuthenticationData[0]["userID"];
        activate.auth.userName = _AuthenticationData[0]["userName"];
        await globals.getImageURL();
        activate.auth.activationKey = _AuthenticationData[0]["activationKey"];
        globals.entered = false;
        await globals.getMenu(int.parse(activate.auth.userID));
        if (connect.timeOut) {
          if (!firstTimeOut) {
            Navigator.of(context).pop();
          }
          await globals.lostConnectionAlert(
            context,
            title: "لا يوجد إتصال بالسيرفر",
            content: "برجاء التأكد من الإتصال بالأنترنت ",
            cancelButton: true,
          );
          if (globals.PopupCancel) {
            globals.PopupCancel = false;
            entered = false;
            firstTimeOut = true;
            await Future.delayed(Duration(milliseconds: 300));
            Navigator.of(context).pushNamed('HomePage');
          } else {
            entered = false;
            firstTimeOut = false;
            checkActivationCode(context);
          }
        } else {
          await globals.getCurrentHistory(int.parse(activate.auth.userID));
          await globals.getPreviousHistory(int.parse(activate.auth.userID));
          await globals.getOrderNumberAndDate(int.parse(activate.auth.userID));
          await Future.delayed(Duration(milliseconds: 3640));
          firstTimeOut = true;
          Navigator.of(context).pushNamed('HomePage');
        }
      } else {
        await Future.delayed(Duration(milliseconds: 3640));
        activate.auth.rememberMe = false;
        Navigator.of(context).pushNamed('LoginScreen');
      }
    } catch (e) {}
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    checkActivationCode(context);
    return Center(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            stops: [
              0.3,
              0.9,
            ],
            colors: [
              Color(0xFFFFEB3B),
              Color(0xFFF44336),
            ],
          ),
        ),
        child: Center(
          child: new Center(
            child: new Image.asset('images/loading.gif'),
          ),
        ),
      ),
    );
  }
}
