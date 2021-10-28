import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';

import '/Components/constants.dart';
import '../globals.dart' as globals;

class auth {
  static var userName;
  static var userID;
  static var activationKey;
  static var rememberMe;
  static var profilePicture = "";
  static var drawerBGimage = "";
  static var currentImageTime;
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late Directory dir;
  String fileName = "Auth.json";
  final myController = TextEditingController();
  bool _saving = false;
  bool _enabled = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    getApplicationDocumentsDirectory().then(
      (Directory directory) {
        dir = directory;
      },
    );
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    myController.dispose();
    super.dispose();
  }

  void done1() {
    setState(
      () {
        _saving = true;
      },
    );
  }

  alert(String text) {
    if (_enabled) {
      _scaffoldKey.currentState!.showSnackBar(
        new SnackBar(
          content: new Text(
            text,
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
          duration: const Duration(milliseconds: 2000),
        ),
      );
      Timer(
        Duration(seconds: 2),
        () {
          _enabled = true;
        },
      );
      _enabled = false;
    }
  }

  RememberMeState() async {
    try {
      final file = File(dir.path + "/" + fileName);
      final contents = await file.readAsString();
      final data = await json.decode(contents);
      if (auth.rememberMe == true) {
        data["Authentication"][0]["RememberMe"] = "true";
        data["Authentication"][0]["userID"] = auth.userID;
        data["Authentication"][0]["userName"] = auth.userName;
        data["Authentication"][0]["activationKey"] = auth.activationKey;
        file.writeAsStringSync(json.encode(data));
      } else {
        data["Authentication"][0]["RememberMe"] = "false";
        file.writeAsStringSync(json.encode(data));
      }
    } catch (e) {}
  }

  Future<void> AuthenticationCheck() async {
    List Response = [];

    await connect.connectToServer(
        "EID:0,ACTCODE:${myController.text.toUpperCase()}<EOF>", 'LogIN');
    if (connect.timeOut) {
      await globals.lostConnectionAlert(
        context,
        title: "لا يوجد إتصال بالسيرفر",
        content: "برجاء التأكد من الإتصال بالأنترنت ",
        cancelButton: true,
      );
      if (globals.PopupCancel) {
        setState(
          () {
            _saving = false;
          },
        );
        globals.PopupCancel = false;
      } else {
        Navigator.of(context).pop();
        AuthenticationCheck();
      }
    } else {
      Response = connect.ResponseList;
      if (Response[0]["activationValid"] == "true") {
        auth.userID = Response[0]["ID"];
        auth.userName = Response[0]["Name"];
        auth.activationKey = myController.text;
        await globals.getImageURL();
        RememberMeState();
        await globals.getCurrentHistory(int.parse(auth.userID));
        await globals.getPreviousHistory(int.parse(auth.userID));
        await globals.getOrderNumberAndDate(int.parse(auth.userID));
        globals.entered = false;
        await globals.getMenu(int.parse(auth.userID));
        Navigator.of(context).pushNamed('HomePage');
      } else if (Response[0]["activationValid"] == "false") {
        alert('برجاء إدخال كود تفعيل صحيح !!');
        setState(
          () {
            _saving = false;
          },
        );
      }
    }
  }

  Widget _buildActivationCode() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          'كود التفعيل',
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            keyboardType: TextInputType.text,
            controller: myController,
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Colors.black,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.vpn_key,
                color: Colors.lightBlue,
              ),
              hintText: '  ادخل كود التفعيل الخاص بك',
              hintStyle: kHintTextStyle,
              hintTextDirection: TextDirection.rtl,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            'تذكر حسابي',
            style: kLabelStyle,
          ),
          Theme(
            data: ThemeData(unselectedWidgetColor: Colors.white),
            child: Checkbox(
              value: auth.rememberMe,
              checkColor: Colors.green,
              activeColor: Colors.white,
              onChanged: (value) {
                setState(
                  () {
                    auth.rememberMe = value!;
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginBtn() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: RaisedButton(
        elevation: 5.0,
        onPressed: () async {
          if (myController.text.isEmpty) {
            alert('برجاء إدخال كود التفعيل !!');
          } else {
            done1();
            await AuthenticationCheck();
          }
        },
        padding: EdgeInsets.all(15.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        color: Colors.white,
        child: Text(
          'تفعيل',
          style: TextStyle(
            color: Color(0xFF527DAA),
            letterSpacing: 1.5,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'OpenSans',
          ),
        ),
      ),
    );
  }

  Widget _buildFullPage() {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: <Widget>[
            Container(
              height: double.infinity,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/burger bg.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.3),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical: 120.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset(
                      'images/Aio_Logo_original.png',
                      scale: 15,
                    ),
                    Text(
                      'الكافيتريا',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'ElMessiri',
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 30.0),
                    _buildActivationCode(),
                    SizedBox(
                      height: 30.0,
                    ),
                    _buildRememberMeCheckbox(),
                    _buildLoginBtn(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // globals.setCurrentContext(context.widget);
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        body: ModalProgressHUD(child: _buildFullPage(), inAsyncCall: _saving),
      ),
      onWillPop: () async => false,
    );
  }
}

//
