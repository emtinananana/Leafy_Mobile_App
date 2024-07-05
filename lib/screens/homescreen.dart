import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leafy_mobile_app/main.dart';
import 'package:leafy_mobile_app/screens/cartscreen.dart';
import 'package:provider/provider.dart';
import 'package:leafy_mobile_app/models/products_model.dart';
import 'package:leafy_mobile_app/providers/authprovider.dart';
import 'package:leafy_mobile_app/providers/products_provider.dart';
import 'package:leafy_mobile_app/widgets/productcard.dart';
import 'package:leafy_mobile_app/widgets/shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController searchController = TextEditingController();
  String selectedProductType = 'All';
  List<String> productTypes = ['All'];
  List<String> _tags = [];
  void searchProducts(String query) {
    if (query.isEmpty) {
      setState(() {
        // Clear the search and show all products based on selected type
        selectedProductType = 'All';
      });
      Provider.of<ProductsProvider>(context, listen: false).getProducts();
    } else {
      // Update search query and filter products

      setState(() {
        // selectedProductType = 'All';
        //  // Reset product type filter
      });
      Provider.of<ProductsProvider>(context, listen: false);
      searchProducts(query);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      await Provider.of<ProductsProvider>(context, listen: false).getProducts();
      await fetchProductTypes();
      await fetchTags();
    });

    // searchController.addListener(() {
    //   if (searchController.text.isEmpty) {
    //     setState(() {
    //       selectedProductType = 'All';
    //     });
    //     Provider.of<ProductsProvider>(context, listen: false).getProducts();
    //   }
    // });
  }

  Future<void> fetchProductTypes() async {
    final types = await Provider.of<ProductsProvider>(context, listen: false)
        .getProductTypes();
    setState(() {
      productTypes.addAll(types);
    });
  }

  Future<void> fetchTags() async {
    await Provider.of<ProductsProvider>(context, listen: false).getTags();
    setState(() {
      _tags = Provider.of<ProductsProvider>(context, listen: false).tags;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Consumer<ProductsProvider>(
      builder: (context, productsConsumer, _) {
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
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search for products...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                  onChanged: (query) {
                    setState(() {
                      searchProducts(query);
                    });
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ...productTypes.map((type) {
                        return FilterButton(
                          label: type,
                          isSelected: selectedProductType == type,
                          onTap: () {
                            setState(() {
                              selectedProductType = type;
                              if (type == 'All') {
                                productsConsumer.getProducts();
                              } else {
                                productsConsumer.getProductsByType(type);
                              }
                            });
                          },
                        );
                      }).toList(),
                      IconButton(
                        icon:
                            const Icon(Icons.filter_list, color: Colors.green),
                        onPressed: () {
                          selectedProductType = 'All';
                          _showTagFilterDialog(productsConsumer);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Divider(
                color: Colors.green.withOpacity(0.2),
                height: 0,
              ),
              Expanded(
                child: productsConsumer.isFailed
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.network_locked_sharp,
                              color: Colors.green.withOpacity(0.6),
                              size: size.width * 0.2,
                            ),
                            const Text(
                              "Something went wrong!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(24),
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 24,
                          mainAxisSpacing: 24,
                        ),
                        itemCount: productsConsumer.isLoading
                            ? 10
                            : filteredProducts(productsConsumer).length,
                        itemBuilder: (context, index) {
                          return productsConsumer.isLoading
                              ? const ShimmerWidget()
                              : ProductCard(
                                  product:
                                      filteredProducts(productsConsumer)[index],
                                );
                        },
                      ),
              ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 4.0,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.shopping_cart,
                      color: Colors.green.withOpacity(0.86)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.history,
                      color: Colors.green.withOpacity(0.86)),
                  onPressed: () {
                    // Navigate to history
                  },
                ),
                IconButton(
                  icon: Icon(Icons.favorite,
                      color: Colors.green.withOpacity(0.86)),
                  onPressed: () {
                    // Navigate to favorites
                  },
                ),
                IconButton(
                  icon: Icon(Icons.post_add,
                      color: Colors.green.withOpacity(0.86)),
                  onPressed: () {
                    // Navigate to posts
                  },
                ),
              ],
            ),
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
                          .then((loggedOut) {
                        if (loggedOut) {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ScreenRouter(),
                            ),
                            (route) => false,
                          );
                        }
                      });
                    },
                    child: const ListTile(
                      title: Text("Logout"),
                      trailing: Icon(Icons.exit_to_app),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  List<ProductModel> filteredProducts(ProductsProvider productsConsumer) {
    String query = searchController.text.toLowerCase();
    return productsConsumer.products.where((product) {
      bool matchesQuery = product.name.toLowerCase().contains(query);
      bool matchesType = selectedProductType == 'All' ||
          selectedProductType.isEmpty ||
          product.productType == selectedProductType;
      return matchesQuery && matchesType;
    }).toList();
  }

  Future<void> _showTagFilterDialog(ProductsProvider productsConsumer) async {
    List<String> selectedTags = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: const Text('Filter by Tags'),
              content: SingleChildScrollView(
                child: Consumer<ProductsProvider>(
                  builder: (context, productsProvider, _) {
                    final tags = productsProvider.tags;
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: tags.map((tag) {
                        return CheckboxListTile(
                          title: Text(tag),
                          value: selectedTags.contains(tag),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value != null) {
                                if (value) {
                                  selectedTags.add(tag); // Add tag if checked
                                } else {
                                  selectedTags
                                      .remove(tag); // Remove tag if unchecked
                                }
                              }
                            });
                          },
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cancel dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Apply and close dialog
                    productsConsumer.filterProductsByTags(selectedTags);
                  },
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class FilterButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8.0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
