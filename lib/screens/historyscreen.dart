import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:leafy_mobile_app/models/ordermodel.dart';

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customer/history'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Order> fetchedOrders = [];
        for (var orderData in jsonData['orders']) {
          List<OrderProduct> orderProducts = [];
          for (var orderProductData in orderData['order_products']) {
            orderProducts.add(OrderProduct(
              id: orderProductData['id'],
              name: orderProductData['product']['name'],
              quantity: orderProductData['quantity'],
              productType: orderProductData['product']['product_type'],
              price: double.parse(orderProductData['product']['price']),
              giftDetails: orderProductData['gift_details'] != null
                  ? GiftDetails(
                      recipientName: orderProductData['gift_details']
                          ['recipient_name'],
                      recipientPhone: orderProductData['gift_details']
                          ['recipient_phone'],
                      recipientAddress: orderProductData['gift_details']
                          ['recipient_address'],
                      note: orderProductData['gift_details']['note'],
                    )
                  : null,
            ));
          }
          fetchedOrders.add(Order(
            id: orderData['id'],
            status: orderData['status'],
            orderDate: orderData['order_date'],
            deliveryDate: orderData['delivery_date'],
            total: double.parse(orderData['total']),
            orderProducts: orderProducts,
          ));
        }
        setState(() {
          orders = fetchedOrders;
        });
      } else {
        print('Failed to fetch orders: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Order History',
            style: GoogleFonts.oswald(
              fontSize: 24,
              color: const Color.fromARGB(221, 44, 163, 58),
              fontWeight: FontWeight.bold,
            )),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: orders.isEmpty
          ? const Center(
              child: Text(
                'You have no orders yet.',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            )
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ExpansionTile(
                    title: Text(
                      'Status: ${order.status}',
                      style: const TextStyle(
                        color: Color.fromARGB(221, 0, 0, 0), // Black color
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Total: ${order.total}',
                        style: const TextStyle(
                          color:
                              Color.fromARGB(221, 44, 163, 58), // Green color
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    children: [
                      ListTile(
                        title: Text('Order Date: ${order.orderDate}'),
                        subtitle: order.deliveryDate != null
                            ? Text('Delivery Date: ${order.deliveryDate}')
                            : null,
                      ),
                      const SizedBox(height: 8), // Additional spacing
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: order.orderProducts.length,
                        itemBuilder: (context, index) {
                          final orderProduct = order.orderProducts[index];
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                title: Text(orderProduct.name),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                        height: 8), // Additional spacing
                                    Text('Quantity: ${orderProduct.quantity}'),
                                    const SizedBox(
                                        height: 8), // Additional spacing
                                    Text(
                                      'Price: \$${orderProduct.price.toStringAsFixed(2)}',
                                    ),
                                    if (orderProduct.giftDetails != null) ...[
                                      const SizedBox(
                                          height: 8), // Additional spacing
                                      const Divider(),
                                      const Text('Gift Details:'),
                                      const SizedBox(
                                          height: 8), // Additional spacing
                                      Text(
                                        'Recipient Name: ${orderProduct.giftDetails!.recipientName}',
                                      ),
                                      const SizedBox(
                                          height: 8), // Additional spacing
                                      Text(
                                        'Recipient Phone: ${orderProduct.giftDetails!.recipientPhone}',
                                      ),
                                      const SizedBox(
                                          height: 8), // Additional spacing
                                      Text(
                                        'Recipient Address: ${orderProduct.giftDetails!.recipientAddress}',
                                      ),
                                      const SizedBox(
                                          height: 8), // Additional spacing
                                      Text(
                                        'Note: ${orderProduct.giftDetails!.note}',
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (index < order.orderProducts.length - 1)
                                const Divider(), // Divider between order products
                            ],
                          );
                        },
                      ),
                      if (order.status == 'pending')
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () =>
                                showCancelConfirmationDialog(order.id),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                              const Color.fromARGB(221, 44, 163, 58),
                            )),
                            child: const Text(
                              'Cancel Order',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void showCancelConfirmationDialog(int orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cancel Order',
              style: GoogleFonts.oswald(
                  fontSize: 24,
                  color: const Color.fromARGB(221, 44, 163, 58),
                  fontWeight: FontWeight.bold)),
          content: const Text('Are you sure you want to cancel this order?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: const Color.fromARGB(221, 44, 163, 58)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                cancelOrder(orderId); // Proceed with canceling the order
              },
              child: const Text('Yes',
                  style: TextStyle(
                    color: const Color.fromARGB(221, 44, 163, 58),
                  )),
            ),
          ],
        );
      },
    );
  }

  Future<void> cancelOrder(int orderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/customer/orders/$orderId'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
            'Order cancelled successfully',
          ),
          backgroundColor: Colors.green,
        ));
        fetchOrders(); // Refresh orders after cancellation
      } else {
        print('Failed to cancel order: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to cancel order'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error cancelling order: $e');
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error cancelling order'),
        backgroundColor: Colors.green,
      ));
    }
  }
}
