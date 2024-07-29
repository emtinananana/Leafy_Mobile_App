import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leafy_mobile_app/main.dart';
import 'package:leafy_mobile_app/screens/cartscreen.dart';
import 'package:leafy_mobile_app/screens/contactus_screen.dart';
import 'package:leafy_mobile_app/screens/favscreen.dart';
import 'package:leafy_mobile_app/screens/historyscreen.dart';
import 'package:leafy_mobile_app/screens/postsscreen.dart';
import 'package:leafy_mobile_app/screens/profilescreen.dart';
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
    setState(() {
      if (query.isEmpty) {
        searchController.clear();
      } else {
        selectedProductType = 'All';
        searchController.text = query;
      }
    });

    Provider.of<ProductsProvider>(context, listen: false).searchProducts(query);
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for products...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.green,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear,
                            color: Color.fromARGB(221, 44, 163, 58)),
                        onPressed: () {
                          setState(() {
                            searchProducts('');
                          });
                        },
                      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
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
                            onClearSearch: () {
                              setState(() {
                                searchController.clear();
                              });
                            },
                          );
                        }).toList(),
                        IconButton(
                          icon: const Icon(
                            Icons.filter_list_alt,
                            color: Colors.green,
                          ),
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
                      : filteredProducts(productsConsumer).isEmpty
                          ? ProductCard(
                              message: 'No products found.',
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
                              itemCount:
                                  filteredProducts(productsConsumer).length,
                              itemBuilder: (context, index) {
                                return ProductCard(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HistoryScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.favorite,
                        color: Colors.green.withOpacity(0.86)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => FavScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.post_add,
                        color: Colors.green.withOpacity(0.86)),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostsScreen()));
                    },
                  ),
                ],
              ),
            ),
            drawer: Drawer(
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ListTile(
                      title: const Text("Profile"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    ListTile(
                      title: Text("Contact Us"),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContactUsScreen(),
                          ),
                        );
                      },
                    ),
                    const Divider(),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Confirm Logout",
                                  style: GoogleFonts.oswald(
                                      fontSize: 24,
                                      color: const Color.fromARGB(
                                          221, 44, 163, 58),
                                      fontWeight: FontWeight.bold)),
                              content: const Text(
                                  "Are you sure you want to logout?"),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text(
                                    "Cancel",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          221, 44, 163, 58),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                TextButton(
                                  child: const Text(
                                    "Logout",
                                    style: TextStyle(
                                      color: const Color.fromARGB(
                                          221, 44, 163, 58),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Close the dialog
                                    Provider.of<AuthProvider>(context,
                                            listen: false)
                                        .logout()
                                        .then((loggedOut) {
                                      if (loggedOut) {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const ScreenRouter(),
                                          ),
                                          (route) => false,
                                        );
                                      }
                                    });
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: const ListTile(
                        title: Text("Logout"),
                        trailing: Icon(Icons.exit_to_app),
                      ),
                    ),
                  ],
                ),
              ),
            ));
      },
    );
  }

  List<ProductModel> filteredProducts(ProductsProvider productsConsumer) {
    return productsConsumer.products.where((product) {
      return selectedProductType == 'All' ||
          product.productType == selectedProductType;
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
              title: Text(
                'Filter by Tags',
                style: GoogleFonts.oswald(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
                          activeColor: Color.fromARGB(221, 44, 163, 58),
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
                  child: const Text('Cancel',
                      style:
                          TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Apply and close dialog
                    if (selectedTags.isEmpty) {
                      productsConsumer
                          .getProducts(); // Fetch all products if no tags are selected
                    } else {
                      productsConsumer.filterProductsByTags(
                          selectedTags); // Filter by selected tags
                    }
                  },
                  child: const Text('Apply',
                      style:
                          TextStyle(color: Color.fromARGB(221, 44, 163, 58))),
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
  final VoidCallback? onClearSearch;

  const FilterButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.onClearSearch,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Clear search input when a product type filter is selected
        if (onClearSearch != null) {
          onClearSearch!();
        }
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.all(4.0),
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
