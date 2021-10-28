import 'package:flutter/material.dart';
import '../Components/History.dart';
import '../Components/Items.dart';
import '../globals.dart' as globals;

class MyCart with ChangeNotifier {
  List<MenuItem> _Cart = [];
  // List<History> orders = globals.fullHistory;
  double price = 0.0;
  int totalitems = 0;
  int inedx = 0;

  void add(MenuItem item) {
    if (item.counter == 1) {
      _Cart.add(item);
      price += item.price;
      totalitems++;
    } else {
      price += item.price;
      totalitems++;
    }
    notifyListeners();
  }

  void remove(MenuItem item) {
    if (item.counter == 0) {
      _Cart.remove(item);
      price -= item.price;
      totalitems--;
    } else {
      price -= item.price;
      totalitems--;
    }
    notifyListeners();
  }

  void removeall(MenuItem item) {
    price -= item.price * item.counter;
    totalitems -= item.counter;
    item.counter = 0;
    _Cart.remove(item);
    notifyListeners();
  }

  ResetItems() {
    History _HistoryTmp = History();
    _HistoryTmp.price = price;
    List<MenuItem> tmp = [];
    while (Basketitem.length > 0) {
      _Cart.remove(Basketitem[Basketitem.length - 1]);
    }
    globals.ResetItems();
    totalitems = 0;
    price = 0;
    notifyListeners();
  }
  notifyListnerRefresh(){
    notifyListeners();
  }

  int get count {
    return _Cart.length;
  }

  int get TotalItems {
    return totalitems;
  }

  List<MenuItem> get Basketitem {
    return _Cart;
  }

  double get Totalprice {
    return price;
  }
}

class Order {
  String date = "";
  String time = "";
}
