import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:leafy_mobile_app/main.dart';
import 'package:leafy_mobile_app/providers/authprovider.dart';
import 'package:leafy_mobile_app/screens/registerscreen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  GlobalKey<FormState> loginForm = GlobalKey<FormState>();

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/leafyleafyh.jpg',
            fit: BoxFit.cover,
          ),
          // Transparent container overlay with login form
          Container(
            color: Colors.black.withOpacity(0.14),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: loginForm,
                onChanged: () {
                  loginForm.currentState!.validate();
                  setState(() {});
                },
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextFormField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Email",
                          hintStyle: const TextStyle(color: Colors.white),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your email";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        style:
                            const TextStyle(color: Colors.white), // Text color
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        obscureText: hidePassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          hintText: "Password",
                          hintStyle: const TextStyle(color: Colors.white),
                          prefixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                hidePassword = !hidePassword;
                              });
                            },
                            icon: Icon(hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                            color: Colors.white,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.white),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.red),
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter your password";
                          }

                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Don't have an account?",
                              style: TextStyle(color: Colors.white)),
                          TextButton(
                            child: const Text("Create Account",
                                style: TextStyle(color: Colors.white)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          onPressed: () {
                            Provider.of<AuthProvider>(context, listen: false)
                                .login({
                              "email": emailController.text,
                              "password": passwordController.text
                            }, context).then((loggedIn) {
                              if (loggedIn) {
                                showDialog(
                                  context: context,
                                  barrierDismissible:
                                      false, // Prevent dialog from being dismissed by tapping outside
                                  builder: (BuildContext context) {
                                    Future.delayed(const Duration(seconds: 2),
                                        () {
                                      Navigator.of(context).pop();
                                      Navigator.pushAndRemoveUntil(
                                        context,
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              const ScreenRouter(),
                                        ),
                                        (route) => false,
                                      );
                                    });
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16.0)),
                                      title: Image.asset(
                                        'assets/plant.png',
                                        height: 20,
                                      ),
                                      content: Text(
                                        "Login successful",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.oswald(
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(89, 149, 180, 158),
                            minimumSize: const Size(114, 40),
                          ),
                          child: const Text('Login',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 17)))
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
