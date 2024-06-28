import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/main.dart';
import 'package:leafy_mobile_app/providers/authprovider.dart';
import 'package:leafy_mobile_app/providers/products_provider.dart';
import 'package:leafy_mobile_app/widgets/productcard.dart';
import 'package:leafy_mobile_app/widgets/shimmer.dart';

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ProductsProvider>(builder: (context, productsConsumer, _) {
      return Scaffold(
        appBar: AppBar(
            iconTheme: const IconThemeData(color: Colors.black87),
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.white,
            title: Text('Leafy', style: TextStyle(color: Colors.black87))),
        body: productsConsumer.isFailed
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.network_locked_sharp,
                        color: Colors.green.withOpacity(0.6),
                        size: size.width * 0.2),
                    const Text(
                      "Something went wrong!",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.black54),
                    )
                  ],
                ),
              )
            : Column(
                children: [
                  Divider(
                    color: Colors.green.withOpacity(0.2),
                    height: 0,
                  ),
                  Expanded(
                    child: GridView.builder(
                        padding: const EdgeInsets.all(24),
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24),
                        itemCount: productsConsumer.isLoading
                            ? 10
                            : productsConsumer.products.length,
                        itemBuilder: (context, index) {
                          return productsConsumer.isLoading
                              ? const ShimmerWidget()
                              : ProductCard(
                                  product: productsConsumer.products[index],
                                );
                        }),
                  )
                ],
              ),
        drawer: Drawer(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const ListTile(
                  title: Text("Contact Us"),
                ),
                const Divider(),
                GestureDetector(
                  onTap: () {
                    Provider.of<AuthProvider>(context, listen: false)
                        .logout()
                        .then((logedOut) {
                      if (logedOut) {
                        Navigator.pushAndRemoveUntil(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => const ScreenRouter()),
                            (route) => false);
                      }
                    });
                  },
                  child: const ListTile(
                    title: Text("Logout"),
                    trailing: Icon(Icons.exit_to_app),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    });
  }
}
