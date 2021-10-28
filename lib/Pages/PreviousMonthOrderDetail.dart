import 'package:flutter/material.dart';
import 'package:kafeteria_elhana/Pages/MyCart.dart';
import 'package:provider/provider.dart';
import '../globals.dart' as globals;
import '../Components/MyDrawer.dart';

class PreviousMonthOrderDetail extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<PreviousMonthOrderDetail> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<MyCart>(context);
    int index = cart.inedx;
    dividerBuilder(int i) {
      if (i != (globals.fullPreviousHistory[index].HistoryLog.length - 1)) {
        return Divider(
            color: Colors.grey,
            indent: 20,
            endIndent: MediaQuery.of(context).size.width / 1.8);
      } else {
        return Container();
      }
    }

    return Scaffold(
      appBar: new AppBar(
        title: new Text('تفاصيل الطلب',
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        toolbarHeight: 50.0,
      ),
      drawer: MyDrawer(),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25.0)),
          child: Column(
            children: <Widget>[
              Container(
                  margin: EdgeInsets.only(top: 5, right: 15),
                  child: Text("طلب #${index + 1}",
                      style: TextStyle(fontSize: 22.0))),
              Divider(color: Colors.black, indent: 50, endIndent: 50),
              Container(
                margin: EdgeInsets.only(top: 10, right: 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        "تاريخ الطلب:",
                        style: TextStyle(
                          fontSize: 18.0,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                          "${globals.fullPreviousHistory[index].datetime}"),
                    )
                  ],
                ),
              ),
              Divider(color: Colors.black, indent: 50, endIndent: 50),
              Container(
                height: 450,
                child: ListView.builder(
                  scrollDirection: Axis.vertical,
                  itemCount:
                      globals.fullPreviousHistory[index].HistoryLog.length,
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, i) {
                    return Container(
                      child: Column(
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.only(
                              right: 15,
                            ),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Text(
                                      "الصنف:",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    )),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      "${globals.fullPreviousHistory[index].HistoryLog[i].name}"),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, right: 15),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "الكمية: ",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      "${globals.fullPreviousHistory[index].HistoryLog[i].counter}"),
                                )
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 5, right: 15),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    "السعر:",
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                      "${globals.fullPreviousHistory[index].HistoryLog[i].price * globals.fullPreviousHistory[index].HistoryLog[i].counter}"),
                                )
                              ],
                            ),
                          ),
                          Container(
                              margin: EdgeInsets.only(top: 5, right: 15),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      "حالة الطلب:",
                                      style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textDirection: TextDirection.rtl,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: (globals.fullPreviousHistory[index]
                                                .HistoryLog[i].orderStatus ==
                                            "True")
                                        ? Text(
                                            "تم الإستلام",
                                            textDirection: TextDirection.rtl,
                                          )
                                        : Text(
                                            "تحت التنفيذ",
                                            textDirection: TextDirection.rtl,
                                          ),
                                  )
                                ],
                              )),
                          dividerBuilder(i),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Divider(
                color: Colors.black,
                indent: 50,
                endIndent: 50,
              ),
              Container(
                margin: EdgeInsets.only(top: 10, right: 15),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Text(
                        "السعر الكلي:",
                        style: TextStyle(
                            fontSize: 20.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${globals.fullPreviousHistory[index].price}",
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        alignment: Alignment.bottomLeft,
        margin: EdgeInsets.only(left: 50, bottom: 20),
        child: FloatingActionButton(
          onPressed: () {
            // Navigator.of(context).pop();
            Navigator.of(context).pushNamed('PreviousMonthOrders');
          },
          child: const Icon(Icons.arrow_back_rounded),
          backgroundColor: Colors.amber,
        ),
      ),
    );
  }
}
