import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> _giftDetails = [];
  double _totalPrice = 0.0;

  List<Map<String, dynamic>> get giftDetails => _giftDetails;
  List<Map<String, dynamic>> get cartItems => _cartItems;
  double get totalPrice => _totalPrice;

  Future<void> fetchCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      // Handle the case where the token is not available
      return;
    }

    final response = await http.get(
      Uri.parse("http://127.0.0.1:8000/api/customer/cart"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    debugPrint("GET ON: http://127.0.0.1:8000/api/customer/cart");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      debugPrint("PARSED RESPONSE DATA: $data");
      _cartItems =
          List<Map<String, dynamic>>.from(data['shoppingCart']['cart_items']);
      debugPrint("CART ITEMS: $_cartItems");
      _updateTotalPrice();
      notifyListeners();
    } else {
      debugPrint(
          "Failed to fetch cart items. Status code: ${response.statusCode}");
    }
  }

  void _updateTotalPrice() {
    _totalPrice = _calculateTotalPrice(_cartItems);
  }

  double _calculateTotalPrice(List<Map<String, dynamic>> cartItems) {
    double totalPrice = 0.0;
    cartItems.forEach((cartItem) {
      final product = cartItem['product'];
      totalPrice += double.parse(product['price']) * cartItem['quantity'];
    });
    return totalPrice;
  }

  Future<void> removeItem(int cartItemId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      // Handle the case where the token is not available
      return;
    }

    final response = await http.delete(
      Uri.parse("http://127.0.0.1:8000/api/customer/cart/remove/$cartItemId"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      // Remove item from local list and notify listeners
      _cartItems.removeWhere((item) => item['id'] == cartItemId);
      _updateTotalPrice();
      notifyListeners();
    } else {
      // Handle error
    }
  }

  Future<void> checkout({List<Map<String, dynamic>>? giftDetails}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      // Handle the case where the token is not available
      return;
    }

    // Prepare the checkout request body
    Map<String, dynamic> requestBody = {
      // Add other required fields for checkout
    };

    if (giftDetails != null && giftDetails.isNotEmpty) {
      // Include gift details in the request body if provided
      requestBody['gift_details'] = giftDetails;
    }

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/customer/cart/checkout"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Checkout successful, clear cart items
      _cartItems.clear();
      _totalPrice = 0.0;
      _giftDetails.clear(); // Clear gift details after checkout
      notifyListeners();
    } else {
      // Handle error
      print('Failed to checkout. Status code: ${response.statusCode}');
    }
  }

  Future<void> fetchGiftProducts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/customer/giftproducts'),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Map<String, dynamic>> giftProducts = [];
        if (jsonData.containsKey('gift_products')) {
          giftProducts = List<Map<String, dynamic>>.from(
            jsonData['gift_products'],
          );
        }
        // Process fetched gift products
        // Example: _processGiftProducts(giftProducts);
      } else {
        throw Exception('Failed to fetch gift products');
      }
    } catch (error) {
      throw error;
    }
  }

  // Method to add gift details
  void addGiftDetails(Map<String, dynamic> giftDetails) {
    _giftDetails.add(giftDetails);
    notifyListeners();
  }

  // Method to remove gift details (if needed)
  void removeGiftDetails(int index) {
    _giftDetails.removeAt(index);
    notifyListeners();
  }

  // Method to clear all gift details
  void clearGiftDetails() {
    _giftDetails.clear();
    notifyListeners();
  }
}
