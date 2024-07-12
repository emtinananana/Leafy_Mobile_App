import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/providers/postprovider.dart';
import 'package:leafy_mobile_app/providers/products_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  late User _user = User(id: 0, name: '', email: '', phone: '', address: '');
  ProductsProvider productsProvider;
  PostProvider postsProvider;

  AuthProvider(this.productsProvider, this.postsProvider);

  User get user => _user;

  Future<bool> login(
      Map<String, dynamic> loginBody, BuildContext context) async {
    bool isLoggedIn = false;

    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/customer/login"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(loginBody),
    );

    debugPrint("POST ON: http://127.0.0.1:8000/api/customer/login");
    debugPrint("SENT BODY: ${jsonEncode(loginBody)}");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("POST RES: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseBody = json.decode(response.body);
        isLoggedIn = true;
        _user = User(
          id: responseBody['user']['id'],
          name: responseBody['user']['name'],
          email: responseBody['user']['email'],
          avatar: responseBody['user']['avatar'],
          phone: responseBody['user']['phone'],
          address: responseBody['user']['address'],
          createdAt: DateTime.parse(responseBody['user']['created_at']),
          updatedAt: DateTime.parse(responseBody['user']['updated_at']),
        );
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", responseBody['token']);
      } catch (e) {
        debugPrint("Error decoding JSON: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Login Failed: Invalid response format"),
        ));
        isLoggedIn = false;
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Login Failed"),
      ));
      isLoggedIn = false;
    }

    if (isLoggedIn) {
      await productsProvider.fetchLikedProducts();
      await postsProvider.fetchLikedPosts();
    }

    return isLoggedIn;
  }

  Future<bool> register(
      Map<String, dynamic> registerBody, BuildContext context) async {
    final response = await http.post(
      Uri.parse("http://127.0.0.1:8000/api/customer/register"),
      body: registerBody,
    );

    debugPrint("POST ON: http://127.0.0.1:8000/api/customer/register");
    debugPrint("SENT BODY: $registerBody");
    debugPrint("STATUS CODE: ${response.statusCode}");
    debugPrint("POST RES: ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final responseBody = json.decode(response.body);

        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", responseBody['token']);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return const AlertDialog(
              title: Text("Success"),
              content: Text("Registration successful"),
            );
          },
        );

        return true;
      } catch (e) {
        debugPrint("Error parsing response: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("Registration failed: Error parsing response"),
        ));
        return false;
      }
    } else {
      final errorMessage =
          response.body.isNotEmpty ? response.body : "Unknown error occurred";
      debugPrint("Error message: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Registration failed: $errorMessage"),
      ));
      return false;
    }
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove('token');
    _user = User(id: 0, name: '', email: '', phone: '', address: '');
    await productsProvider.clearLikedProducts();
    // await prefs.remove(
    //     'liked_post_ids');
    await postsProvider
        .clearLikedPosts(); // Ensure this matches where liked post ids are stored
    return true;
  }

  void updateAvatar(String avatarUrl) {
    _user = User(
      id: _user.id,
      name: _user.name,
      email: _user.email,
      avatar: avatarUrl,
      phone: _user.phone,
      address: _user.address,
      createdAt: _user.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }

  void updateUserProfile(
      String name, String email, String phone, String address) {
    _user = User(
      id: _user.id,
      name: name,
      email: email,
      avatar: _user.avatar,
      phone: phone,
      address: address,
      createdAt: _user.createdAt,
      updatedAt: DateTime.now(),
    );
    notifyListeners();
  }
}

class User {
  final int id;
  final String name;
  final String email;
  final String? avatar;
  final String phone;
  final String address;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.avatar,
    required this.phone,
    required this.address,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      avatar: json['avatar'],
      phone: json['phone'],
      address: json['address'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}
