import 'dart:async';

import 'package:flutter/material.dart';
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;
import 'package:kafeteria_elhana/Pages/MyCart.dart';
import 'package:provider/provider.dart';

import '../Components/MyDrawer.dart';
import '../Pages/activation_screen.dart' as activate;
import '../globals.dart' as globals;

class CurrentMonthOrders extends StatefulWidget {
  const CurrentMonthOrders({Key? key}) : super(key: key);

  @override
  CurrentMonthOrdersState createState() => CurrentMonthOrdersState();
}

class CurrentMonthOrdersState extends State<CurrentMonthOrders> {
  getHistoryLoop(BuildContext context) async {
    await globals.getCurrentHistory(int.parse(activate.auth.userID));
    if (connect.timeOut) {
      await globals.lostConnectionAlert(
        context,
        title: "لا يوجد إتصال بالسيرفر",
        content: "برجاء التأكد من الإتصال بالأنترنت ",
      );
      getHistoryLoop(context);
    }
  }

  int counter = 1;
  dateFormating(int index, int startChar, int endChar) {
    return int.parse(globals.fullCurrentHistory[index].datetime
        .substring(startChar, endChar));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<MyCart>(context, listen: false);
    Future<bool> _onBackPressed() async {
      return Navigator.of(context).pushNamed('HomePage') as Future<bool>;
    }

    globals.fullCurrentHistory = globals.historySorting(globals.fullCurrentHistory);
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F0F0),
        appBar: new AppBar(
          title: new Text('طلبات الشهر الحالي',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          toolbarHeight: 50.0,
        ),
        drawer: MyDrawer(),
        body: globals.fullCurrentHistory.length == 0
            ? Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(bottom: 50.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "لا يوجد سجل طلبات متاح الآن",
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF656464),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              Reconnect() async {
                                globals.entered2 = false;
                                globals.WaitingAlert(
                                  context,
                                  title: "برجاء الإنتظار...",
                                  content: "جار الإتصال بالسيرفر...",
                                );
                                await globals.getCurrentHistory(
                                    int.parse(activate.auth.userID));
                                if (connect.timeOut) {
                                  Navigator.of(context).pop();
                                  await globals.lostConnectionAlert(
                                    context,
                                    title: "لا يوجد إتصال بالسيرفر",
                                    content:
                                        "برجاء التأكد من الإتصال بالأنترنت ",
                                    cancelButton: true,
                                  );
                                  if (globals.PopupCancel) {
                                    globals.PopupCancel = false;
                                  } else {
                                    Navigator.of(context).pop();
                                    Reconnect();
                                  }
                                }
                              }

                              await Reconnect();
                              Navigator.of(context).pop();
                              setState(() {});
                            },
                            icon: Icon(
                              Icons.refresh,
                              size: 35,
                              color: Color(0xFF656464),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  child: RefreshIndicator(
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: globals.fullCurrentHistory.length,
                      physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemBuilder: (context, index) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: GestureDetector(
                            onTap: () {
                              cart.inedx = index;
                              globals.fullCurrentHistory[index].paymentType ==
                                      'Prepaid'
                                  ? Navigator.of(context)
                                      .pushNamed('CurrentMonthOrderDetails')
                                  : null;
                            },
                            child: Column(
                              children: [
                                ((globals.fullCurrentHistory[index].datetime
                                                .substring(0, 6)) ==
                                            (globals.Daterequest.substring(
                                                0, 6))) &&
                                        (index == 0)
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            width: 130,
                                            decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15.0))),
                                            height: 5,
                                          ),
                                          Text(
                                            "  طلبات اليوم  ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Container(
                                            width: 130,
                                            decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15.0))),
                                            height: 5,
                                          ),
                                        ],
                                      )
                                    : Container(),
                                Card(
                                  color: Colors.white.withOpacity(0.97),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25.0),
                                  ),
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 5,
                                        ),
                                        child: Text(
                                          "${globals.fullCurrentHistory[index].datetime.substring(0, 3)} ${dateFormating(index, 4, 6)}, ${dateFormating(index, 12, 14) > 12 ? dateFormating(index, 12, 14) - 12 : dateFormating(index, 12, 14)}${globals.fullCurrentHistory[index].datetime.substring(14, 17)}",
                                          style: TextStyle(fontSize: 22.0),
                                        ),
                                      ),
                                      Divider(
                                          color: Colors.black,
                                          indent: 50,
                                          endIndent: 50),
                                      Container(
                                        child: globals.fullCurrentHistory[index]
                                                    .orderNumber !=
                                                0
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.baseline,
                                                textBaseline:
                                                    TextBaseline.alphabetic,
                                                children: <Widget>[
                                                  Text(
                                                    "رقم الطلب:",
                                                    style: TextStyle(
                                                        fontSize: 16.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                  SizedBox(
                                                    width: 5.0,
                                                  ),
                                                  Text(
                                                    "${globals.fullCurrentHistory[index].orderNumber}",
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  )
                                                ],
                                              )
                                            : null,
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 10,
                                          right: 15,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.baseline,
                                          textBaseline: TextBaseline.alphabetic,
                                          children: <Widget>[
                                            Expanded(
                                                flex: 1,
                                                child: Text("السعر الكلي:")),
                                            Expanded(
                                              flex: 3,
                                              child: Text(
                                                  "${globals.fullCurrentHistory[index].price}"),
                                            )
                                          ],
                                        ),
                                      ),
                                      Container(
                                        margin: EdgeInsets.only(
                                            top: 10.0,
                                            right: 15.0,
                                            bottom: 10.0),
                                        child: Row(
                                          children: <Widget>[
                                            Text("طريقة الدفع:"),
                                            Expanded(
                                              // flex: 300,
                                              child: Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                child: Text(
                                                    "${globals.fullCurrentHistory[index].paymentType == 'Postpaid' ? 'دفع عند الإستلام  (${globals.fullCurrentHistory[index].HistoryLog[0].name}) ' : 'دفع مسبق'} "),
                                              ),
                                            ),
                                            globals.fullCurrentHistory[index]
                                                        .paymentType ==
                                                    'Prepaid'
                                                ? Expanded(
                                                    // flex: 200,
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10.0),
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: <Widget>[
                                                          Text(
                                                            "تفاصيل الطلب ",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Icon(Icons
                                                              .keyboard_arrow_down_outlined)
                                                        ],
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ((globals.fullCurrentHistory[index].datetime
                                                .substring(0, 6)) ==
                                            (globals.Daterequest.substring(
                                                0, 6))) &&
                                        ((index + 1 <
                                                globals
                                                    .fullCurrentHistory.length)
                                            ? (globals.fullCurrentHistory[index]
                                                    .datetime
                                                    .substring(0, 6)) !=
                                                (globals
                                                    .fullCurrentHistory[
                                                        index + 1]
                                                    .datetime
                                                    .substring(0, 6))
                                            : true)
                                    ? Column(
                                        children: [
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Container(
                                            width: 330,
                                            decoration: BoxDecoration(
                                                color: Colors.amber,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15.0))),
                                            height: 5,
                                          ),
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      )
                                    : Container(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    onRefresh: () {
                      return Future.delayed(
                        Duration(seconds: 1),
                        () async {
                          globals.entered2 = false;
                          await globals.getCurrentHistory(
                              int.parse(activate.auth.userID));
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
              ),
        bottomNavigationBar: globals.fullCurrentHistory.length != 0
            ? Container(
                height: 50,
                child: Card(
                  color: Colors.amber,
                  margin: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        "L.E  ${globals.TotalCurrentOrdersPrice}",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(right: 20, left: 25),
                        child: Text(
                          "السعر الكلي للطلبات :",
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : null,
      ),
      onWillPop: _onBackPressed,
    );
  }
}

class indexing with ChangeNotifier {
  int index;
  indexing({required this.index});
}
