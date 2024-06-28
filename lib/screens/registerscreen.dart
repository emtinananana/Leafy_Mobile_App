import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:leafy_mobile_app/providers/authprovider.dart';
import 'package:leafy_mobile_app/screens/loginscreen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  GlobalKey<FormState> registerform = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController teamController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool hidePassword = false;

  @override
  void dispose() {
    nameController.dispose();
    teamController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: registerform,
        onChanged: () {
          registerform.currentState!.validate();
          setState(() {});
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(hintText: "Name"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your name";
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: teamController,
                  decoration: const InputDecoration(hintText: "Team"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your team name";
                    }

                    return null;
                  },
                ),
                TextFormField(
                  controller: phoneController,
                  decoration: const InputDecoration(hintText: "Phone"),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your phone";
                    }
                    if (value.length != 10) {
                      return "Phone must be 10 digits";
                    }

                    return null;
                  },
                ),
                TextFormField(
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  obscureText: hidePassword,
                  controller: passwordController,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "Please enter your password";
                    }
                    if (value.length < 8) {
                      return "Password must be at least 8 characters";
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                    prefixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          hidePassword = !hidePassword;
                        });
                      },
                      icon: Icon(hidePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    hintText: "Password",
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Already have an account?"),
                    TextButton(
                      child: const Text("Login"),
                      onPressed: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 35,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Provider.of<AuthProvider>(context, listen: false)
                              .register(
                            {
                              "name": nameController.text,
                              "team_code": teamController.text,
                              "phone": phoneController.text,
                              "password": passwordController.text
                            },
                            context,
                          ).then((registrationSuccessful) {
                            if (registrationSuccessful) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => const LoginScreen()),
                                (route) => false,
                              );
                            }
                          });
                        },
                        child: const Text("Register"),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
