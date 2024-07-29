import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leafy_mobile_app/models/products_model.dart';
import 'package:leafy_mobile_app/screens/product_details.dart';

class ProductCard extends StatelessWidget {
  final ProductModel? product;
  final String? message;

  const ProductCard({Key? key, this.product, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (product == null && message != null) {
      return Center(
        child: Text(
          message!,
          style: GoogleFonts.montserrat(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () {
        if (product != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailsScreen(product: product!),
            ),
          );
        }
      },
      child: Container(
        height: 400,
        width: 900,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product image
              if (product != null)
                Flexible(
                  flex: 3,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Image.network(
                      product!.firstImage,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          height: 200, // Placeholder height
                          child: Center(
                            child: Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name
                      if (product != null)
                        Text(
                          product!.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 7),
                      // Product price
                      if (product != null)
                        Text(
                          '\$${product!.price.toStringAsFixed(2)}', // Format price with two decimal places
                          style: GoogleFonts.roboto(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 8),
                      // Like count
                      if (product != null)
                        Row(
                          children: [
                            Icon(
                              Icons.favorite,
                              size: 16,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${product!.likeCount}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                          ],
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
  }
}
