class Order {
  final int id;
  final String status;
  final String orderDate;
  final String? deliveryDate;
  final double total;
  final List<OrderProduct> orderProducts;

  Order({
    required this.id,
    required this.status,
    required this.orderDate,
    this.deliveryDate,
    required this.total,
    required this.orderProducts,
  });
}

class OrderProduct {
  final int id;
  final String name;
  final int quantity;
  final String productType;
  final double price;
  final GiftDetails? giftDetails;

  OrderProduct({
    required this.id,
    required this.name,
    required this.quantity,
    required this.productType,
    required this.price,
    this.giftDetails,
  });
}

class GiftDetails {
  final String recipientName;
  final String recipientPhone;
  final String recipientAddress;
  final String note;

  GiftDetails({
    required this.recipientName,
    required this.recipientPhone,
    required this.recipientAddress,
    required this.note,
  });
}
