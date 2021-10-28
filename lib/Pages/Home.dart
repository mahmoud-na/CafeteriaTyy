import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;
import 'package:provider/provider.dart';

import '../Components/Checkout_List_Builder.dart';
import '../Components/Drinks_List_Builder.dart';
import '../Components/Food_List_Builder.dart';
import '../Components/MyDrawer.dart';
import '../Components/Snacks_List_Builder.dart';
import '../Pages/activation_screen.dart' as activate;
import '../globals.dart' as globals;
import 'MyCart.dart';

class Home extends StatefulWidget {
  @override
  State<Home> createState() => HomeState();
}

class HomeState extends State<Home> with ChangeNotifier {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int totalitems = 0;
  double pricetotal = 0.0;
  int currentStep = 0;
  bool complete = false;
  int index = 0;
  List<Widget> menuNavBar = [];
  setIndexval(int val) {
    index = val;
  }

  List<Widget> pageList = [
    Home_List_Builder(),
    Drink_List_Builder(),
    Snacks_List_Builder(),
  ];

  cancel() {
    if (currentStep > 0) {
      goTo(currentStep - 1);
    }
  }

  goTo(int step) {
    setState(
      () {
        currentStep = step;
      },
    );
  }

  Future<bool> _onBackPressed() async {
    if (currentStep == 0) {
      return (await showDialog(
            context: context,
            builder: (_) => new AlertDialog(
              title: new Text(
                "إنتبه",
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: new Text(
                "هل تود الخروج من التطبيق",
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textDirection: TextDirection.rtl,
              ),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    TextButton(
                      child: Text(
                        'تأكيد',
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green),
                      ),
                      onPressed: () {
                        SystemNavigator.pop();
                      },
                    ),
                    TextButton(
                      child: Text(
                        'إلغاء',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 25.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                    )
                  ],
                ),
              ],
            ),
          )) ??
          false;
    } else {
      return Navigator.of(context).pushNamed('HomePage') as Future<bool>;
    }
  }

  bool timerFire = true;

  alert(String msg, int duration) {
    _scaffoldKey.currentState!.showSnackBar(
      new SnackBar(
        content: new Text(
          msg,
          textDirection: TextDirection.rtl,
          style: TextStyle(
              fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        duration: Duration(milliseconds: duration),
        backgroundColor: Colors.grey[200],
      ),
    );
  }

  sendOrderLoop(String order, MyCart cart, BuildContext context) async {
    List confirmList = [];
    await connect.connectToServer(
        'EID:${activate.auth.userID},Order,$order,EName:${activate.auth.userName},TCost:${cart.Totalprice}<EOF>',
        'Order');
    if (connect.timeOut) {
      Navigator.of(context).pop();
      await globals.lostConnectionAlert(
        context,
        title: "لا يوجد إتصال بالسيرفر",
        content: "برجاء التأكد من الإتصال بالأنترنت ",
        cancelButton: true,
      );
      if (!globals.PopupCancel) {
        sendOrderLoop(order, cart, context);
      }
      globals.PopupCancel = false;
    }
    confirmList = connect.ResponseList;
    if (confirmList[0]["OrderValid"] == "true") {
      globals.orderNumber = confirmList[0]["orderNum"];
      timerFire = true;
      Navigator.of(context).pop();
      Timer(
        Duration(seconds: 2),
        () async {
          if (timerFire) {
            timerFire = false;
            await globals.getCurrentHistory(int.parse(activate.auth.userID));
            await globals.getPreviousHistory(int.parse(activate.auth.userID));
            cart.ResetItems();
            Navigator.of(context).pushNamed('HomePage');
          }
        },
      );
      await globals.ConfirmationAlert(
        context,
        title: '  تم تأكيد الطلب رقم  ${confirmList[0]["orderNum"]} #',
        content: "يمكنك مراجعة الطلب من صفحة طلباتي",
        TitleStyle: TextStyle(
          color: Colors.green,
          fontSize: 25.0,
          fontWeight: FontWeight.bold,
        ),
        icon: Icon(
          Icons.verified_rounded,
          color: Colors.green,
          size: 40,
        ),
      );
      cart.ResetItems();
      if (timerFire) {
        Navigator.of(context).pushNamed('HomePage');
      }
      timerFire = false;
      await globals.getCurrentHistory(int.parse(activate.auth.userID));
      await globals.getPreviousHistory(int.parse(activate.auth.userID));
    } else {
      Navigator.of(context).pop();
      globals.ConfirmationAlert(
        context,
        title: 'لم يتم قبول الطلب',
        content: confirmList[0]["errMsg"],
        TitleStyle: TextStyle(
          color: Colors.red,
          fontSize: 23.0,
          fontWeight: FontWeight.bold,
        ),
        icon: Icon(
          Icons.error,
          color: Colors.red,
          size: 40,
        ),
      );
    }
  }

  Future sendOrder(MyCart cart, BuildContext context) async {
    connect.ResponseList = [];
    String order = '';
    for (int index = 0; index < cart.Basketitem.length; index++) {
      if (cart.Basketitem[index].id >= 2000 &&
          cart.Basketitem[index].id < 3000) {
        order = order +
            'LID:${cart.Basketitem[index].id},LQty:${cart.Basketitem[index].counter}';
        if (index != cart.Basketitem.length - 1) {
          order = order + ",";
        }
      } else if (cart.Basketitem[index].id >= 3000 &&
          cart.Basketitem[index].id < 4000) {
        order = order +
            'BID:${cart.Basketitem[index].id},BQty:${cart.Basketitem[index].counter}';
        if (index != cart.Basketitem.length - 1) {
          order = order + ",";
        }
      } else if (cart.Basketitem[index].id >= 4000 &&
          cart.Basketitem[index].id < 5000) {
        order = order +
            'DID:${cart.Basketitem[index].id},DQty:${cart.Basketitem[index].counter}';
        if (index != cart.Basketitem.length - 1) {
          order = order + ",";
        }
      } else if (cart.Basketitem[index].id >= 5000 &&
          cart.Basketitem[index].id < 6000) {
        order = order +
            'SID:${cart.Basketitem[index].id},SQty:${cart.Basketitem[index].counter}';
        if (index != cart.Basketitem.length - 1) {
          order = order + ",";
        }
      } else {
        print("لا يمكن اتمام االطلب برجاء المحاولة مرة اخرى");
      }
    }
    sendOrderLoop(order, cart, context);
  }

  _showMaterialDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text(
          title,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontSize: 25.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: new Text(
          content,
          style: TextStyle(
            fontSize: 18.0,
          ),
          textDirection: TextDirection.rtl,
        ),
        buttonPadding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        actions: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      border: Border(
                    top: BorderSide(
                      width: 1.5,
                      color: Colors.grey.shade200,
                    ),
                    right: BorderSide(
                      width: 1.5,
                      color: Colors.grey.shade200,
                    ),
                  )),
                  child: TextButton(
                    child: Text(
                      'تأكيد',
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      globals.WaitingAlert(
                        context,
                        title: "برجاء الإنتظار...",
                        content: "جار الإتصال بالسيرفر...",
                      );
                      final cart = Provider.of<MyCart>(context, listen: false);
                      await sendOrder(cart, context);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1.5,
                        color: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  child: TextButton(
                    child: Text(
                      'إلغاء',
                      textDirection: TextDirection.rtl,
                      style: TextStyle(
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _enabled = true;

  unSelectedColor() {
    if (currentStep == 1) {
      return Colors.black38;
    } else {
      return Colors.black38;
    }
  }

  selectedColor() {
    if (currentStep == 1) {
      return Colors.black38;
    } else {
      return Colors.amber;
    }
  }

  bool step1IsActivated() {
    if (currentStep == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool step2IsActivated() {
    if (currentStep == 1) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<MyCart>(
      context,
    );
    List<Step> _steps = [
      Step(
        title: const Text(
          'اختر اكلك',
          textDirection: TextDirection.rtl,
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
        ),
        isActive: step1IsActivated(),
        state: StepState.indexed,
        content: Column(
          children: [
            globals.orderNumber != 0
                ? Container(
                    width: 125,
                    height: 30,
                    child: FloatingActionButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7.0))),
                      onPressed: null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "${globals.orderNumber}",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "طلب رقم ",
                            style: TextStyle(fontSize: 18.0),
                            textDirection: TextDirection.rtl,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
            pageList[index],
          ],
        ),
      ),
      Step(
        title: const Text('مراجعة الطلب',
            textDirection: TextDirection.rtl,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        isActive: step2IsActivated(),
        state: StepState.indexed,
        content: Checkout_List_Builder(),
      ),
    ];
    next() {
      if (currentStep + 1 != _steps.length) {
        goTo(currentStep + 1);
      }
    }

    List<Widget> menuNavBar = [
      IconButton(
        icon: Icon(
          Icons.fastfood,
          color: index == 0 ? Colors.white : Colors.grey.withOpacity(0.8),
          size: index == 0 ? 35 : 30,
        ),
        onPressed: () {
          setState(
            () {
              index = 0;
            },
          );
        },
      ),
      IconButton(
        icon: Icon(
          Icons.emoji_food_beverage_rounded,
          color: index == 1 ? Colors.white : Colors.grey.withOpacity(0.8),
          size: index == 1 ? 35 : 30,
        ),
        onPressed: () {
          setState(
            () {
              index = 1;
            },
          );
        },
      ),
      IconButton(
        icon: ImageIcon(
          AssetImage(
            "images/snacks.png",
          ),
          color: index == 2 ? Colors.white : Colors.grey.withOpacity(0.8),
          size: index == 2 ? 40 : 30,
        ),
        onPressed: () {
          setState(
            () {
              index = 2;
            },
          );
        },
      ),
    ];
    List<Widget> checkoutNavBar = [
      Icon(
        Icons.shopping_cart,
        color: Colors.white,
        size: 30,
      ),
      Container(
        child: Text(
          "أضف إلى السلة",
          textDirection: TextDirection.rtl,
          style: TextStyle(
              fontSize: 23.0, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    ];
    return WillPopScope(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          title: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: new Text(
              'الكافيتريا',
              style: TextStyle(
                fontSize: 23.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          toolbarHeight: 50.0,
          centerTitle: false,
          elevation: 6.0,
        ),
        drawer: MyDrawer(),
        body: currentStep == 1
            ? Stepper(
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                steps: _steps,
                type: StepperType.horizontal,
                currentStep: currentStep,
                onStepContinue: next,
                controlsBuilder: (BuildContext context,voidCallback) {
                  return Column();
                },
                onStepTapped: (step) {
                  if (cart.TotalItems == 0 && step != 0) {
                    if (_enabled &&
                        (globals.FoodList.isNotEmpty ||
                            globals.DrinksList.isNotEmpty ||
                            globals.SnacksList.isNotEmpty)) {
                      alert("برجاء اختيار الوجبة للأنتقال للصفحة التالية !!",
                          2000);
                      Timer(
                        Duration(seconds: 2),
                        () {
                          _enabled = true;
                        },
                      );
                      _enabled = false;
                    }
                  } else {
                    return goTo(step);
                  }
                },
              )
            : RefreshIndicator(
                onRefresh: () {
                  return Future.delayed(
                    Duration(milliseconds: 700),
                    () async {
                      globals.DrinksList = [];
                      globals.FoodList = [];
                      globals.SnacksList = [];
                      globals.entered = false;
                      await globals.getMenu(int.parse(activate.auth.userID));
                      await globals.getOrderNumberAndDate(
                          int.parse(activate.auth.userID));
                      cart.ResetItems();
                    },
                  );
                },
                child: Stepper(
                  physics: globals.FoodList.isEmpty &&
                          globals.DrinksList.isEmpty &&
                          globals.SnacksList.isEmpty
                      ? NeverScrollableScrollPhysics()
                      : BouncingScrollPhysics(
                          parent: AlwaysScrollableScrollPhysics()),
                  steps: _steps,
                  type: StepperType.horizontal,
                  currentStep: currentStep,
                  onStepContinue: next,
                  controlsBuilder: (BuildContext context,voidCallback ) {return Container();},
                  // controlsBuilder: (BuildContext context, {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {return Container();},
                  onStepTapped: (step) {
                    if (cart.TotalItems == 0 && step != 0) {
                      if (_enabled &&
                          (globals.FoodList.isNotEmpty ||
                              globals.DrinksList.isNotEmpty ||
                              globals.SnacksList.isNotEmpty)) {
                        alert("برجاء اختيار الوجبة للأنتقال للصفحة التالية !!",
                            2000);
                        Timer(
                          Duration(seconds: 2),
                          () {
                            _enabled = true;
                          },
                        );
                        _enabled = false;
                      }
                    } else {
                      return goTo(step);
                    }
                  },
                ),
              ),
        bottomNavigationBar: currentStep == 0
            ? BottomAppBar(
                shape: CircularNotchedRectangle(),
                color: Colors.amber,
                notchMargin: 8,
                child: Container(
                  margin:
                      cart.TotalItems != 0 ? EdgeInsets.only(right: 80) : null,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: menuNavBar,
                  ),
                ),
              )
            : GestureDetector(
                child: BottomAppBar(
                  shape: CircularNotchedRectangle(),
                  notchMargin: 8,
                  clipBehavior: Clip.antiAlias,
                  color: Colors.amber,
                  child: Container(
                    color: Colors.transparent,
                    padding: EdgeInsets.only(
                      right: MediaQuery.of(context).size.width / 16,
                      left: MediaQuery.of(context).size.width / 8,
                      top: 5,
                      bottom: 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: checkoutNavBar,
                    ),
                  ),
                ),
                onTap: () {
                  goTo(0);
                },
              ),
        floatingActionButton: currentStep == 0
            ? (cart.TotalItems != 0
                ? FloatingActionButton(
                    child: Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {
                        goTo(1);
                      });
                    },
                  )
                : null)
            : SizedBox(
                width: 60,
                height: 60,
                child: FloatingActionButton(
                  child: Text(
                    "إدفع",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  // Icon(Icons.monetization_on,color: Colors.white,size: 45,),
                  onPressed: () {
                    _showMaterialDialog(
                        "تأكيد الدفع", "برجاء مراجعة الطلب قبل تأكيد الدفع");
                  },
                ),
              ),
        floatingActionButtonLocation: currentStep == 0
            ? FloatingActionButtonLocation.endDocked
            : FloatingActionButtonLocation.centerDocked,
      ),
      onWillPop: _onBackPressed,
    );
  }
}
