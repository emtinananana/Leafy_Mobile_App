// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  Future<bool> login(Map loginBody, BuildContext context) async {
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
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString("token", responseBody['token']);

        // Show success message
      } catch (e) {
        debugPrint("Error decoding JSON: $e");
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Failed: Invalid response format")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Login Failed")));
    }

    return isLoggedIn;
  }

  Future<bool> register(Map registerBody, BuildContext context) async {
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

        // Show success message
        showDialog(
          context: context,
          builder: (BuildContext context) {
            Future.delayed(const Duration(seconds: 2), () {
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Registration failed: Error parsing response")),
        );
        return false;
      }
    } else {
      final errorMessage =
          response.body.isNotEmpty ? response.body : "Unknown error occurred";
      debugPrint("Error message: $errorMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $errorMessage")),
      );
      return false;
    }
  }

  Future<bool> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    return true;
  }
}
