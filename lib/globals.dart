import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;

import '/Components/Items.dart';
import '../Components/History.dart';
import '../Pages/activation_screen.dart' as activate;

late var currentContext;
List FoodList = [];
List DrinksList = [];
List SnacksList = [];
List<MenuItem> Items = [];
List<MenuItem> Drinks = [];
List<MenuItem> Snacks = [];
List<History> fullCurrentHistory = [];
List<History> fullPreviousHistory = [];
double TotalCurrentOrdersPrice = 0.0;
double TotalPreviousOrdersPrice = 0.0;
bool entered = false;
bool entered2 = false;
bool entered3 = false;
bool PopupCancel = false;
int orderNumber = 0;
String Daterequest = '';

getImageURL() async {
  try {
    FirebaseStorage storageRef = FirebaseStorage.instance;
    Reference ref = storageRef.ref();
    activate.auth.profilePicture = await ref
        .child('ProfilesPics/${activate.auth.userName}:${activate.auth.userID}')
        .getDownloadURL();
    activate.auth.drawerBGimage = await ref
        .child(
            'drawerBGimages/${activate.auth.userName}:${activate.auth.userID}')
        .getDownloadURL();
    print('Get Image URL Successfully');
  } catch (e) {}
}

Future ConfirmationAlert(
  BuildContext context, {
  String title = '',
  String content = '',
  bool withButton = false,
  bool Backbutton = true,
  TextStyle ContentStyle = const TextStyle(
    fontSize: 18.0,
  ),
  TextStyle TitleStyle = const TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
  ),
  Icon icon = const Icon(
    Icons.error,
    color: Colors.red,
    size: 40,
  ),
  int delayDuration = 0,
  Widget widget = const CircularProgressIndicator(),
}) async {
  await showDialog(
    context: context,
    barrierDismissible: !withButton,
    builder: (BuildContext contextt) {
      return AlertDialog(
        titlePadding: EdgeInsets.only(
          top: 15.0,
        ),
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              child: icon,
            ),
            new Text(
              title,
              textDirection: TextDirection.rtl,
              style: TitleStyle,
            ),
            Divider(color: Colors.grey, indent: 55, endIndent: 55),
          ],
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(25.0))),
        content: new Text(
          content,
          style: ContentStyle,
          textDirection: TextDirection.rtl,
        ),
      );
    },
  );
}

Future WaitingAlert(
  BuildContext context, {
  String title = '',
  String content = '',
  TextStyle ContentStyle = const TextStyle(fontSize: 18.0),
  TextStyle TitleStyle =
      const TextStyle(fontSize: 25.0, fontWeight: FontWeight.bold),
  Widget widget = const CircularProgressIndicator(
    strokeWidth: 4,
  ),
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext contextt) {
      return WillPopScope(
          onWillPop: () async => false,
          child: AlertDialog(
            title: new Text(
              title,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontSize: 25.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 40),
                  child: SizedBox(
                    height: 23,
                    width: 23,
                    child: widget,
                  ),
                ),
                new Text(
                  content,
                  style: TextStyle(
                    fontSize: 18.0,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ));
    },
  );
}

Future lostConnectionAlert(
  BuildContext context, {
  String title = '',
  String content = '',
  bool cancelButton = false,
  TextStyle ContentStyle = const TextStyle(
    fontSize: 18.0,
  ),
  TextStyle TitleStyle = const TextStyle(
    fontSize: 25.0,
    fontWeight: FontWeight.bold,
  ),
}) async {
  await showDialog(
    context: context,
    barrierDismissible: !cancelButton,
    builder: (BuildContext contextt) {
      return WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: new Text(
            title,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              new Text(
                content,
                style: TextStyle(
                  fontSize: 18.0,
                ),
                textDirection: TextDirection.rtl,
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
          actions: <Widget>[
            Row(
              mainAxisAlignment: cancelButton
                  ? MainAxisAlignment.spaceEvenly
                  : MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(contextt).pop();
                      WaitingAlert(
                        context,
                        title: "برجاء الإنتظار...",
                        content: "جار الإتصال بالسيرفر...",
                      );
                    },
                    icon: Icon(Icons.replay),
                    label: Text("إعادة المحاولة")),
                cancelButton
                    ? ElevatedButton(
                        onPressed: () {
                          PopupCancel = true;
                          Navigator.of(contextt).pop();
                        },
                        child: Text("إلغاء"),
                      )
                    : Container(),
              ],
            ),
          ],
        ),
      );
    },
  );
}

List<History> historySorting(List<History> tmpHistorySorting) {
  var tmp;
  for (int i = 0; i < tmpHistorySorting.length; i++) {
    for (int j = 0; j < tmpHistorySorting.length - 1; j++) {
      if (int.parse(tmpHistorySorting[j].datetime.substring(4, 6)) <
          int.parse(tmpHistorySorting[j + 1].datetime.substring(4, 6))) {
        tmp = tmpHistorySorting[j];
        tmpHistorySorting[j] = tmpHistorySorting[j + 1];
        tmpHistorySorting[j + 1] = tmp;
      } else if (int.parse(tmpHistorySorting[j].datetime.substring(4, 6)) ==
          int.parse(tmpHistorySorting[j + 1].datetime.substring(4, 6))) {
        if (int.parse(tmpHistorySorting[j].datetime.substring(12, 14)) <
            int.parse(tmpHistorySorting[j + 1].datetime.substring(12, 14))) {
          tmp = tmpHistorySorting[j];
          tmpHistorySorting[j] = tmpHistorySorting[j + 1];
          tmpHistorySorting[j + 1] = tmp;
        } else if (int.parse(tmpHistorySorting[j].datetime.substring(12, 14)) ==
            int.parse(tmpHistorySorting[j + 1].datetime.substring(12, 14))) {
          if (int.parse(tmpHistorySorting[j].datetime.substring(15, 17)) <
              int.parse(tmpHistorySorting[j + 1].datetime.substring(15, 17))) {
            tmp = tmpHistorySorting[j];
            tmpHistorySorting[j] = tmpHistorySorting[j + 1];
            tmpHistorySorting[j + 1] = tmp;
          } else if (int.parse(
                  tmpHistorySorting[j].datetime.substring(15, 17)) ==
              int.parse(tmpHistorySorting[j + 1].datetime.substring(15, 17))) {
            if (int.parse(tmpHistorySorting[j].datetime.substring(18, 20)) <
                int.parse(
                    tmpHistorySorting[j + 1].datetime.substring(18, 20))) {
              tmp = tmpHistorySorting[j];
              tmpHistorySorting[j] = tmpHistorySorting[j + 1];
              tmpHistorySorting[j + 1] = tmp;
            }
          }
        }
      }
    }
  }

  return tmpHistorySorting;
}

Future getCurrentHistory(int UserID) async {
  connect.ResponseList = [];
  fullCurrentHistory = [];
  print("-------------------------------------------\n");
  print("Just before connectTo Server");
  print("-------------------------------------------\n");
  await connect.connectToServer(
      'EID:$UserID,CurrentHistory<EOF>', 'CurrentHistory');
  if (!connect.timeOut) {
    // historyList = connect.ResponseList;
    entered2 = false;
    getCurrentHistoryReady(connect.ResponseList);
    print("-------------------------------------------\n");
    print("Just after connectTo Server");
    print("-------------------------------------------\n");
  }
}

Future getPreviousHistory(int UserID) async {
  connect.ResponseList = [];
  fullPreviousHistory = [];
  print("-------------------------------------------\n");
  print("Just before connectTo Server");
  print("-------------------------------------------\n");
  await connect.connectToServer(
      'EID:$UserID,PreviousHistory<EOF>', 'PreviousHistory');
  if (!connect.timeOut) {
    // historyList = connect.ResponseList;
    entered3 = false;
    getPreviousHistoryReady(connect.ResponseList);
    print("-------------------------------------------\n");
    print("Just after connectTo Server");
    print("-------------------------------------------\n");
  }
}

getPreviousHistoryReady(List historyList) {
  TotalPreviousOrdersPrice = 0.0;
  if (!entered3 && historyList.isNotEmpty) {
    try {
      for (int index = 0; index < historyList.length; index++) {
        History _HistoryTmp = History();
        _HistoryTmp.datetime = historyList[index]['datetime'];
        _HistoryTmp.price = historyList[index]['price'];
        _HistoryTmp.paymentType = historyList[index]['payType'];
        TotalPreviousOrdersPrice += historyList[index]['price'];
        List items = historyList[index]['List'];
        if (_HistoryTmp.paymentType == "Prepaid") {
          _HistoryTmp.orderNumber = historyList[index]['OrderNumber'];
          for (int i = 0; i < items.length; i++) {
            _HistoryTmp.HistoryLog.add(HistoryItem(
                id: items[i]['id'],
                name: items[i]['name'],
                price: items[i]['price'],
                counter: items[i]['counter'],
                orderStatus: items[i]['OrderStatus']));
          }
        } else {
          //This else for hard coded postpaid details order
          _HistoryTmp.HistoryLog.add(HistoryItem(
              id: 111,
              name: items[0]['name'],
              price: 0.0,
              counter: 0,
              orderStatus: ""));
        }
        fullPreviousHistory.add(_HistoryTmp);
      }
    } catch (e) {
      print("Error in previous History:  $e");
    }
  }
  entered3 = true;
}

getCurrentHistoryReady(List historyList) {
  TotalCurrentOrdersPrice = 0.0;
  if (!entered2 && historyList.isNotEmpty) {
    try {
      for (int index = 0; index < historyList.length; index++) {
        History _HistoryTmp = History();
        _HistoryTmp.datetime = historyList[index]['datetime'];
        _HistoryTmp.price = historyList[index]['price'];
        _HistoryTmp.paymentType = historyList[index]['payType'];
        TotalCurrentOrdersPrice += historyList[index]['price'];
        List items = historyList[index]['List'];
        if (_HistoryTmp.paymentType == "Prepaid") {
          _HistoryTmp.orderNumber = historyList[index]['OrderNumber'];
          for (int i = 0; i < items.length; i++) {
            _HistoryTmp.HistoryLog.add(
              HistoryItem(
                  id: items[i]['id'],
                  name: items[i]['name'],
                  price: items[i]['price'],
                  counter: items[i]['counter'],
                  orderStatus: items[i]['OrderStatus']),
            );
          }
        } else {
          _HistoryTmp.HistoryLog.add(HistoryItem(
              id: 111,
              name: items[0]['name'],
              price: 0.0,
              counter: 0,
              orderStatus: ""));
        }
        fullCurrentHistory.add(_HistoryTmp);
      }
    } catch (e) {
      print("error ya joee $e");
    }
  }
  entered2 = true;
}

Future getMenu(int UserID) async {
  Items = [];
  Snacks = [];
  Drinks = [];
  connect.ResponseList = [];
  print("-------------------------------------------\n");
  print("Just before connectTo Server");
  print("-------------------------------------------\n");
  await connect.connectToServer('EID:$UserID,DayMenu<EOF>', 'Menu');
  if (!connect.timeOut) {
    print(connect.ResponseList[0]);
    GetMenuReady(connect.ResponseList);
    print("-------------------------------------------\n");
    print("Just after connectTo Server");
    print("-------------------------------------------\n");
  }
}

late bool validMenu;
Future<void> GetMenuReady(List MenuList) async {
  if (!entered && MenuList.isNotEmpty) {
    validMenu = MenuList[0]['Valid'];
    // validMenu=false;

    if (MenuList[0]['Food'] != null) {
      FoodList = MenuList[0]['Food'];
      for (int index = 0; index < FoodList.length; index++) {
        Items.add(MenuItem(
            id: FoodList[index]['id'],
            name: FoodList[index]['name'],
            price: FoodList[index]['price'],
            image: FoodList[index]['image'],
            counter: FoodList[index]['counter'],
            quantity: FoodList[index]['quantity']));
      }
    } else {}

    if (MenuList[0]['Beverages'] != null) {
      DrinksList = MenuList[0]['Beverages'];
      for (int index = 0; index < DrinksList.length; index++) {
        Drinks.add(MenuItem(
            id: DrinksList[index]['id'],
            name: DrinksList[index]['name'],
            price: DrinksList[index]['price'],
            image: DrinksList[index]['image'],
            counter: DrinksList[index]['counter'],
            quantity: DrinksList[index]['quantity']));
      }
    } else {}

    if (MenuList[0]['Snacks'] != null) {
      SnacksList = MenuList[0]['Snacks'];
    }
    if (MenuList[0]['Desserts'] != null) {
      if (MenuList[0]['Snacks'] != null) {
        SnacksList = (MenuList[0]['Desserts']) + SnacksList;
      } else {
        SnacksList = (MenuList[0]['Desserts']);
      }
    }
    if (SnacksList.isNotEmpty) {
      for (int index = 0; index < SnacksList.length; index++) {
        Snacks.add(MenuItem(
            id: SnacksList[index]['id'],
            name: SnacksList[index]['name'],
            price: SnacksList[index]['price'],
            image: SnacksList[index]['image'],
            counter: SnacksList[index]['counter'],
            quantity: SnacksList[index]['quantity']));
      }
    }
  } else {}
  entered = true;
}

Future getOrderNumberAndDate(int UserID) async {
  connect.ResponseList = [];
  print("-------------------------------------------\n");
  print("Just before connectTo Server");
  print("-------------------------------------------\n");
  await connect.connectToServer(
      'EID:$UserID,OrderNumberAndDate<EOF>', 'OrderNumberAndDate');

  if (!connect.timeOut) {
    orderNumber = connect.ResponseList["orderNum"];
    print('ToDay Order Number:  ${connect.ResponseList['orderNum']}');
    orderNumber = connect.ResponseList["orderNum"];
    print('ToDay Date:  ${connect.ResponseList['Date']}');
    Daterequest = await connect.ResponseList["Date"];
    print("-------------------------------------------\n");
    print("Just after connectTo Server");
    print("-------------------------------------------\n");
  }
}

ResetItems() {
  for (int index = 0; index < FoodList.length; index++) {
    Items[index].counter = 0;
  }

  for (int index = 0; index < DrinksList.length; index++) {
    Drinks[index].counter = 0;
  }

  for (int index = 0; index < SnacksList.length; index++) {
    Snacks[index].counter = 0;
  }
}
