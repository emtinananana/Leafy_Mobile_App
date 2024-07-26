import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:leafy_mobile_app/models/products_model.dart';
import 'package:leafy_mobile_app/providers/products_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailsScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailsScreen({Key? key, required this.product})
      : super(key: key);

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
    final productsProvider = Provider.of<ProductsProvider>(context);

    // Check if the product is liked
    bool isLiked = productsProvider.likedProductIds.contains(widget.product.id);

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.product.name,
                  style: GoogleFonts.oswald(
                    fontSize: 24,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Colors.grey,
                    size: 30,
                  ),
                  onPressed: () async {
                    await productsProvider.toggleLike(widget.product.id);
                    setState(() {});
                    final message = isLiked
                        ? 'Product unliked successfully!'
                        : 'Product liked successfully!';
                    final snackBar = SnackBar(
                      content: Text(message),
                      backgroundColor: Colors.green,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                ),
              ],
            ),

            const SizedBox(height: 18.0),
            Text(
              '\$${widget.product.price}',
              style: GoogleFonts.roboto(
                fontSize: 22,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 18.0),
            Row(
              children: [
                const Text('Product Type  ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  widget.product.productType,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18.0),
            Row(
              children: [
                const Text('Tags  ',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  widget.product.tags.map((tag) => tag.name).join(', '),
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 18.0),
            const Text(
              'Description ',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18.0),
            Text(
              widget.product.description,
              style: const TextStyle(fontSize: 18, color: Colors.black54),
            ),
            if (widget.product.plantInstructions != null) ...[
              const SizedBox(height: 18.0),
              const Text(
                'Plant Instructions ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16.0),
              ...widget.product.plantInstructions!.map((instruction) {
                Widget instructionText = Text(
                  instruction.instruction,
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                );

                if (instruction.instruction.contains('Water')) {
                  instructionText = Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.water_drop,
                              size: 24,
                              color: Color.fromARGB(255, 144, 205, 255)),
                          const SizedBox(width: 8),
                          instructionText,
                        ],
                      ),
                      const SizedBox(height: 13),
                    ],
                  );
                } else if (instruction.instruction.contains('sun')) {
                  instructionText = Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.wb_sunny,
                              size: 24, color: Colors.orange),
                          const SizedBox(width: 8),
                          instructionText,
                        ],
                      ),
                      const SizedBox(height: 13),
                    ],
                  );
                } else if (instruction.instruction.contains('Pet')) {
                  instructionText = Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.pets,
                              size: 24,
                              color: Color.fromARGB(255, 133, 198, 135)),
                          const SizedBox(width: 8),
                          instructionText,
                        ],
                      ),
                      const SizedBox(height: 13),
                    ],
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: instructionText,
                );
              }),
            ],
            const SizedBox(height: 30.0),
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
        padding: const EdgeInsets.all(25.0),
        child: ElevatedButton(
          onPressed: widget.product.quantity > 1
              ? () {
                  _showAddToCartModal(context);
                }
              : null,
          style: ElevatedButton.styleFrom(
            foregroundColor:
                widget.product.quantity > 1 ? Colors.white : Colors.black38,
            backgroundColor:
                widget.product.quantity > 1 ? Colors.green : Colors.grey,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Add to Cart'),
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
              title: Text(
                'Add to Cart',
                style: GoogleFonts.oswald(
                  fontSize: 24,
                  color: const Color.fromARGB(221, 44, 163, 58),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Quantity'),
                        const SizedBox(width: 130),
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
                    const SizedBox(height: 10),
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
                    if (widget.product.productType == 'Plant')
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          const Text('Select pot type:'),
                          const SizedBox(height: 8.0),
                          DropdownButton<String>(
                            value: _selectedPotType,
                            hint: const Text('Select pot type'),
                            items: ['Plastic', 'Ceramic', 'Glass']
                                .map((type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(type),
                                    ))
                                .toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedPotType = value;
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
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                const SizedBox(
                  width: 18,
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (widget.product.productType == 'Plant' &&
                        _selectedPotType == null) {
                      // Show a message if pot type is required but not selected
                      const snackBar = SnackBar(
                        content: Text('Please select a pot type.'),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      return;
                    }
                    await _addToCart();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color.fromARGB(221, 44, 163, 58),
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: const Text('Add'),
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
    String? potType = _selectedPotType;

    if (token == null) {
      // Handle case where user is not logged in
      return;
    }

    var url = Uri.parse(
        'http://127.0.0.1:8000/api/customer/cart/add/${widget.product.id}');
    var body = json.encode({
      'quantity': _quantity,
      'is_gift': _isGift,
      'pot_type': widget.product.productType == 'Plant' ? potType : null,
    });

    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      Navigator.of(context).pop();
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Added To Cart Successfully',
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
                      'Please check your cart for details.',
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
                      style:
                          TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          });
    } else {
      // Handle error
    }
  }
}
