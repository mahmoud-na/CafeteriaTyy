import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/Pages/MyCart.dart';
import '../globals.dart' as globals;

class Checkout_List_Builder extends StatefulWidget {
  const Checkout_List_Builder({Key? key}) : super(key: key);

  @override
  _Checkout_List_BuilderState createState() => _Checkout_List_BuilderState();
}

class _Checkout_List_BuilderState extends State<Checkout_List_Builder> {
  deleteCardConfirmationAlert(String title, String content, MyCart cart,
      int index, BuildContext context) {
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
                          ),
                        ),
                        child: TextButton(
                          child: Text(
                            'تأكيد',
                            style: TextStyle(
                                fontSize: 25.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.green),
                          ),
                          onPressed: () {
                            if (cart.Basketitem[index].counter > 0) {
                              cart.removeall(cart.Basketitem[index]);
                              Navigator.of(context).pop();
                              if (cart.TotalItems == 0) {
                                Navigator.of(context).pushNamed('HomePage');
                              }
                            }
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
                    )
                  ],
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    // final home = Provider.of<HomeState>(context);

    return Consumer<MyCart>(builder: (context, cart, child) {
      bool _onPressed(int index) {
        return (cart.Basketitem[index].counter == 0) ? false : true;
      }

      return Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            child: Card(
              color: Colors.transparent,
              elevation: 0.0,
              child: Column(
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text("الملخص  ",
                          style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.black)),
                    ],
                  ),
                  Divider(
                    height: 10,
                    endIndent: 60,
                    indent: 60,
                    // thickness: 2,
                    color: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        "${cart.TotalItems}",
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        "عدد الطلبات",
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                  Divider(
                    height: 10,
                    endIndent: 60,
                    indent: 60,
                    // thickness: 2,
                    color: Colors.grey,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Text(
                        "${cart.Totalprice}",
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        "المبلغ       ",
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                        textDirection: TextDirection.rtl,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            child: ListView.builder(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: cart.count,
              physics: BouncingScrollPhysics(),
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  height: 130.0,
                  child: Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0)),
                      color: Colors.white.withOpacity(0.97),
                      child: Container(
                        child: Row(
                          // mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            Container(
                              width: 110,
                              height: 100,
                              margin: EdgeInsets.only(left: 7.0),
                              child: CachedNetworkImage(
                                key: UniqueKey(),
                                imageUrl: "${cart.Basketitem[index].image}",
                                height: 200,
                                width: 200,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25.0),
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
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black12,
                                      borderRadius: BorderRadius.circular(25.0),
                                    ),
                                    child: Icon(
                                      Icons.fastfood,
                                      color: Colors.red,
                                    ),
                                  );
                                },
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10.0, top: 5.0),
                                child: Container(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      Expanded(
                                        child: Container(
                                          child: Text(
                                            "${cart.Basketitem[index].name}",
                                            style: TextStyle(
                                                fontSize: 23.0,
                                                fontWeight: FontWeight.bold),
                                            textDirection: TextDirection.rtl,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: <Widget>[
                                              Text(
                                                " L.E ${cart.Basketitem[index].price} ",
                                                style: TextStyle(
                                                  fontSize: 18.0,
                                                ),
                                                // textDirection: TextDirection.rtl,
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
                                      Container(
                                        // margin: EdgeInsets.zero,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Expanded(
                                              child: Container(
                                                child: IconButton(
                                                  onPressed: () {
                                                    deleteCardConfirmationAlert(
                                                        "إنتبه.. !",
                                                        "هل انت متأكد انك تريد حذف الطلب",
                                                        cart,
                                                        index,
                                                        context);
                                                  },
                                                  icon: Icon(Icons
                                                      .delete_outline_outlined),
                                                  iconSize: 30,
                                                  padding: EdgeInsets.only(
                                                      right: 40),
                                                  color: Colors.red,
                                                ),
                                                alignment: Alignment.centerLeft,
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                child: GestureDetector(
                                                  child: IconButton(
                                                    padding: EdgeInsets.zero,
                                                    onPressed: _onPressed(index)
                                                        ? () {
                                                            if (cart
                                                                    .Basketitem[
                                                                        index]
                                                                    .counter >
                                                                0) {
                                                              cart
                                                                  .Basketitem[
                                                                      index]
                                                                  .counter = cart
                                                                      .Basketitem[
                                                                          index]
                                                                      .counter -
                                                                  1;
                                                              print(
                                                                  "${cart.Basketitem[index].counter} : ${cart.Basketitem[index].name}");
                                                              cart.remove(
                                                                  cart.Basketitem[
                                                                      index]);
                                                              if (cart.TotalItems ==
                                                                  0) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pushNamed(
                                                                        'HomePage');
                                                              }
                                                            }
                                                          }
                                                        : null,
                                                    icon: new Icon(Icons
                                                        .remove_circle_outline_outlined),
                                                    iconSize: 40,
                                                    splashRadius: 20,
                                                    color: Colors.deepOrange,
                                                    splashColor:
                                                        Colors.deepOrange,
                                                    enableFeedback: true,
                                                  ),
                                                  onLongPress: () {
                                                    if (cart.Basketitem[index]
                                                            .counter >
                                                        0) {
                                                      cart.removeall(cart
                                                          .Basketitem[index]);
                                                      if (cart.TotalItems ==
                                                          0) {
                                                        Navigator.of(context)
                                                            .pushNamed(
                                                                'HomePage');
                                                      }
                                                    }
                                                  },
                                                ),
                                              ),
                                            ),
                                            Container(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 10.0),
                                                child: Center(
                                                  child: Text(
                                                    "${cart.Basketitem[index].counter}",
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    style: TextStyle(
                                                        fontSize: 24.0,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                )),
                                            Expanded(
                                              child: Container(
                                                child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  onPressed: () {
                                                    cart.Basketitem[index]
                                                        .counter = cart
                                                            .Basketitem[index]
                                                            .counter +
                                                        1;
                                                    cart.add(
                                                        cart.Basketitem[index]);
                                                    print(
                                                        "${cart.Basketitem[index].counter} : ${cart.Basketitem[index].name}");
                                                    print(
                                                        "global list ${globals.Items[index].counter} : ${globals.Items[index].name} ");
                                                  },
                                                  icon: new Icon(
                                                      Icons.add_circle_outline),
                                                  iconSize: 40,
                                                  splashRadius: 20,
                                                  color: Colors.blue,
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
                            ),
                          ],
                        ),
                      )),
                );
              },
            ),
          ),
        ],
      );
    });
  }
}
