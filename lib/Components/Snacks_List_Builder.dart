import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:kafeteria_elhana/Pages/MyCart.dart';
import 'package:provider/provider.dart';
import '../Pages/activation_screen.dart' as activate;
import '../globals.dart' as globals;
import 'package:kafeteria_elhana/Components/Connections.dart' as connect;

class Snacks_List_Builder extends StatefulWidget {
  @override
  _Snacks_List_Builder createState() => _Snacks_List_Builder();
}

class _Snacks_List_Builder extends State<Snacks_List_Builder> {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<MyCart>(context);
    print("SNACKS LIST BUILDER");
    bool _onPressed(int index) {
      return (globals.Snacks[index].counter == 0) ? false : true;
    }
    return globals.SnacksList.isNotEmpty ? globals.validMenu ?
    ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: globals.SnacksList.length,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          height: 130.0,
          child: globals.Snacks[index].quantity != 0
              ? Card(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0)),
            color: Colors.white.withOpacity(0.97),
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Container(
                      width: 105,
                      height: 110,
                      margin: EdgeInsets.only(left: 7.0),
                      child: CachedNetworkImage(
                        key: UniqueKey(),
                        imageUrl:
                        "${globals.Snacks[index].image}",
                        height: 200,
                        width: 200,
                        imageBuilder:
                            (context, imageProvider) =>
                            Container(
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(5.0),
                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                        placeholder: (context, url) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius:
                              BorderRadius.circular(
                                  5.0),
                            ),
                          );
                        },
                        errorWidget: (context, url, error) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius:
                              BorderRadius.circular(
                                  5.0),
                            ),
                            child: Icon(
                              Icons.fastfood,
                              color: Colors.red,
                              size: 30,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 5),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: 15),
                              child: Text(
                                "${globals.Snacks[index].name}",
                                style: TextStyle(
                                    fontSize: 23.0,
                                    fontWeight:
                                    FontWeight.bold),
                                textDirection:
                                TextDirection.rtl,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(
                                  right: 15, top: 0),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.end,
                                children: <Widget>[
                                  Text(
                                    " L.E ${globals.Snacks[index].price} ",
                                    style: TextStyle(
                                      fontSize: 18.0,
                                    ),
                                  ),
                                  Text(
                                    "السعر:",
                                    style: TextStyle(
                                      fontSize: 21.0,
                                    ),
                                    textDirection:
                                    TextDirection.rtl,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Consumer<MyCart>(
                            builder:
                                (context, cart, child) {
                              return Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: 15,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .end,
                                    children: <Widget>[
                                      Container(
                                        child:
                                        GestureDetector(
                                          child: IconButton(
                                            padding:
                                            EdgeInsets.zero,
                                            onPressed:
                                            _onPressed(index)
                                                ? () {
                                              if (globals.Snacks[index].counter > 0) {
                                                globals.Snacks[index].counter = globals.Snacks[index].counter - 1;
                                                cart.remove(globals.Snacks[index]);
                                                print("${globals.Snacks[index].counter} : ${globals.Snacks[index].name}");
                                              }
                                            }
                                                : null,
                                            icon: new Icon(Icons.remove_circle_outline_outlined),
                                            iconSize: 40,
                                            splashRadius: 20,
                                            color: Colors.deepOrange,
                                            splashColor: Colors.deepOrange,
                                            enableFeedback: true,
                                          ),
                                          onLongPress: () {
                                            if (globals.Snacks[
                                            index].counter > 0) {
                                              cart.removeall(globals.Snacks[index]);
                                              print(
                                                  "=============================================");
                                              print(
                                                  "${globals.Snacks[index].counter} : ${globals.Snacks[index].name}");
                                              print(
                                                  "=============================================");
                                            }
                                          },
                                        ),
                                      ),
                                      Container(
                                        width: 50,
                                        child: Center(
                                          child: Text(
                                            "${globals.Snacks[index].counter}",
                                            textDirection:
                                            TextDirection
                                                .rtl,
                                            style: TextStyle(
                                                fontSize:
                                                24.0,
                                                fontWeight:
                                                FontWeight
                                                    .bold),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        // flex: 3,
                                        child: IconButton(
                                          padding:
                                          EdgeInsets
                                              .zero,
                                          onPressed: () {
                                            globals
                                                .Snacks[
                                            index]
                                                .counter = globals
                                                .Snacks[
                                            index]
                                                .counter +
                                                1;
                                            cart.add(globals
                                                .Snacks[
                                            index]);
                                            print(
                                                "${globals.Snacks[index].counter} : ${globals.Snacks[index].name} ");
                                          },
                                          icon: new Icon(Icons
                                              .add_circle_outline),
                                          iconSize: 40,
                                          splashRadius: 20,
                                          color:
                                          Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
              : Stack(
            children: <Widget>[
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(5.0)),
                color: Colors.white.withOpacity(0.97),
                child: Container(
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 105,
                          height: 110,
                          margin:
                          EdgeInsets.only(left: 7.0),
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            imageUrl:
                            "${globals.Snacks[index].image}",
                            height: 200,
                            width: 200,
                            imageBuilder:
                                (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(
                                        5.0),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius:
                                  BorderRadius.circular(
                                      5.0),
                                ),
                              );
                            },
                            errorWidget:
                                (context, url, error) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius:
                                  BorderRadius.circular(
                                      5.0),
                                ),
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin:
                          EdgeInsets.only(bottom: 5),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: 15),
                                  child: Text(
                                    "${globals.Snacks[index].name}",
                                    style: TextStyle(
                                        fontSize: 23.0,
                                        fontWeight:
                                        FontWeight
                                            .bold),
                                    textDirection:
                                    TextDirection.rtl,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: 15, top: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment
                                        .end,
                                    children: <Widget>[
                                      Text(
                                        " L.E ${globals.Snacks[index].price} ",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Text(
                                        "السعر:",
                                        style: TextStyle(
                                          fontSize: 21.0,
                                        ),
                                        textDirection:
                                        TextDirection
                                            .rtl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Consumer<MyCart>(
                                builder:
                                    (context, cart, child) {
                                  return Expanded(
                                    child: Container(
                                      margin:
                                      EdgeInsets.only(
                                        right: 15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment
                                            .end,
                                        children: <Widget>[
                                          Container(
                                            child:
                                            IconButton(
                                              padding:
                                              EdgeInsets
                                                  .zero,
                                              onPressed:
                                              null,
                                              icon: new Icon(
                                                  Icons
                                                      .remove_circle_outline_outlined),
                                              iconSize: 40,
                                              splashRadius:
                                              20,
                                              color: Colors
                                                  .deepOrange,
                                              splashColor:
                                              Colors
                                                  .deepOrange,
                                              enableFeedback:
                                              true,
                                            ),
                                          ),
                                          Container(
                                            width: 50,
                                            child: Center(
                                              child: Text(
                                                "${globals.Snacks[index].counter}",
                                                textDirection:
                                                TextDirection
                                                    .rtl,
                                                style: TextStyle(
                                                    fontSize:
                                                    24.0,
                                                    fontWeight:
                                                    FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            child:
                                            IconButton(
                                              padding:
                                              EdgeInsets
                                                  .zero,
                                              onPressed:
                                              null,
                                              icon: new Icon(
                                                  Icons
                                                      .add_circle_outline),
                                              iconSize: 40,
                                              splashRadius:
                                              20,
                                              color: Colors
                                                  .blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
              RotationTransition(
                turns: AlwaysStoppedAnimation(-17 / 360),
                child: Center(
                  child: Text(
                    "غير متاح الآن",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ) : Stack(
      children: <Widget>[
        ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: globals.SnacksList.length,
          physics: NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Container(
              height: 130.0,
              child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                color: Colors.white.withOpacity(0.97),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: Container(
                          width: 105,
                          height: 110,
                          margin: EdgeInsets.only(left: 7.0),
                          child: CachedNetworkImage(
                            key: UniqueKey(),
                            imageUrl:
                            "${globals.Snacks[index].image}",
                            height: 200,
                            width: 200,
                            // fit: BoxFit.cover,
                            imageBuilder:
                                (context, imageProvider) =>
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(5.0),
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                            placeholder: (context, url) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius:
                                  BorderRadius.circular(5.0),
                                ),
                              );
                            },
                            errorWidget: (context, url, error) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.black12,
                                  borderRadius:
                                  BorderRadius.circular(5.0),
                                ),
                                child: Icon(
                                  Icons.fastfood,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 5),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.end,
                            children: <Widget>[
                              Expanded(
                                child: Container(
                                  margin:
                                  EdgeInsets.only(right: 15),
                                  child: Text(
                                    "${globals.Snacks[index].name}",
                                    style: TextStyle(
                                        fontSize: 23.0,
                                        fontWeight:
                                        FontWeight.bold),
                                    textDirection:
                                    TextDirection.rtl,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                      right: 15, top: 0),
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.end,
                                    children: <Widget>[
                                      Text(
                                        " L.E ${globals.Snacks[index].price} ",
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Text(
                                        "السعر:",
                                        style: TextStyle(
                                          fontSize: 21.0,
                                        ),
                                        textDirection:
                                        TextDirection.rtl,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Consumer<MyCart>(
                                builder: (context, cart, child) {
                                  return Expanded(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        right: 15,
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.end,
                                        children: <Widget>[
                                          Container(
                                            child: IconButton(
                                              padding:
                                              EdgeInsets.zero,
                                              onPressed: null,
                                              icon: new Icon(Icons
                                                  .remove_circle_outline_outlined),
                                              iconSize: 40,
                                              splashRadius: 20,
                                              color: Colors
                                                  .deepOrange,
                                              splashColor: Colors
                                                  .deepOrange,
                                              enableFeedback:
                                              true,
                                            ),
                                          ),
                                          Container(
                                              width: 50,
                                              child: Center(
                                                child: Text(
                                                  "${globals.Snacks[index].counter}",
                                                  textDirection:
                                                  TextDirection
                                                      .rtl,
                                                  style: TextStyle(
                                                      fontSize:
                                                      24.0,
                                                      fontWeight:
                                                      FontWeight
                                                          .bold),
                                                ),
                                              )),
                                          Container(
                                            // flex: 3,
                                            child: IconButton(
                                              padding:
                                              EdgeInsets.zero,
                                              onPressed: null,
                                              icon: new Icon(Icons
                                                  .add_circle_outline),
                                              iconSize: 40,
                                              splashRadius: 20,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        Container(
          child: Center(
            child: Text(
              "لا يمكنك الطلب الآن،\n برجاء المحاولة من الساعة ٧-٩ صباحا",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
              textDirection: TextDirection.rtl,
            ),
          ),
          height: 130.0 * globals.SnacksList.length,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5.0),
            color: Colors.black.withOpacity(0.6),
          ),
        ),
      ],
    ) : Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(bottom: 50.0),
            child: Column(
              children: <Widget>[
                Text(
                  "لا يوجد طلبات متاحة الآن",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF656464),
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    Reconnect() async {
                      globals.entered = false;
                      globals.WaitingAlert(
                        context,
                        title: "برجاء الإنتظار...",
                        content: "جار الإتصال بالسيرفر...",
                      );
                      await globals
                          .getMenu(int.parse(activate.auth.userID));
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
    );
  }
}
