import 'dart:async';
import 'dart:convert';

import 'package:leafy_mobile_app/models/products_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  List<ProductModel> products = [];

  bool isFailed = false;
  bool isLoading = false;

  setFailed(bool status) {
    Timer(const Duration(milliseconds: 50), () {
      isFailed = status;
      notifyListeners();
    });
  }

  setLoading(bool status) {
    Timer(const Duration(milliseconds: 50), () {
      isLoading = status;
      notifyListeners();
    });
  }

  getProducts() async {
    setLoading(true);

    try {
      final response =
          await http.get(Uri.parse("http://192.168.0.108:8000/api/catalog"));
      debugPrint("STATUS CODE : ${response.statusCode}");
      debugPrint("BODY IS : ${response.body}");

      if (response.statusCode == 200) {
        setFailed(false);
        var decodedData = json.decode(response.body) as List;

        products = decodedData
            .map((productJson) => ProductModel.fromJson(productJson))
            .toList();
        debugPrint("Products: $products");
      } else {
        setFailed(true);
        debugPrint("Failed to load products");
      }
    } catch (error) {
      debugPrint("Error fetching products: $error");
      setFailed(true);
    } finally {
      setLoading(false);
    }
  }
}
