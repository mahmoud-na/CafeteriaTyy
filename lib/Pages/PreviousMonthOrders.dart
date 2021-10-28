import 'dart:async';
import 'package:flutter/material.dart';
import 'package:kafeteria_elhana/Pages/MyCart.dart';
import 'package:provider/provider.dart';
import '../globals.dart' as globals;
import '../Components/MyDrawer.dart';
import '../Pages/activation_screen.dart' as activate;
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;

class PreviousMonthOrders extends StatefulWidget {
  const PreviousMonthOrders({Key? key}) : super(key: key);

  @override
  PreviousMonthOrdersState createState() => PreviousMonthOrdersState();
}

class PreviousMonthOrdersState extends State<PreviousMonthOrders> {
  getHistoryLoop(BuildContext context) async {
    await globals.getPreviousHistory(int.parse(activate.auth.userID));
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
    return int.parse(globals.fullPreviousHistory[index].datetime.substring(startChar, endChar));
  }
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<MyCart>(context, listen: false);
    Future<bool> _onBackPressed() async {
      return Navigator.of(context).pushNamed('HomePage') as Future<bool>;
    }
    print(globals.fullPreviousHistory.length);
    globals.fullPreviousHistory = globals.historySorting(globals.fullPreviousHistory);
    print(globals.fullPreviousHistory.length);
    return WillPopScope(
      child: Scaffold(
        backgroundColor: Color(0xFFF1F0F0),
        appBar: new AppBar(
          title: new Text('طلبات الشهر السابق',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          toolbarHeight: 50.0,
        ),
        drawer: MyDrawer(),
        body: globals.fullPreviousHistory.isEmpty
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
                                globals.entered3 = false;
                                globals.WaitingAlert(
                                  context,
                                  title: "برجاء الإنتظار...",
                                  content: "جار الإتصال بالسيرفر...",
                                );
                                await globals.getPreviousHistory(int.parse(activate.auth.userID));
                                if (connect.timeOut) {
                                  Navigator.of(context).pop();
                                  await globals.lostConnectionAlert(
                                    context,
                                    title: "لا يوجد إتصال بالسيرفر",
                                    content: "برجاء التأكد من الإتصال بالأنترنت ",
                                    cancelButton: true,
                                  );
                                  if(globals.PopupCancel){
                                    globals.PopupCancel=false;
                                  }else{
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
                      itemCount: globals.fullPreviousHistory.length,
                      physics: BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics(),
                      ),
                      itemBuilder: (context, index) {
                        return Directionality(
                          textDirection: TextDirection.rtl,
                          child: GestureDetector(
                            onTap: () {
                              cart.inedx = index;
                              globals.fullPreviousHistory[index].paymentType=='Prepaid'? Navigator.of(context).pushNamed('PreviousMonthOrderDetails'):null;
                            },
                            child:
                            Card(
                              color: Colors.white.withOpacity(0.97),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                      margin: EdgeInsets.only(top: 5,),
                                      child: Text("${globals.fullPreviousHistory[index].datetime.substring(0, 3)} ${dateFormating(index, 4, 6)}, ${dateFormating(index, 12, 14) > 12 ? dateFormating(index, 12, 14) - 12 : dateFormating(index, 12, 14)}${globals.fullPreviousHistory[index].datetime.substring(14, 17)}",
                                        style: TextStyle(fontSize: 22.0),
                                      ),
                                  ),
                                  Divider(
                                      color: Colors.black,
                                      indent: 50,
                                      endIndent: 50),
                                  Container(
                                    child:globals.fullPreviousHistory[index].orderNumber != 0
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
                                          "${globals.fullPreviousHistory[index].orderNumber}",
                                          style: TextStyle(
                                            fontSize: 16.0,
                                            fontWeight:
                                            FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    )
                                        :null,
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10,
                                        right: 15
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
                                              "${globals.fullPreviousHistory[index].price}"),
                                        )
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin: EdgeInsets.only(
                                        top: 10.0, right: 15.0,bottom: 10.0),
                                    child: Row(
                                      children: <Widget>[
                                       Text("طريقة الدفع:"),
                                        Expanded(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(horizontal: 10.0),
                                            child: Text("${globals.fullPreviousHistory[index].paymentType == 'Postpaid' ? 'دفع عند الإستلام  (${globals.fullPreviousHistory[index].HistoryLog[0].name}) ' : 'دفع مسبق'} "),
                                          ),
                                        ),
                                        globals.fullPreviousHistory[index].paymentType == 'Prepaid'
                                            ? Expanded(
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
                          ),
                        );
                      },
                    ),
                    onRefresh: () {
                      return Future.delayed(
                        Duration(seconds: 1),
                        () async {
                          globals.entered3 = false;
                          await globals.getPreviousHistory(
                              int.parse(activate.auth.userID));
                          setState(() {});
                        },
                      );
                    },
                  ),
                ),
            ),
        bottomNavigationBar: globals.fullPreviousHistory.length != 0
            ?Container(
          height: 50,
          child: Card(
            color: Colors.amber,
            margin: EdgeInsets.zero,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  "L.E  ${globals.TotalPreviousOrdersPrice}",
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
            :null,
      ),
      onWillPop: _onBackPressed,
    );
  }
}

class indexing with ChangeNotifier {
  int index;
  indexing({required this.index});
}
