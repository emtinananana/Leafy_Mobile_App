import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leafy_mobile_app/providers/cartprovider.dart';
import 'package:provider/provider.dart';

import 'package:flutter_svg/flutter_svg.dart';

class GiftIconWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/gift.svg',
      height: 24.0,
      width: 24.0,
    );
  }
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<Map<String, dynamic>> _giftDetails = [];

  @override
  void initState() {
    super.initState();
    Provider.of<CartProvider>(context, listen: false).fetchCartItems();
  }

  Future<void> _fetchGiftProducts() async {
    setState(() {});
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      await cartProvider.fetchGiftProducts();
      setState(() {
        _giftDetails = List.from(cartProvider.giftDetails);
        // Ensure _giftDetails has the same length as cartItems
        while (_giftDetails.length < cartProvider.cartItems.length) {
          _giftDetails.add({
            "product_id": cartProvider.cartItems[_giftDetails.length]['product']
                ['id'],
            "recipient_name": null,
            "recipient_phone": null,
            "recipient_address": null,
            "note": null,
          });
        }
      });
    } catch (error) {
      print('Error fetching gift products: $error');
    } finally {
      setState(() {});
    }
  }

  Future<void> _showGiftDetailsDialog(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // Check if there are any gifts in the cart
    bool hasGifts =
        cartProvider.cartItems.any((cartItem) => cartItem['is_gift']);

    if (hasGifts) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            title: Text(
              'Add Gift Details',
              style: GoogleFonts.oswald(
                fontSize: 24,
                color: const Color.fromARGB(221, 44, 163, 58),
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (int index = 0;
                      index < cartProvider.cartItems.length;
                      index++)
                    if (cartProvider.cartItems[index]
                        ['is_gift']) // Only show for gift items
                      ListTile(
                        title: Text(
                          cartProvider.cartItems[index]['product']['name'],
                          style: GoogleFonts.oswald(
                            fontSize: 20,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  _giftDetails[index]['recipient_name'] ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Recipient Name',
                                labelStyle: TextStyle(color: Colors.green),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _giftDetails[index]['recipient_name'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue:
                                  _giftDetails[index]['recipient_phone'] ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Recipient Phone',
                                labelStyle: TextStyle(color: Colors.green),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _giftDetails[index]['recipient_phone'] =
                                      value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _giftDetails[index]
                                      ['recipient_address'] ??
                                  '',
                              decoration: const InputDecoration(
                                labelText: 'Recipient Address',
                                labelStyle: TextStyle(color: Colors.green),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _giftDetails[index]['recipient_address'] =
                                      value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _giftDetails[index]['note'] ?? '',
                              decoration: const InputDecoration(
                                labelText: 'Note',
                                labelStyle: TextStyle(color: Colors.green),
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _giftDetails[index]['note'] = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                  Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      color: const Color.fromARGB(221, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Confirm Order',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _checkout(context);
                },
              ),
            ],
          );
        },
      );
    } else {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Checkout',
                style: GoogleFonts.oswald(
                    fontSize: 24,
                    color: const Color.fromARGB(221, 44, 163, 58),
                    fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                    style: GoogleFonts.oswald(
                      fontSize: 14,
                      color: const Color.fromARGB(221, 0, 0, 0),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Confirm Order',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
                onPressed: () async {
                  Navigator.of(context).pop();
                  await _checkout(context);
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _checkout(BuildContext context) async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    List<Map<String, dynamic>> giftDetailsForCheckout = [];
    for (int i = 0; i < _giftDetails.length; i++) {
      final cartItem = cartProvider.cartItems[i];
      if (cartItem['is_gift']) {
        giftDetailsForCheckout.add({
          "product_id": cartItem['product']['id'],
          "recipient_name": _giftDetails[i]['recipient_name'],
          "recipient_phone": _giftDetails[i]['recipient_phone'],
          "recipient_address": _giftDetails[i]['recipient_address'],
          "note": _giftDetails[i]['note'],
        });
      }
    }

    if (giftDetailsForCheckout.isNotEmpty) {
      await cartProvider.checkout(giftDetails: giftDetailsForCheckout);
    } else {
      await cartProvider.checkout();
    }
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Order Placed Successfully',
                style: GoogleFonts.oswald(
                    fontSize: 24,
                    color: const Color.fromARGB(221, 44, 163, 58),
                    fontWeight: FontWeight.bold)),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Please check your order history for details.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(221, 0, 0, 0),
                    ),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('OK',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'My Cart',
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color.fromARGB(221, 44, 163, 58),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: cartProvider.cartItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Your cart is empty.',
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  : ListView.builder(
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final cartItem = cartProvider.cartItems[index];
                        final product = cartItem['product'];
                        final isGift = cartItem['is_gift'];

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                            leading: Image.network(
                              product['first_image'],
                              width: 60,
                              height: 60,
                              fit: BoxFit.contain,
                            ),
                            title: Row(
                              children: [
                                Text(
                                  product['name'],
                                  style: GoogleFonts.oswald(
                                    fontSize: 20,
                                  ),
                                ),
                                const SizedBox(width: 13),
                                if (cartItem['is_gift']) GiftIconWidget(),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 11),
                                Text('Price: \$${product['price']}'),
                                const SizedBox(height: 11),
                                Text('Quantity: ${cartItem['quantity']}'),
                                const SizedBox(height: 11),
                                if (cartItem['pot_type'] != null) ...[
                                  Text('Pot Type: ${cartItem['pot_type']}'),
                                ],
                                const SizedBox(height: 11),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                cartProvider.removeItem(cartItem['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          if (cartProvider.cartItems.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Total: \$${cartProvider.totalPrice.toStringAsFixed(2)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: cartProvider.cartItems.isEmpty
                  ? null
                  : () async {
                      await _fetchGiftProducts();
                      await _showGiftDetailsDialog(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: cartProvider.cartItems.isEmpty
                    ? Colors.grey
                    : const Color.fromARGB(221, 44, 163, 58), // Green color
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Checkout',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
