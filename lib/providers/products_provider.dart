import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:leafy_mobile_app/models/products_model.dart';

class ProductsProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  List<String> _productTypes = [];
  List<String> _tags = [];
  bool _isFailed = false;
  bool _isLoading = false;

  List<ProductModel> get products => _products;
  List<String> get productTypes => _productTypes;
  List<String> get tags => _tags;
  bool get isFailed => _isFailed;
  bool get isLoading => _isLoading;

  setFailed(bool status) {
    _isFailed = status;
    notifyListeners();
  }

  setLoading(bool status) {
    _isLoading = status;
    notifyListeners();
  }

  Future<void> getProducts() async {
    setLoading(true);
    try {
      final response =
          await http.get(Uri.parse("http://127.0.0.1:8000/api/catalog"));
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        _products = decodedData
            .map((productJson) => ProductModel.fromJson(productJson))
            .toList();
        setFailed(false);
      } else {
        setFailed(true);
      }
    } catch (error) {
      setFailed(true);
    } finally {
      setLoading(false);
    }
  }

  Future<List<String>> getProductTypes() async {
    const url = 'http://127.0.0.1:8000/api/productTypes';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        List<String> types =
            responseData.map((type) => type['name'] as String).toList();
        _productTypes = types;
        return types;
      } else {
        _productTypes = [];
        return [];
      }
    } catch (error) {
      _productTypes = [];
      return [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> getTags() async {
    try {
      final response =
          await http.get(Uri.parse('http://127.0.0.1:8000/api/tags/index'));
      if (response.statusCode == 200) {
        final List<dynamic> tagsJson = json.decode(response.body);
        _tags = tagsJson.map((tag) => tag['name'] as String).toList();
      } else {
        _tags = [];
      }
    } catch (error) {
      _tags = [];
    } finally {
      notifyListeners();
    }
  }

  Future<void> getProductsByType(String type) async {
    final response = await http
        .get(Uri.parse('http://127.0.0.1:8000/api/catalog/type/$type'));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);

      final List<ProductModel> products =
          (jsonData['products'] as List<dynamic>)
              .map((productJson) => ProductModel.fromJson(productJson))
              .toList();

      _products = products;
      notifyListeners(); // Notify listeners that the data has changed
    } else {
      print('Failed to load products (HTTP ${response.statusCode})');
    }
  }

  Future<void> filterProductsByTags(List<String> tags) async {
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/catalog/filter'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'tags': tags}),
      );
      debugPrint("tags filter  : ${response.statusCode}");
      debugPrint("BODY of filter by tag IS : ${response.body}");
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> productsJson = responseBody['products'];
        debugPrint("Filtered products JSON: $productsJson");
        _products =
            productsJson.map((json) => ProductModel.fromJson(json)).toList();
        setFailed(false);
      } else {
        setFailed(true);
      }
    } catch (e) {
      print('Error filtering products: $e');
      setFailed(true);
    } finally {
      notifyListeners();
    }
  }
}
