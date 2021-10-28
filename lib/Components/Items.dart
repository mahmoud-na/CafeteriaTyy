class MenuItem {
  int id;
  int counter;
  int quantity;
  String name;
  double price;
  String image;
  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.counter,
    required this.quantity,
  });
}

class HistoryItem {
  int id;
  int counter;
  String name;
  double price;
  String orderStatus;

  HistoryItem({
    required this.id,
    required this.name,
    required this.price,
    required this.counter,
    required this.orderStatus,
  });
}
