import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:leafy_mobile_app/models/products_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  _ProductDetailsScreenState createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  int _selectedImageIndex = 0;
  int _quantity = 1;
  bool _isGift = false;
  String? _selectedPotType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'L E A F Y',
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color.fromARGB(221, 44, 163, 58),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main product image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                widget.product.images[_selectedImageIndex].image,
                height: 250,
                width: double.infinity,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16.0),
            // Thumbnails
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.product.images.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedImageIndex = index;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8.0),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _selectedImageIndex == index
                              ? Colors.green
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.product.images[index].image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              widget.product.name,
              style: GoogleFonts.oswald(
                fontSize: 24,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              '\$${widget.product.price}',
              style: GoogleFonts.roboto(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16.0),
            Text(
              'Product Type: ${widget.product.productType}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 8.0),
            Text(
              'Tags: ${widget.product.tags.map((tag) => tag.name).join(', ')}',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Description:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            Text(
              widget.product.description,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            if (widget.product.plantInstructions != null) ...[
              const SizedBox(height: 16.0),
              const Text(
                'Plant Instructions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ...widget.product.plantInstructions!.map((instruction) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      instruction.instruction,
                      style:
                          const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  )),
            ],
            const SizedBox(height: 16.0),
            if (widget.product.quantity <= 1)
              const Center(
                child: Text(
                  'Out of Stock',
                  style: TextStyle(fontSize: 18, color: Colors.red),
                ),
              ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: widget.product.quantity > 1
              ? () {
                  _showAddToCartModal(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor:
                widget.product.quantity > 1 ? Colors.green : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: Text(
            'Add to Cart',
            style: TextStyle(
              color:
                  widget.product.quantity > 1 ? Colors.white : Colors.black38,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showAddToCartModal(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add to Cart',
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    color: const Color.fromARGB(221, 44, 163, 58),
                    fontWeight: FontWeight.bold,
                  )),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Quantity'),
                        SizedBox(width: 130),
                        DropdownButton<int>(
                          value: _quantity,
                          items: List.generate(5, (index) => index + 1)
                              .map((e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e.toString()),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _quantity = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Is this a gift?'),
                        Checkbox(
                          value: _isGift,
                          onChanged: (value) {
                            setState(() {
                              _isGift = value!;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    if (widget.product.productType == 'Plant')
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Pot Type'),
                          SizedBox(width: 80),
                          DropdownButton<String>(
                            value: _selectedPotType,
                            items: ['Plastic', 'Ceramic', 'Glass']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPotType = value!;
                              });
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58)),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _addToCart();
                    Navigator.of(context).pop();
                  },
                  child: const Text(
                    'Add to Cart',
                    style: TextStyle(color: Color.fromARGB(221, 44, 163, 58)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _addToCart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    final response = await http.post(
      Uri.parse(
          "http://127.0.0.1:8000/api/customer/cart/add/${widget.product.id}"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'quantity': _quantity,
        'is_gift': _isGift,
        if (_selectedPotType != null) 'pot_type': _selectedPotType,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Added to cart successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to add to cart")),
      );
    }
  }
}
