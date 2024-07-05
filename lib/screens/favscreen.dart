import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leafy_mobile_app/providers/products_provider.dart';
import 'package:provider/provider.dart';

class FavScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);

    final likedProducts = productsProvider.likedProducts;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Favorites',
          style: GoogleFonts.oswald(
            fontSize: 24,
            color: const Color.fromARGB(221, 44, 163, 58),
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: likedProducts.isEmpty
          ? const Center(
              child: Text('No favorites yet.'),
            )
          : ListView.builder(
              itemCount: likedProducts.length,
              itemBuilder: (ctx, index) {
                final product = likedProducts[index];
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      product.firstImage,
                      fit: BoxFit.cover,
                    ),
                    title: Text(product.name),
                    subtitle: Text('Price: \$${product.price}'),
                    trailing: IconButton(
                      icon: const Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        productsProvider.unlikeProduct(product.id);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
